#!/usr/bin/env bash
#
# Packages the Linux release bundle as a single-file AppImage.
#
# A Flutter Linux build is a directory, so the only way to offer Linux users a
# genuine direct download — one file, chmod +x, run — is an AppImage. It needs
# no installation, no extraction and no root.
#
# Usage: ./tool/build-appimage.sh <version> [output-directory]
set -euo pipefail

VERSION="${1:?usage: build-appimage.sh <version> [output-dir]}"
OUT_DIR="${2:-dist}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_DIR="${ROOT_DIR}/build/linux/x64/release/bundle"
BINARY_NAME="dividendendackel"
APP_DIR="$(mktemp -d)/DividendenDackel.AppDir"
trap 'rm -rf "$(dirname "${APP_DIR}")"' EXIT

if [[ ! -x "${BUNDLE_DIR}/${BINARY_NAME}" ]]; then
    echo "error: ${BUNDLE_DIR}/${BINARY_NAME} not found. Run: flutter build linux --release" >&2
    exit 1
fi

mkdir -p "${APP_DIR}/usr/bin"
cp -r "${BUNDLE_DIR}/." "${APP_DIR}/usr/bin/"

# The icon has to sit at the AppDir root as well; appimagetool looks for it
# next to the .desktop file.
cp "${ROOT_DIR}/assets/branding/icon.png" "${APP_DIR}/${BINARY_NAME}.png"
mkdir -p "${APP_DIR}/usr/share/icons/hicolor/512x512/apps"
cp "${ROOT_DIR}/assets/branding/icon.png" \
   "${APP_DIR}/usr/share/icons/hicolor/512x512/apps/${BINARY_NAME}.png"

cat > "${APP_DIR}/${BINARY_NAME}.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=DividendenDackel
GenericName=Dividend Tracker
Comment=The dachshund that fetches your dividends
Exec=${BINARY_NAME}
Icon=${BINARY_NAME}
Categories=Office;Finance;
Terminal=false
DESKTOP

cat > "${APP_DIR}/AppRun" <<'APPRUN'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
# The Flutter engine and plugin libraries ship beside the executable.
export LD_LIBRARY_PATH="${HERE}/usr/bin/lib:${LD_LIBRARY_PATH}"
exec "${HERE}/usr/bin/dividendendackel" "$@"
APPRUN
chmod +x "${APP_DIR}/AppRun"

mkdir -p "${ROOT_DIR}/${OUT_DIR}"
OUTPUT="${ROOT_DIR}/${OUT_DIR}/DividendenDackel-${VERSION}-x86_64.AppImage"

APPIMAGETOOL="${APPIMAGETOOL:-appimagetool}"

# appimagetool is itself an AppImage and would normally self-mount via FUSE.
# CI runners do not ship libfuse2, so it is told to unpack itself instead.
# Harmless where FUSE is available.
ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 \
    "${APPIMAGETOOL}" --no-appstream "${APP_DIR}" "${OUTPUT}"
chmod +x "${OUTPUT}"

echo "built ${OUTPUT}"
