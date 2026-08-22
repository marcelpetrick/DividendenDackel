#!/usr/bin/env bash
#
# Generates release notes from Conventional Commits (Vision.md §64, §75).
#
# Usage: ./tool/release-notes.sh <version> [previous-tag]
#
# Without a previous tag, the range starts at the repository root, which is
# what the first release needs.
set -euo pipefail

VERSION="${1:?usage: release-notes.sh <version> [previous-tag]}"
PREVIOUS_TAG="${2:-}"

if [[ -n "${PREVIOUS_TAG}" ]]; then
    RANGE="${PREVIOUS_TAG}..HEAD"
    COMPARED="Changes since \`${PREVIOUS_TAG}\`."
else
    RANGE="HEAD"
    COMPARED="First release."
fi

# Collects commit subjects for one Conventional Commit type.
section() {
    local type="$1"
    local heading="$2"
    local body

    body="$(git log --no-merges --pretty=format:'%s' "${RANGE}" \
        | grep -E "^${type}(\([^)]+\))?!?: " \
        | sed -E "s/^${type}\(([^)]+)\)!?: /- **\1**: /; s/^${type}!?: /- /" \
        || true)"

    if [[ -n "${body}" ]]; then
        printf '### %s\n\n%s\n\n' "${heading}" "${body}"
    fi
}

printf '## DividendenDackel %s\n\n%s\n\n' "${VERSION}" "${COMPARED}"

section feat "Features"
section fix "Fixes"
section perf "Performance"
section refactor "Internal changes"
section build "Build and dependencies"
section ci "Continuous integration"
section docs "Documentation"
section test "Tests"

# Breaking changes are called out separately per the Conventional Commits spec.
BREAKING="$(git log --no-merges --pretty=format:'%H' "${RANGE}" | while read -r sha; do
    if git show -s --format='%s%n%b' "${sha}" | grep -qE '^BREAKING CHANGE:|^[a-z]+(\([^)]+\))?!:'; then
        git show -s --format='- %s' "${sha}"
    fi
done || true)"

if [[ -n "${BREAKING}" ]]; then
    printf '### Breaking changes\n\n%s\n\n' "${BREAKING}"
fi

cat <<'FOOTER'
### Artifacts

| File | Platform |
| --- | --- |
| `dividendendackel-<version>-android.apk` | Android 10 (API 29) and newer |
| `dividendendackel-<version>-linux-x86_64.tar.gz` | Linux x86_64 desktop |
| `SHA256SUMS` | Checksums for both artifacts |

The APK is unsigned beyond a debug key, so Android will warn on install from
an unknown source. Verify the download against `SHA256SUMS` before installing.

### Data sources

Works out of the box with no API key: SEC EDGAR (dividend history, filings)
and Frankfurter/ECB (foreign-exchange rates), with a bundled sample dataset
filling the gaps. See `docs/data-providers.md`.
FOOTER
