#!/usr/bin/env bash
set -euo pipefail

# Packages AuraDictate.app into:
# 1. dist/AuraDictate.dmg (drag-and-drop /Applications installer for non-technical users)
# 2. dist/AuraDictate-macos-arm64.zip (for GitHub Releases / Homebrew Cask / install.sh)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
STAGE_DMG="$DIST_DIR/dmg-root"
SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application: Jeffrey Nguyen (63UPQPPWQF)}"

rm -rf "$DIST_DIR"
mkdir -p "$STAGE_DMG"

echo "==> Building signed AuraDictate.app..."
SIGN_IDENTITY="$SIGN_IDENTITY" "$ROOT_DIR/build.sh" "$STAGE_DMG/AuraDictate.app"

echo "==> Creating AuraDictate-macos-arm64.zip..."
ditto -c -k --sequesterRsrc --keepParent "$STAGE_DMG/AuraDictate.app" "$DIST_DIR/AuraDictate-macos-arm64.zip"

echo "==> Creating drag-and-drop AuraDictate.dmg..."
ln -s /Applications "$STAGE_DMG/Applications"
hdiutil create \
    -volname "Aura Dictate" \
    -srcfolder "$STAGE_DMG" \
    -ov \
    -format UDZO \
    "$DIST_DIR/AuraDictate.dmg" >/dev/null

rm -rf "$STAGE_DMG"

if [[ "$SIGN_IDENTITY" != "-" ]]; then
    codesign --force --sign "$SIGN_IDENTITY" "$DIST_DIR/AuraDictate.dmg"
fi

echo "==> Release artifacts ready in $DIST_DIR:"
ls -lh "$DIST_DIR"
shasum -a 256 "$DIST_DIR/AuraDictate.dmg" "$DIST_DIR/AuraDictate-macos-arm64.zip"
