#!/usr/bin/env bash
#
# Local project pipeline for DividendenDackel.
#
# Runs the same quality gate that CI runs, so a green run here means a green
# run on GitHub (Vision.md §65, §67). The CI workflow invokes this very script
# so the two cannot drift apart.
set -u
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE_LOG_DIR="${TMPDIR:-/tmp}/DividendenDackel-pipeline-$$"
trap 'rm -rf "${PIPELINE_LOG_DIR}"' EXIT

# Keep in sync with .github/workflows/ci.yml and CONTRIBUTING.md (Vision.md §70).
readonly PINNED_FLUTTER_VERSION="3.44.7"
readonly REQUIRED_MIN_SDK="29"
readonly GRADLE_FILE="android/app/build.gradle.kts"

declare -a SUMMARY_LINES=()

RUN_APP=1
STAGE="all"

TOOLCHAIN_OK=0
DEPS_OK=0
FORMAT_OK=0
ANALYZE_OK=0
TESTS_OK=0
ANDROID_COMPAT_OK=0
BUILD_LINUX_OK=0
BUILD_ANDROID_OK=0

TOOLCHAIN_DETAILS=""
TESTS_DETAILS=""
ANALYZE_DETAILS=""
BUILD_LINUX_DETAILS=""
BUILD_ANDROID_DETAILS=""

print_usage() {
    cat <<EOF
Usage: ./localPipeline.sh [--noRun] [--stage <name>]

Local project pipeline:
  1. Verify the Flutter/Dart toolchain and report the version in use
  2. Fetch dependencies (flutter pub get)
  3. Check formatting (dart format --set-exit-if-changed)
  4. Run static analysis (flutter analyze)
  5. Run the test suite (flutter test)
  6. Assert Android 10 compatibility (minSdk stays ${REQUIRED_MIN_SDK})
  7. Build the Linux x86_64 release bundle
  8. Build the Android release APK
  9. Launch the Linux app briefly as a smoke test (skipped with --noRun)
 10. Print a final stage-by-stage summary

Options:
  --noRun          Skip the application launch stage. Always use this in CI and
                   on headless machines.
  --stage <name>   Run a subset of stages. One of:
                     all       every stage (default)
                     quality   toolchain, deps, format, analyze, tests
                     android   toolchain, deps, compatibility check, APK build
                     linux     toolchain, deps, Linux bundle build
  --help           Show this help.
EOF
}

log() {
    printf '[INFO] %s\n' "$*"
}

warn() {
    printf '[WARN] %s\n' "$*" >&2
}

error() {
    printf '[ERROR] %s\n' "$*" >&2
}

mark_result() {
    local label="$1"
    local status="$2"
    local details="$3"
    SUMMARY_LINES+=("$(printf '%-20s : %-4s %s' "${label}" "${status}" "${details}")")
}

run_with_log() {
    local log_path="$1"
    shift

    mkdir -p "${PIPELINE_LOG_DIR}"
    "$@" 2>&1 | tee "${log_path}"
    return "${PIPESTATUS[0]}"
}

stage_enabled() {
    local stage="$1"
    case "${STAGE}" in
        all) return 0 ;;
        quality)
            [[ "${stage}" == "toolchain" || "${stage}" == "deps" || "${stage}" == "format" \
                || "${stage}" == "analyze" || "${stage}" == "tests" ]]
            ;;
        android)
            [[ "${stage}" == "toolchain" || "${stage}" == "deps" || "${stage}" == "compat" \
                || "${stage}" == "android" ]]
            ;;
        linux)
            [[ "${stage}" == "toolchain" || "${stage}" == "deps" || "${stage}" == "linux" ]]
            ;;
        *) return 1 ;;
    esac
}

verify_toolchain() {
    if ! command -v flutter >/dev/null 2>&1; then
        TOOLCHAIN_DETAILS="flutter not found on PATH"
        return 1
    fi

    local version
    version="$(flutter --version 2>/dev/null | grep -oE 'Flutter [0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | awk '{print $2}')"
    if [[ -z "${version}" ]]; then
        TOOLCHAIN_DETAILS="could not determine the Flutter version"
        return 1
    fi

    TOOLCHAIN_DETAILS="Flutter ${version}"
    if [[ "${version}" != "${PINNED_FLUTTER_VERSION}" ]]; then
        # Not fatal locally: the pinned version is what CI and releases use, but
        # a developer may legitimately be testing an upgrade (Vision.md §72).
        warn "Flutter ${version} differs from the pinned ${PINNED_FLUTTER_VERSION}"
        TOOLCHAIN_DETAILS="Flutter ${version} (pinned: ${PINNED_FLUTTER_VERSION})"
    fi
    return 0
}

fetch_dependencies() {
    run_with_log "${PIPELINE_LOG_DIR}/pub-get.log" flutter pub get >/dev/null
}

check_formatting() {
    run_with_log "${PIPELINE_LOG_DIR}/format.log" \
        dart format --output=none --set-exit-if-changed . >/dev/null
}

run_analyzer() {
    local log_path="${PIPELINE_LOG_DIR}/analyze.log"
    if run_with_log "${log_path}" flutter analyze >/dev/null; then
        ANALYZE_DETAILS="No issues found"
        return 0
    fi
    ANALYZE_DETAILS="$(grep -cE '^\s+(info|warning|error) •' "${log_path}" 2>/dev/null || echo '?') issue(s)"
    return 1
}

run_tests() {
    local log_path="${PIPELINE_LOG_DIR}/test.log"
    local status=0
    run_with_log "${log_path}" flutter test >/dev/null || status=1

    local summary
    summary="$(grep -oE '\+[0-9]+(\s+-[0-9]+)?: (All tests passed|Some tests failed)' "${log_path}" | tail -n 1 || true)"
    if [[ -n "${summary}" ]]; then
        TESTS_DETAILS="${summary}"
    else
        TESTS_DETAILS="see flutter test output"
    fi
    return "${status}"
}

# Vision.md §58: Android 10 support is a product requirement, so it is asserted
# mechanically rather than trusted to review.
assert_android_compatibility() {
    if [[ ! -f "${GRADLE_FILE}" ]]; then
        error "${GRADLE_FILE} is missing"
        return 1
    fi
    if grep -qE "^[[:space:]]*minSdk[[:space:]]*=[[:space:]]*${REQUIRED_MIN_SDK}[[:space:]]*(//.*)?$" "${GRADLE_FILE}"; then
        return 0
    fi
    error "minSdk must stay ${REQUIRED_MIN_SDK} (Android 10) — see Vision.md §4.1 and §58"
    grep -nE 'minSdk' "${GRADLE_FILE}" >&2 || true
    return 1
}

build_linux() {
    local log_path="${PIPELINE_LOG_DIR}/build-linux.log"
    if ! run_with_log "${log_path}" flutter build linux --release >/dev/null; then
        BUILD_LINUX_DETAILS="build failed"
        return 1
    fi
    local bundle="build/linux/x64/release/bundle"
    if [[ ! -x "${bundle}/dividendendackel" ]]; then
        BUILD_LINUX_DETAILS="executable missing from ${bundle}"
        return 1
    fi
    BUILD_LINUX_DETAILS="$(du -sh "${bundle}" 2>/dev/null | awk '{print $1}') bundle"
    return 0
}

build_android() {
    local log_path="${PIPELINE_LOG_DIR}/build-android.log"
    if ! run_with_log "${log_path}" flutter build apk --release >/dev/null; then
        BUILD_ANDROID_DETAILS="build failed"
        return 1
    fi
    local apk="build/app/outputs/flutter-apk/app-release.apk"
    if [[ ! -f "${apk}" ]]; then
        BUILD_ANDROID_DETAILS="APK missing from ${apk}"
        return 1
    fi
    BUILD_ANDROID_DETAILS="$(du -h "${apk}" 2>/dev/null | awk '{print $1}') APK"
    return 0
}

# Smoke test: start the freshly built Linux bundle and confirm it stays up.
# Requires a display, so CI and headless machines pass --noRun.
smoke_test_linux_app() {
    local bundle="build/linux/x64/release/bundle/dividendendackel"
    if [[ ! -x "${bundle}" ]]; then
        return 1
    fi
    if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
        return 2
    fi

    "${bundle}" >/dev/null 2>&1 &
    local pid=$!
    sleep 5
    if kill -0 "${pid}" 2>/dev/null; then
        kill "${pid}" 2>/dev/null
        wait "${pid}" 2>/dev/null
        return 0
    fi
    return 1
}

print_summary() {
    printf '\n===== localPipeline.sh summary =====\n'
    local line
    for line in "${SUMMARY_LINES[@]}"; do
        printf '%s\n' "${line}"
    done
    printf '====================================\n'
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --noRun)
                RUN_APP=0
                shift
                ;;
            --stage)
                if [[ $# -lt 2 ]]; then
                    error "--stage requires a value"
                    print_usage >&2
                    exit 2
                fi
                STAGE="$2"
                shift 2
                ;;
            --help | -h)
                print_usage
                exit 0
                ;;
            *)
                error "Unknown argument: $1"
                print_usage >&2
                exit 2
                ;;
        esac
    done

    case "${STAGE}" in
        all | quality | android | linux) ;;
        *)
            error "Unknown stage: ${STAGE}"
            print_usage >&2
            exit 2
            ;;
    esac
}

main() {
    parse_arguments "$@"
    cd "${ROOT_DIR}" || exit 1

    log "Running local pipeline (stage: ${STAGE}, run app: ${RUN_APP})"

    if verify_toolchain; then
        TOOLCHAIN_OK=1
        mark_result "Toolchain" "PASS" "${TOOLCHAIN_DETAILS}"
    else
        mark_result "Toolchain" "FAIL" "${TOOLCHAIN_DETAILS}"
        print_summary
        error "localPipeline.sh cannot continue without a working toolchain"
        exit 1
    fi

    if fetch_dependencies; then
        DEPS_OK=1
        mark_result "Dependencies" "PASS" "flutter pub get"
    else
        mark_result "Dependencies" "FAIL" "flutter pub get failed"
        print_summary
        error "localPipeline.sh cannot continue without dependencies"
        exit 1
    fi

    if stage_enabled format; then
        if check_formatting; then
            FORMAT_OK=1
            mark_result "Format" "PASS" "dart format is clean"
        else
            mark_result "Format" "FAIL" "run: dart format ."
        fi
    else
        FORMAT_OK=1
        mark_result "Format" "SKIP" "Not part of stage ${STAGE}"
    fi

    if stage_enabled analyze; then
        if run_analyzer; then
            ANALYZE_OK=1
            mark_result "Analyze" "PASS" "${ANALYZE_DETAILS}"
        else
            mark_result "Analyze" "FAIL" "${ANALYZE_DETAILS}"
        fi
    else
        ANALYZE_OK=1
        mark_result "Analyze" "SKIP" "Not part of stage ${STAGE}"
    fi

    if stage_enabled tests; then
        if run_tests; then
            TESTS_OK=1
            mark_result "Tests" "PASS" "${TESTS_DETAILS}"
        else
            mark_result "Tests" "FAIL" "${TESTS_DETAILS}"
        fi
    else
        TESTS_OK=1
        mark_result "Tests" "SKIP" "Not part of stage ${STAGE}"
    fi

    if stage_enabled compat; then
        if assert_android_compatibility; then
            ANDROID_COMPAT_OK=1
            mark_result "Android 10 compat" "PASS" "minSdk ${REQUIRED_MIN_SDK}"
        else
            mark_result "Android 10 compat" "FAIL" "minSdk changed"
        fi
    else
        ANDROID_COMPAT_OK=1
        mark_result "Android 10 compat" "SKIP" "Not part of stage ${STAGE}"
    fi

    if stage_enabled linux; then
        if build_linux; then
            BUILD_LINUX_OK=1
            mark_result "Build Linux" "PASS" "${BUILD_LINUX_DETAILS}"
        else
            mark_result "Build Linux" "FAIL" "${BUILD_LINUX_DETAILS}"
        fi
    else
        BUILD_LINUX_OK=1
        mark_result "Build Linux" "SKIP" "Not part of stage ${STAGE}"
    fi

    if stage_enabled android; then
        if [[ "${ANDROID_COMPAT_OK}" -eq 1 ]]; then
            if build_android; then
                BUILD_ANDROID_OK=1
                mark_result "Build Android" "PASS" "${BUILD_ANDROID_DETAILS}"
            else
                mark_result "Build Android" "FAIL" "${BUILD_ANDROID_DETAILS}"
            fi
        else
            mark_result "Build Android" "SKIP" "Skipped because the compatibility check failed"
        fi
    else
        BUILD_ANDROID_OK=1
        mark_result "Build Android" "SKIP" "Not part of stage ${STAGE}"
    fi

    if [[ "${RUN_APP}" -eq 1 ]]; then
        if [[ "${BUILD_LINUX_OK}" -eq 1 ]]; then
            smoke_test_linux_app
            case $? in
                0) mark_result "App smoke test" "PASS" "Linux bundle stayed up for 5s" ;;
                2) mark_result "App smoke test" "SKIP" "No display available" ;;
                *) mark_result "App smoke test" "FAIL" "Linux bundle exited early" ;;
            esac
        else
            mark_result "App smoke test" "SKIP" "Skipped because the Linux build failed"
        fi
    else
        mark_result "App smoke test" "SKIP" "Disabled with --noRun"
    fi

    local exit_code=1
    if [[ "${TOOLCHAIN_OK}" -eq 1 && "${DEPS_OK}" -eq 1 && "${FORMAT_OK}" -eq 1 \
        && "${ANALYZE_OK}" -eq 1 && "${TESTS_OK}" -eq 1 && "${ANDROID_COMPAT_OK}" -eq 1 \
        && "${BUILD_LINUX_OK}" -eq 1 && "${BUILD_ANDROID_OK}" -eq 1 ]]; then
        exit_code=0
    fi

    if [[ "${exit_code}" -eq 0 ]]; then
        log "localPipeline.sh completed successfully"
    else
        error "localPipeline.sh completed with failing mandatory stage(s)"
    fi
    print_summary
    exit "${exit_code}"
}

main "$@"
