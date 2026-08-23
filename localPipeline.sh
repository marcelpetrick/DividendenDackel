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
readonly PINNED_FLUTTER_VERSION="3.47.1"
# The JDK that *runs* Gradle and Android Lint. Distinct from the project's
# sourceCompatibility, which is the bytecode target and stays at 17.
# Android Lint is compiled against Java 21 APIs (java.util.List.removeLast),
# so running it on 17 crashes with NoSuchMethodError. Keep in step with
# .github/workflows/ci.yml and release.yml.
readonly REQUIRED_JAVA_MAJOR="21"
readonly REQUIRED_MIN_SDK="29"
readonly GRADLE_FILE="android/app/build.gradle.kts"
readonly ANDROID_MANIFEST="android/app/src/main/AndroidManifest.xml"
readonly APP_COMMIT="${APP_COMMIT:-development build}"

declare -a SUMMARY_LINES=()

RUN_APP=1
STAGE="all"

TOOLCHAIN_OK=0
DEPS_OK=0
FORMAT_OK=0
ANALYZE_OK=0
TESTS_OK=0
INTEGRATION_OK=0
VERSION_OK=0
ANDROID_COMPAT_OK=0
BUILD_LINUX_OK=0
BUILD_ANDROID_OK=0

TOOLCHAIN_DETAILS=""
TESTS_DETAILS=""
INTEGRATION_DETAILS=""
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
  6. Run the real Linux desktop integration journey
  7. Assert Android 10 compatibility (minSdk stays ${REQUIRED_MIN_SDK})
  8. Build the Linux x86_64 release bundle
  9. Build the Android release APK
 10. Launch the Linux app briefly as a smoke test (skipped with --noRun)
 11. Print a final stage-by-stage summary

Options:
  --noRun          Skip rendered-release verification. Headless CI installs
                   Xvfb and leaves this enabled for Linux/release jobs.
  --selfTest       Verify that the pipeline reports failing commands as failures,
                   then exit.
  --stage <name>   Run a subset of stages. One of:
                     all       every stage (default)
                     quality   toolchain, deps, format, analyze, tests
                     integration  toolchain, deps, Linux integration journey
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

# Runs a command quietly, but dumps its full output when it fails.
#
# A pipeline that hides why a stage failed is useless in CI, where the log is
# the only evidence available.
run_with_log() {
    local log_path="$1"
    shift

    mkdir -p "${PIPELINE_LOG_DIR}"

    # Capture the status immediately. Reading $? after an `if` block yields the
    # status of the compound statement (0 when no branch ran), not the command's
    # — a mistake that silently turned failing stages into passes.
    local status=0
    "$@" >"${log_path}" 2>&1 || status=$?

    if [[ "${status}" -eq 0 ]]; then
        return 0
    fi

    error "Command failed (exit ${status}): $*"
    printf -- '--- begin output of: %s ---\n' "$*" >&2
    cat "${log_path}" >&2
    printf -- '--- end output ---\n' >&2
    return "${status}"
}

stage_enabled() {
    local stage="$1"
    case "${STAGE}" in
        all) return 0 ;;
        quality)
            [[ "${stage}" == "toolchain" || "${stage}" == "deps" || "${stage}" == "format" \
                || "${stage}" == "analyze" || "${stage}" == "tests" ]]
            ;;
        integration)
            [[ "${stage}" == "toolchain" || "${stage}" == "deps" \
                || "${stage}" == "integration" ]]
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

    # The JDK matters as much as the Flutter version. A local build on 21 that
    # passes while CI runs 17 is exactly how a green local gate shipped a
    # broken release, so the mismatch is reported here rather than discovered
    # eight minutes into a CI run.
    local java_major=""
    if command -v java >/dev/null 2>&1; then
        java_major="$(java -version 2>&1 | grep -oE '(openjdk|java) version "[0-9]+' | grep -oE '[0-9]+$' | head -n 1)"
    fi
    if [[ -z "${java_major}" ]]; then
        warn "could not determine the Java version; Android builds need JDK ${REQUIRED_JAVA_MAJOR}"
        TOOLCHAIN_DETAILS="${TOOLCHAIN_DETAILS}, Java unknown"
    elif [[ "${java_major}" != "${REQUIRED_JAVA_MAJOR}" ]]; then
        warn "Java ${java_major} differs from the required ${REQUIRED_JAVA_MAJOR}; Android Lint needs ${REQUIRED_JAVA_MAJOR}"
        TOOLCHAIN_DETAILS="${TOOLCHAIN_DETAILS}, Java ${java_major} (required: ${REQUIRED_JAVA_MAJOR})"
    else
        TOOLCHAIN_DETAILS="${TOOLCHAIN_DETAILS}, Java ${java_major}"
    fi
    return 0
}

fetch_dependencies() {
    run_with_log "${PIPELINE_LOG_DIR}/pub-get.log" flutter pub get
}

check_formatting() {
    run_with_log "${PIPELINE_LOG_DIR}/format.log" \
        dart format --output=none --set-exit-if-changed .
}

run_analyzer() {
    local log_path="${PIPELINE_LOG_DIR}/analyze.log"
    if run_with_log "${log_path}" flutter analyze; then
        ANALYZE_DETAILS="No issues found"
        return 0
    fi
    ANALYZE_DETAILS="$(grep -cE '^\s+(info|warning|error) •' "${log_path}" 2>/dev/null || echo '?') issue(s)"
    return 1
}

run_tests() {
    local log_path="${PIPELINE_LOG_DIR}/test.log"
    local status=0
    run_with_log "${log_path}" flutter test || status=1

    local summary
    summary="$(grep -oE '(All tests passed|Some tests failed)' "${log_path}" | tail -n 1 || true)"
    local counts
    counts="$(grep -oE '\+[0-9]+( -[0-9]+)?' "${log_path}" | tail -n 1 || true)"
    if [[ -n "${summary}" ]]; then
        TESTS_DETAILS="${counts:+${counts} }${summary}"
    else
        TESTS_DETAILS="see flutter test output above"
    fi
    return "${status}"
}

run_integration_tests() {
    local log_path="${PIPELINE_LOG_DIR}/integration-test.log"
    local -a command=(flutter test integration_test/portfolio_journey_test.dart -d linux)
    local status=0

    # Prefer a virtual display even when a real one exists. A desktop
    # compositor throttles frame callbacks for a window that is unfocused or
    # occluded, and the Flutter test binding then waits for frames that never
    # arrive, so pumpAndSettle times out with nothing wrong in the app. Under
    # xvfb the window is always "visible", which is also what CI does — so the
    # local run and CI agree.
    if command -v xvfb-run >/dev/null 2>&1; then
        run_with_log "${log_path}" xvfb-run -a "${command[@]}" || status=1
    elif [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
        warn "xvfb-run not found; using the real display, which can time out if the window loses focus"
        run_with_log "${log_path}" "${command[@]}" || status=1
    else
        error "Linux integration tests need xvfb-run or a display"
        INTEGRATION_DETAILS="no display; install xvfb (Debian: xvfb, Arch: xorg-server-xvfb)"
        return 1
    fi

    if [[ "${status}" -eq 0 ]]; then
        INTEGRATION_DETAILS="portfolio journey passed on Linux"
    else
        INTEGRATION_DETAILS="Linux portfolio journey failed"
    fi
    return "${status}"
}

# Checks that every commit this branch adds moved the version one step, per
# docs/releases.md. Mechanical, because as a convention it drifted.
check_version_scheme() {
    if [[ ! -x "${ROOT_DIR}/tool/check-version.sh" ]]; then
        return 0
    fi
    "${ROOT_DIR}/tool/check-version.sh" origin/master HEAD
}

# Vision.md §58: Android 10 support is a product requirement, so it is asserted
# mechanically rather than trusted to review.
assert_android_compatibility() {
    if [[ ! -f "${GRADLE_FILE}" ]]; then
        error "${GRADLE_FILE} is missing"
        return 1
    fi
    if grep -qE "^[[:space:]]*minSdk[[:space:]]*=[[:space:]]*${REQUIRED_MIN_SDK}[[:space:]]*(//.*)?$" "${GRADLE_FILE}"; then
        if [[ ! -f "${ANDROID_MANIFEST}" ]]; then
            error "${ANDROID_MANIFEST} is missing"
            return 1
        fi
        if ! grep -q 'android.permission.INTERNET' "${ANDROID_MANIFEST}"; then
            error "Release manifest must grant INTERNET for live data providers"
            return 1
        fi
        return 0
    fi
    error "minSdk must stay ${REQUIRED_MIN_SDK} (Android 10) — see Vision.md §4.1 and §58"
    grep -nE 'minSdk' "${GRADLE_FILE}" >&2 || true
    return 1
}

build_linux() {
    local log_path="${PIPELINE_LOG_DIR}/build-linux.log"
    if ! run_with_log "${log_path}" flutter build linux --release \
        --dart-define="APP_COMMIT=${APP_COMMIT}"; then
        BUILD_LINUX_DETAILS="build failed"
        return 1
    fi
    local bundle="build/linux/x64/release/bundle"
    if [[ ! -x "${bundle}/dividendendackel" ]]; then
        BUILD_LINUX_DETAILS="executable missing from ${bundle}"
        return 1
    fi
    local bytes
    bytes="$(du -sb "${bundle}" 2>/dev/null | awk '{print $1}')"
    BUILD_LINUX_DETAILS="$(du -sh "${bundle}" 2>/dev/null | awk '{print $1}') bundle (${bytes} bytes)"
    return 0
}

build_android() {
    local log_path="${PIPELINE_LOG_DIR}/build-android.log"
    if ! run_with_log "${log_path}" flutter build apk --release \
        --dart-define="APP_COMMIT=${APP_COMMIT}"; then
        BUILD_ANDROID_DETAILS="build failed"
        return 1
    fi
    local apk="build/app/outputs/flutter-apk/app-release.apk"
    if [[ ! -f "${apk}" ]]; then
        BUILD_ANDROID_DETAILS="APK missing from ${apk}"
        return 1
    fi
    if ! unzip -tq "${apk}" >/dev/null 2>&1; then
        BUILD_ANDROID_DETAILS="APK archive verification failed"
        return 1
    fi
    local bytes
    bytes="$(stat -c '%s' "${apk}")"
    BUILD_ANDROID_DETAILS="$(du -h "${apk}" 2>/dev/null | awk '{print $1}') APK (${bytes} bytes)"
    return 0
}

# Smoke test: require the freshly built release to deliver its first frame.
smoke_test_linux_app() {
    local bundle="build/linux/x64/release/bundle/dividendendackel"
    run_with_log "${PIPELINE_LOG_DIR}/smoke-linux.log" \
        ./tool/smoke-linux.sh "${bundle}"
}

# Verifies that the pipeline's own plumbing reports failure as failure.
#
# A quality gate that turns a failing command into PASS is worse than no gate,
# so the property is asserted rather than assumed.
run_self_test() {
    local failures=0

    if run_with_log "${PIPELINE_LOG_DIR}/selftest-pass.log" true >/dev/null 2>&1; then
        log "self-test: a succeeding command reports success"
    else
        error "self-test: a succeeding command was reported as failing"
        failures=$((failures + 1))
    fi

    if run_with_log "${PIPELINE_LOG_DIR}/selftest-fail.log" false >/dev/null 2>&1; then
        error "self-test: a failing command was reported as succeeding"
        failures=$((failures + 1))
    else
        log "self-test: a failing command reports failure"
    fi

    if [[ "${failures}" -eq 0 ]]; then
        log "self-test passed"
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
            --selfTest)
                mkdir -p "${PIPELINE_LOG_DIR}"
                run_self_test
                exit $?
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
        all | quality | integration | android | linux) ;;
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

    mkdir -p "${PIPELINE_LOG_DIR}"
    if ! run_self_test; then
        error "localPipeline.sh cannot be trusted; aborting"
        exit 1
    fi

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

    if stage_enabled integration; then
        if run_integration_tests; then
            INTEGRATION_OK=1
            mark_result "Integration Linux" "PASS" "${INTEGRATION_DETAILS}"
        else
            mark_result "Integration Linux" "FAIL" "${INTEGRATION_DETAILS}"
        fi
    else
        INTEGRATION_OK=1
        mark_result "Integration Linux" "SKIP" "Not part of stage ${STAGE}"
    fi

    if stage_enabled format; then
        if run_with_log "${PIPELINE_LOG_DIR}/version.log" check_version_scheme; then
            VERSION_OK=1
            mark_result "Version scheme" "PASS" "each commit bumps once"
        else
            mark_result "Version scheme" "FAIL" "see ./tool/check-version.sh"
        fi
    else
        VERSION_OK=1
        mark_result "Version scheme" "SKIP" "Not part of stage ${STAGE}"
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

    if [[ "${RUN_APP}" -eq 1 ]] && stage_enabled linux; then
        if [[ "${BUILD_LINUX_OK}" -eq 1 ]]; then
            if smoke_test_linux_app; then
                mark_result "App smoke test" "PASS" "Release rendered first frame"
            else
                mark_result "App smoke test" "FAIL" "Release did not render"
                BUILD_LINUX_OK=0
            fi
        else
            mark_result "App smoke test" "SKIP" "Skipped because the Linux build failed"
        fi
    elif [[ "${RUN_APP}" -eq 0 ]]; then
        mark_result "App smoke test" "SKIP" "Disabled with --noRun"
    else
        mark_result "App smoke test" "SKIP" "Not part of stage ${STAGE}"
    fi

    local exit_code=1
    if [[ "${TOOLCHAIN_OK}" -eq 1 && "${DEPS_OK}" -eq 1 && "${FORMAT_OK}" -eq 1 \
        && "${ANALYZE_OK}" -eq 1 && "${TESTS_OK}" -eq 1 && "${INTEGRATION_OK}" -eq 1 \
        && "${ANDROID_COMPAT_OK}" -eq 1 \
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
