#!/usr/bin/env bash
#
# Refuses a release whose version has no CHANGELOG.md section.
#
# Five versions were published without one, so everything since 0.1.0 sat under
# [Unreleased] and neither the repository nor the in-app view could say what a
# given build contained. A convention did not hold; a check does.
#
# Usage: ./tool/check-changelog.sh [version]
# Defaults to the version in pubspec.yaml, without its build number.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGELOG="${ROOT_DIR}/CHANGELOG.md"

VERSION="${1:-}"
if [[ -z "${VERSION}" ]]; then
    VERSION="$(grep -E '^version:' "${ROOT_DIR}/pubspec.yaml" | awk '{print $2}')"
    VERSION="${VERSION%%+*}"
fi

if [[ ! -f "${CHANGELOG}" ]]; then
    echo "[FAIL] ${CHANGELOG} is missing."
    exit 1
fi

# The heading must carry a date as well. An undated section is still pending
# work, so releasing against it would publish notes that claim nothing shipped.
heading="$(grep -nE "^## \[${VERSION//./\\.}\][[:space:]]*-[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*$" "${CHANGELOG}" || true)"
if [[ -z "${heading}" ]]; then
    echo "[FAIL] CHANGELOG.md has no dated section for ${VERSION}."
    echo
    echo "        Add one before releasing:"
    echo "          ## [${VERSION}] - $(date -u +%Y-%m-%d)"
    echo
    echo "        Move the entries out of [Unreleased] into it, so the"
    echo "        repository and the app can both say what this build changed."
    exit 1
fi

line="${heading%%:*}"
# Everything until the next release heading belongs to this version.
body="$(awk -v start="${line}" 'NR > start { if ($0 ~ /^## /) exit; print }' "${CHANGELOG}")"
if ! grep -qE '^- ' <<<"${body}"; then
    echo "[FAIL] The ${VERSION} section in CHANGELOG.md has no entries."
    echo "        A release with nothing to say about it is a release nobody"
    echo "        can evaluate."
    exit 1
fi

entries="$(grep -cE '^- ' <<<"${body}")"
echo "[INFO] CHANGELOG.md documents ${VERSION} with ${entries} entr$([[ "${entries}" -eq 1 ]] && echo y || echo ies)."
