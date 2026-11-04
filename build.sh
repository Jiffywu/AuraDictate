#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="${1:-$SCRIPT_DIR/build/AuraDictate.app}"
mkdir -p "$(dirname "$APP_PATH")"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

PARENT_DIR="$(dirname "$APP_PATH")"
STAGE_DIR="$(mktemp -d "${PARENT_DIR}/.AuraDictate.stage.XXXXXX")"
STAGE_APP="$STAGE_DIR/AuraDictate.app"
BACKUP_APP="${APP_PATH}.backup.$$"

cleanup() {
    rm -rf "$STAGE_DIR"
    if [[ -d "$BACKUP_APP" && ! -d "$APP_PATH" ]]; then
        mv "$BACKUP_APP" "$APP_PATH" || true
    else
        rm -rf "$BACKUP_APP"
    fi
}
trap cleanup EXIT

echo "==> Staging clean AuraDictate.app bundle"
mkdir -p "$STAGE_APP/Contents/MacOS"
mkdir -p "$STAGE_APP/Contents/Resources/Fonts"

cp "$SCRIPT_DIR/Info.plist" "$STAGE_APP/Contents/Info.plist"
if [[ -f "$SCRIPT_DIR/AppIcon.icns" ]]; then
    cp "$SCRIPT_DIR/AppIcon.icns" "$STAGE_APP/Contents/Resources/AppIcon.icns"
    plutil -replace CFBundleIconFile -string "AppIcon" "$STAGE_APP/Contents/Info.plist"
fi

if [[ -d "$SCRIPT_DIR/Fonts" ]]; then
    shopt -s nullglob
    FONT_FILES=("$SCRIPT_DIR/Fonts/"*.otf "$SCRIPT_DIR/Fonts/"*.ttf)
    shopt -u nullglob
    if (( ${#FONT_FILES[@]} > 0 )); then
        cp "${FONT_FILES[@]}" "$STAGE_APP/Contents/Resources/Fonts/"
    fi
fi

plutil -lint "$STAGE_APP/Contents/Info.plist" >/dev/null

swiftc -O \
    -target arm64-apple-macosx26.0 \
    -parse-as-library \
    "$SCRIPT_DIR/AuraDictate.swift" \
    -o "$STAGE_APP/Contents/MacOS/AuraDictate"

if [[ "$SIGN_IDENTITY" == "-" ]]; then
    codesign --force --deep --entitlements "$SCRIPT_DIR/Entitlements.plist" --sign - "$STAGE_APP"
else
    codesign --force --deep --options runtime --entitlements "$SCRIPT_DIR/Entitlements.plist" --sign "$SIGN_IDENTITY" "$STAGE_APP"
fi

codesign --verify --deep --strict "$STAGE_APP"

if [[ -d "$APP_PATH" ]]; then
    mv "$APP_PATH" "$BACKUP_APP"
fi
mv "$STAGE_APP" "$APP_PATH"
rm -rf "$BACKUP_APP"
touch "$APP_PATH"

echo "==> Successfully built, verified, and installed: $APP_PATH"
