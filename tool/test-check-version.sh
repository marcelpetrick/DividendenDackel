#!/usr/bin/env bash
#
# Self-test for tool/check-version.sh.
#
# The version scheme is a build gate, so the gate itself needs evidence. Each
# case builds a throwaway repository, commits into it and asserts the exit
# status and the reason the checker printed.
#
# Usage: ./tool/test-check-version.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECKER="${ROOT_DIR}/tool/check-version.sh"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

passed=0
failed=0

# Starts an empty repository with one commit carrying `version:` and echoes it.
new_repo() {
    local repo="${WORK_DIR}/repo-${RANDOM}${RANDOM}"
    mkdir -p "${repo}"
    git -C "${repo}" init --quiet --initial-branch=master
    git -C "${repo}" config user.email 'test@example.invalid'
    git -C "${repo}" config user.name 'Test Author'
    printf 'version: 1.2.3+7\n' >"${repo}/pubspec.yaml"
    git -C "${repo}" add pubspec.yaml
    git -C "${repo}" commit --quiet -m 'chore: base'
    printf '%s' "${repo}"
}

# commit <repo> <subject> [author-name] -- then the files to touch.
commit_touching() {
    local repo="$1" subject="$2" author="$3"
    shift 3
    local path
    for path in "$@"; do
        mkdir -p "${repo}/$(dirname "${path}")"
        printf 'changed %s\n' "${RANDOM}" >>"${repo}/${path}"
        git -C "${repo}" add "${path}"
    done
    git -C "${repo}" commit --quiet --author "${author} <bot@example.invalid>" -m "${subject}"
}

set_version() {
    printf 'version: %s\n' "$2" >"$1/pubspec.yaml"
    git -C "$1" add pubspec.yaml
}

# expect <description> <expected-exit> <expected-substring> <repo>
expect() {
    local description="$1" expected_status="$2" expected_text="$3" repo="$4"
    local output status=0
    output="$(cd "${repo}" && "${CHECKER}" master~1 master 2>&1)" || status=$?
    if [[ "${status}" -eq "${expected_status}" && "${output}" == *"${expected_text}"* ]]; then
        echo "[PASS] ${description}"
        passed=$((passed + 1))
    else
        echo "[FAIL] ${description}"
        echo "         expected exit ${expected_status} containing '${expected_text}'"
        echo "         got exit ${status}:"
        printf '%s\n' "${output}" | sed 's/^/           /'
        failed=$((failed + 1))
    fi
}

# A documentation-only commit may leave the version alone: it cannot change the
# built artifact, and the GitHub web UI cannot run the bump script.
repo="$(new_repo)"
commit_touching "${repo}" 'Update README.md' 'Test Author' README.md
expect 'documentation-only commit needs no bump' 0 '[SKIP]' "${repo}"

repo="$(new_repo)"
commit_touching "${repo}" 'docs: describe the gate' 'Test Author' docs/releases.md .github/workflows/ci.yml
expect 'docs and workflow paths are non-shipping' 0 '[SKIP]' "${repo}"

# A bot cannot bump the version in the branch it opens.
repo="$(new_repo)"
commit_touching "${repo}" 'build(deps): bump a dependency' 'dependabot[bot]' pubspec.lock
expect 'bot-authored commit needs no bump' 0 'authored by a bot' "${repo}"

# The exemption is a floor, not a licence.
repo="$(new_repo)"
set_version "${repo}" '9.9.9+99'
commit_touching "${repo}" 'Update README.md' 'Test Author' README.md
expect 'documentation commit that moves the version is still checked' 1 '[FAIL]' "${repo}"

# Everything that reaches the build still has to step exactly once.
repo="$(new_repo)"
commit_touching "${repo}" 'fix: correct a rounding error' 'Test Author' lib/main.dart
expect 'source commit without a bump fails' 1 'expected 1.2.4+8' "${repo}"

repo="$(new_repo)"
set_version "${repo}" '1.2.4+8'
commit_touching "${repo}" 'fix: correct a rounding error' 'Test Author' lib/main.dart
expect 'patch bump on a fix passes' 0 'Version scheme holds' "${repo}"

repo="$(new_repo)"
set_version "${repo}" '1.3.0+8'
commit_touching "${repo}" 'feat: add a forecast' 'Test Author' lib/main.dart
expect 'minor bump on a feature passes' 0 'Version scheme holds' "${repo}"

repo="$(new_repo)"
set_version "${repo}" '1.2.4+8'
commit_touching "${repo}" 'feat: add a forecast' 'Test Author' lib/main.dart
expect 'feature with only a patch bump fails' 1 'expected 1.3.0+8' "${repo}"

repo="$(new_repo)"
set_version "${repo}" '1.3.0+8'
commit_touching "${repo}" 'refactor!: drop the legacy store' 'Test Author' lib/main.dart
expect 'breaking marker moves the minor' 0 'Version scheme holds' "${repo}"

echo
if [[ "${failed}" -gt 0 ]]; then
    echo "[ERROR] ${failed} of $((passed + failed)) version-scheme cases failed."
    exit 1
fi
echo "[INFO] All ${passed} version-scheme cases passed."
