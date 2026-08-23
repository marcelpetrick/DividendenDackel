#!/usr/bin/env bash
# Reports stable toolchain releases without changing the repository. Intended
# for the scheduled freshness workflow and useful as a local audit command.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ROOT_DIR
readonly SUMMARY_FILE="${GITHUB_STEP_SUMMARY:-/dev/stdout}"

fetch() {
    curl --fail --silent --show-error --location --retry 3 "$1"
}

stable_maven_version() {
    sed -n '/<versions>/,/<\/versions>/p' \
        | sed -n 's:.*<version>\([^<-]*\)</version>.*:\1:p' \
        | sort -V \
        | tail -n 1
}

current_flutter="$(sed -n 's/^readonly PINNED_FLUTTER_VERSION="\([^"]*\)"/\1/p' "${ROOT_DIR}/localPipeline.sh")"
latest_flutter="$(fetch https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json \
    | jq -r '.current_release.stable as $stable | .releases[] | select(.hash == $stable) | .version')"
current_agp="$(sed -n 's/.*id("com.android.application") version "\([^"]*\)".*/\1/p' "${ROOT_DIR}/android/settings.gradle.kts")"
latest_agp="$(fetch https://dl.google.com/dl/android/maven2/com/android/tools/build/gradle/maven-metadata.xml | stable_maven_version)"
current_gradle="$(sed -n 's:.*gradle-\([0-9.]*\)-all.zip:\1:p' "${ROOT_DIR}/android/gradle/wrapper/gradle-wrapper.properties")"
latest_gradle="$(fetch https://services.gradle.org/versions/current | jq -r .version)"
current_kotlin="$(sed -n 's/.*id("org.jetbrains.kotlin.android") version "\([^"]*\)".*/\1/p' "${ROOT_DIR}/android/settings.gradle.kts")"
latest_kotlin="$(fetch https://plugins.gradle.org/m2/org/jetbrains/kotlin/android/org.jetbrains.kotlin.android.gradle.plugin/maven-metadata.xml | stable_maven_version)"
min_sdk="$(sed -n 's/^[[:space:]]*minSdk = \([0-9]*\).*/\1/p' "${ROOT_DIR}/android/app/build.gradle.kts")"
target_sdk="$(sed -n 's/^[[:space:]]*targetSdk = \([0-9]*\).*/\1/p' "${ROOT_DIR}/android/app/build.gradle.kts")"

{
    echo '## Toolchain'
    echo
    echo '| Component | Pinned | Latest stable |'
    echo '| --- | ---: | ---: |'
    echo "| Flutter | ${current_flutter} | ${latest_flutter} |"
    echo "| Android Gradle Plugin | ${current_agp} | ${latest_agp} |"
    echo "| Gradle | ${current_gradle} | ${latest_gradle} |"
    echo "| Kotlin | ${current_kotlin} | ${latest_kotlin} |"
    echo
    echo "Android compatibility guard: minSdk ${min_sdk}; targetSdk ${target_sdk}."
    echo
    echo 'Dependabot separately reports immutable GitHub Action updates.'
} >> "${SUMMARY_FILE}"

for comparison in \
    "Flutter:${current_flutter}:${latest_flutter}" \
    "Android Gradle Plugin:${current_agp}:${latest_agp}" \
    "Gradle:${current_gradle}:${latest_gradle}" \
    "Kotlin:${current_kotlin}:${latest_kotlin}"; do
    IFS=: read -r component current latest <<< "${comparison}"
    if [[ "${current}" != "${latest}" ]]; then
        echo "::warning title=${component} update available::Pinned ${current}; latest stable ${latest}"
    fi
done
