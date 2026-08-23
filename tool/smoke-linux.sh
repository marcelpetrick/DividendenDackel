#!/usr/bin/env bash
# Launches a built Linux bundle and requires Flutter's first-frame signal.
set -u
set -o pipefail

readonly EXECUTABLE="${1:-build/linux/x64/release/bundle/dividendendackel}"
readonly TIMEOUT_SECONDS="${SMOKE_TIMEOUT_SECONDS:-20}"
SMOKE_LOG_DIR="$(mktemp -d)"
readonly SMOKE_LOG_DIR
readonly SMOKE_LOG="${SMOKE_LOG_DIR}/application.log"
APP_PID=""

# Invoked indirectly by the EXIT trap below.
# shellcheck disable=SC2329
cleanup() {
    if [[ -n "${APP_PID}" ]] && kill -0 "${APP_PID}" 2>/dev/null; then
        kill -TERM -- "-${APP_PID}" 2>/dev/null || kill "${APP_PID}" 2>/dev/null || true
        wait "${APP_PID}" 2>/dev/null || true
    fi
    rm -rf "${SMOKE_LOG_DIR}"
}
trap cleanup EXIT

if [[ ! -x "${EXECUTABLE}" ]]; then
    printf 'Smoke-test executable is missing or not executable: %s\n' "${EXECUTABLE}" >&2
    exit 1
fi
if ! [[ "${TIMEOUT_SECONDS}" =~ ^[1-9][0-9]*$ ]]; then
    printf 'SMOKE_TIMEOUT_SECONDS must be a positive integer.\n' >&2
    exit 2
fi
if ! command -v setsid >/dev/null 2>&1; then
    printf 'setsid is required to contain the smoke-test process group.\n' >&2
    exit 1
fi

if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
    setsid "${EXECUTABLE}" >"${SMOKE_LOG}" 2>&1 &
elif command -v xvfb-run >/dev/null 2>&1; then
    setsid xvfb-run -a "${EXECUTABLE}" >"${SMOKE_LOG}" 2>&1 &
else
    printf 'Linux release smoke test needs a display or xvfb-run.\n' >&2
    exit 1
fi
APP_PID=$!

readonly DEADLINE=$((SECONDS + TIMEOUT_SECONDS))
while ((SECONDS < DEADLINE)); do
    if grep -q '^DIVIDENDENDACKEL_FIRST_FRAME$' "${SMOKE_LOG}"; then
        printf 'Linux release rendered its first Flutter frame.\n'
        exit 0
    fi
    if ! kill -0 "${APP_PID}" 2>/dev/null; then
        printf 'Linux release exited before rendering its first frame.\n' >&2
        cat "${SMOKE_LOG}" >&2
        exit 1
    fi
    sleep 0.1
done

printf 'Linux release did not render a first frame within %ss.\n' "${TIMEOUT_SECONDS}" >&2
cat "${SMOKE_LOG}" >&2
exit 1
