#!/usr/bin/env bash
#
# Runs the app with local provider keys, without them touching the repository.
#
# Keys live in dev_secrets.env, which git ignores. They are passed as
# --dart-define values, so they exist only in this debug run: a release build
# never receives them, and nothing is written to a file the app ships.
#
# Usage: ./tool/run-dev.sh [flutter run arguments]
#        ./tool/run-dev.sh -d linux
#        ./tool/run-dev.sh -d <android-device-id>
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS="${ROOT_DIR}/dev_secrets.env"

if [[ ! -f "${SECRETS}" ]]; then
    echo "[INFO] No dev_secrets.env yet. Creating one from the example."
    cp "${ROOT_DIR}/dev_secrets.example.env" "${SECRETS}"
    echo "[INFO] It starts with Alpha Vantage's published demo key, which"
    echo "       answers for IBM and refuses everything else. Put your own key"
    echo "       in ${SECRETS} to price a real portfolio."
fi

defines=()
while IFS='=' read -r name value; do
    [[ "${name}" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${name// /}" || -z "${value// /}" ]] && continue
    defines+=("--dart-define=${name// /}=${value}")
done <"${SECRETS}"

if [[ "${#defines[@]}" -eq 0 ]]; then
    echo "[WARN] ${SECRETS} defines no keys; quotes will be unavailable."
else
    # Names only. Printing a value here would put it in a terminal scrollback
    # and any CI log that ever runs this.
    echo "[INFO] Passing $(printf '%s\n' "${defines[@]}" | sed 's/=.*//;s/--dart-define=//' | paste -sd' ' -)"
fi

exec flutter run "${defines[@]}" "$@"
