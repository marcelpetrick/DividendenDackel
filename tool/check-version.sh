#!/usr/bin/env bash
#
# Enforces the project's version scheme (docs/releases.md).
#
# For every commit in a range, the version in pubspec.yaml must move exactly
# one step from its parent:
#   feat, or any commit marked breaking with `!`  -> minor bump, patch reset
#   anything else                                 -> patch bump
# and the build number must increase by exactly one.
#
# The scheme was previously a convention, so it drifted: two feature commits
# shipped under the same version. Checking it mechanically is the difference
# between a rule and a hope.
#
# Two kinds of commit may leave the version where it is, because they cannot
# run ./tool/bump-version.sh at all:
#
#   * commits that touch nothing the application is built from - documentation
#     and repository metadata only. A version identifies a build, and these
#     produce a bit-identical one. Editing README.md in the GitHub web UI is
#     the normal case, and it used to fail the build.
#   * commits authored by a bot, i.e. Dependabot, which has no way to bump the
#     version in the branch it opens.
#
# The exemption is a floor, not a licence: such a commit that *does* move the
# version must still move it correctly, and the next commit steps on from
# whatever its parent carries, so the chain never drifts.
#
# Usage: ./tool/check-version.sh [base-ref] [head-ref]
# Defaults to origin/master..HEAD, i.e. whatever this branch adds.
set -euo pipefail

# Paths that are never compiled, bundled or shipped. Anything outside this set
# is assumed to change the artifact and therefore needs a version.
NON_SHIPPING_PATHS='^(docs/|\.github/|\.idea/|\.claude/|[^/]+\.md$|LICENSE$)'

BASE_REF="${1:-origin/master}"
HEAD_REF="${2:-HEAD}"

version_at() {
    git show "$1:pubspec.yaml" 2>/dev/null | grep -E '^version:' | awk '{print $2}'
}

# True when the commit changes nothing the application is built from.
changes_only_non_shipping_paths() {
    local files
    files="$(git show --pretty=format: --name-only "$1")"
    # A commit that changes nothing at all is not documentation; treat it as
    # shipping so an empty or merge-like commit is never silently waved past.
    [[ -n "$(printf '%s' "${files}" | tr -d '[:space:]')" ]] || return 1
    ! printf '%s\n' "${files}" | grep -vE '^[[:space:]]*$' | grep -qvE "${NON_SHIPPING_PATHS}"
}

# True when the commit was authored by a bot, which cannot bump the version.
authored_by_bot() {
    [[ "$(git log -1 --pretty=%an "$1")" == *'[bot]' ]]
}

# Prints "major minor patch build" for a `X.Y.Z+B` string.
parts_of() {
    printf '%s' "$1" | sed -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$/\1 \2 \3 \4/'
}

if ! git rev-parse --verify --quiet "${BASE_REF}" >/dev/null; then
    echo "[INFO] ${BASE_REF} is unknown here; nothing to check."
    exit 0
fi

commits="$(git rev-list --reverse --no-merges "${BASE_REF}..${HEAD_REF}")"
if [[ -z "${commits}" ]]; then
    echo "[INFO] No new commits between ${BASE_REF} and ${HEAD_REF}; nothing to check."
    exit 0
fi

failures=0
checked=0
exempted=0

for sha in ${commits}; do
    subject="$(git log -1 --pretty=%s "${sha}")"
    parent="$(git rev-parse "${sha}^")"

    current="$(version_at "${sha}")"
    previous="$(version_at "${parent}")"
    short="$(git rev-parse --short "${sha}")"

    if [[ -z "${current}" || -z "${previous}" ]]; then
        echo "[WARN] ${short}: no version found on this commit or its parent; skipping."
        continue
    fi

    # Commits that cannot bump the version are allowed to leave it alone. One
    # that moved it anyway falls through and is validated like any other.
    if [[ "${current}" == "${previous}" ]]; then
        if changes_only_non_shipping_paths "${sha}"; then
            echo "[SKIP] ${short}: documentation/metadata only; version stays ${current}."
            exempted=$((exempted + 1))
            continue
        fi
        if authored_by_bot "${sha}"; then
            echo "[SKIP] ${short}: authored by a bot; version stays ${current}."
            exempted=$((exempted + 1))
            continue
        fi
    fi

    read -r cmaj cmin cpat cbuild <<<"$(parts_of "${current}")"
    read -r pmaj pmin ppat pbuild <<<"$(parts_of "${previous}")"

    if [[ -z "${cmaj}" || -z "${pmaj}" ]]; then
        echo "[FAIL] ${short}: version is not X.Y.Z+B (found '${current}' after '${previous}')."
        failures=$((failures + 1))
        continue
    fi

    # `feat:` or a `!` breaking marker moves the minor; everything else moves
    # the patch. Pre-1.0 the major stays put, per docs/releases.md.
    if [[ "${subject}" =~ ^[a-z]+(\([^\)]*\))?\! ]] || [[ "${subject}" =~ ^feat(\([^\)]*\))?\!?: ]]; then
        expected_major="${pmaj}"
        expected_minor="$((pmin + 1))"
        expected_patch=0
        kind='feature/breaking -> minor'
    else
        expected_major="${pmaj}"
        expected_minor="${pmin}"
        expected_patch="$((ppat + 1))"
        kind='other -> patch'
    fi
    expected="${expected_major}.${expected_minor}.${expected_patch}+$((pbuild + 1))"

    if [[ "${current}" != "${expected}" ]]; then
        echo "[FAIL] ${short} ${subject}"
        echo "         ${kind}"
        echo "         expected ${expected}, found ${current} (parent ${previous})"
        failures=$((failures + 1))
    fi
    checked=$((checked + 1))
done

if [[ "${failures}" -gt 0 ]]; then
    echo
    echo "[ERROR] ${failures} of ${checked} commit(s) do not follow the version scheme."
    echo "        Fix with: ./tool/bump-version.sh   (see docs/releases.md)"
    exit 1
fi

if [[ "${exempted}" -gt 0 ]]; then
    echo "[INFO] Version scheme holds across ${checked} commit(s); ${exempted} exempt."
else
    echo "[INFO] Version scheme holds across ${checked} commit(s)."
fi
