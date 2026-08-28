#!/usr/bin/env bash
#
# Self-test for tool/check-changelog.sh.
#
# The check is what stops a release shipping without notes, so a version of it
# that passes everything would be worse than none at all.
#
# Usage: ./tool/test-check-changelog.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

passed=0
failed=0

# Builds a throwaway project whose CHANGELOG.md holds $2 and echoes its path.
new_project() {
    local dir="${WORK_DIR}/p-${RANDOM}${RANDOM}"
    mkdir -p "${dir}/tool"
    cp "${ROOT_DIR}/tool/check-changelog.sh" "${dir}/tool/"
    printf 'version: %s\n' "$1" >"${dir}/pubspec.yaml"
    printf '%s\n' "$2" >"${dir}/CHANGELOG.md"
    printf '%s' "${dir}"
}

expect() {
    local description="$1" expected="$2" dir="$3"
    shift 3
    local output status=0
    output="$("${dir}/tool/check-changelog.sh" "$@" 2>&1)" || status=$?
    if [[ "${status}" -eq "${expected}" ]]; then
        echo "[PASS] ${description}"
        passed=$((passed + 1))
    else
        echo "[FAIL] ${description} (wanted exit ${expected}, got ${status})"
        printf '%s\n' "${output}" | sed 's/^/         /'
        failed=$((failed + 1))
    fi
}

documented='# Changelog

## [Unreleased]

### Added

- Something pending.

## [1.2.3] - 2026-08-28

### Added

- A documented change.
'

expect 'a dated section with entries passes' 0 "$(new_project '1.2.3+7' "${documented}")"
expect 'an explicit version argument is honoured' 0 \
    "$(new_project '9.9.9+1' "${documented}")" '1.2.3'
expect 'a version with no section fails' 1 "$(new_project '2.0.0+9' "${documented}")"

undated='# Changelog

## [1.2.3]

### Added

- Still pending, with no release date.
'
# An undated heading is pending work. Releasing against it would publish notes
# that never claimed to describe a build.
expect 'an undated section is not a release' 1 "$(new_project '1.2.3+7' "${undated}")"

empty='# Changelog

## [1.2.3] - 2026-08-28

### Added
'
expect 'a section with no entries fails' 1 "$(new_project '1.2.3+7' "${empty}")"

# The next release must not be able to borrow the previous one's entries.
borrowed='# Changelog

## [2.0.0] - 2026-08-28

## [1.2.3] - 2026-08-01

### Added

- An older change.
'
expect 'entries under a later section do not count' 1 \
    "$(new_project '2.0.0+9' "${borrowed}")"

# A dot in a version must not act as a regular-expression wildcard.
expect 'the version is matched literally, not as a pattern' 1 \
    "$(new_project '1x2x3+7' "${documented}")"

echo
if [[ "${failed}" -gt 0 ]]; then
    echo "[ERROR] ${failed} of $((passed + failed)) changelog-gate cases failed."
    exit 1
fi
echo "[INFO] All ${passed} changelog-gate cases passed."
