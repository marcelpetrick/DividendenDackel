#!/usr/bin/env bash
#
# Applies the next version to pubspec.yaml, following docs/releases.md.
#
# Run before committing. Pass the Conventional Commit type you are about to
# use, or let it read the staged commit message template.
#
# Usage: ./tool/bump-version.sh [feat|fix|docs|...] [--breaking]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="${ROOT_DIR}/pubspec.yaml"

TYPE="${1:-}"
BREAKING=0
for arg in "$@"; do
    [[ "${arg}" == "--breaking" ]] && BREAKING=1
done

if [[ -z "${TYPE}" || "${TYPE}" == "--breaking" ]]; then
    echo "usage: bump-version.sh <feat|fix|docs|test|ci|build|chore|refactor|perf> [--breaking]" >&2
    exit 2
fi

current="$(grep -E '^version:' "${PUBSPEC}" | awk '{print $2}')"
if [[ ! "${current}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
    echo "error: pubspec version '${current}' is not X.Y.Z+B" >&2
    exit 1
fi

semver="${current%%+*}"
build="${current##*+}"
IFS=. read -r major minor patch <<<"${semver}"

if [[ "${TYPE}" == "feat" || "${BREAKING}" -eq 1 ]]; then
    minor=$((minor + 1))
    patch=0
else
    patch=$((patch + 1))
fi
next="${major}.${minor}.${patch}+$((build + 1))"

sed -i -E "s|^version:[[:space:]].*|version: ${next}|" "${PUBSPEC}"
echo "${current} -> ${next}"
