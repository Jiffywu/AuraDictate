#!/usr/bin/env bash
set -euo pipefail

# Aura Dictate — One-Line macOS Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Jiffywu/AuraDictate/main/install.sh | bash

REPO="Jiffywu/AuraDictate"
INSTALL_PATH="/Applications/AuraDictate.app"
TMP_DIR="$(mktemp -d /tmp/auradictate-install.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Installing Aura Dictate to $INSTALL_PATH..."

# 1. Try downloading the latest pre-built release asset first
LATEST_URL="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null | grep -Eo 'https://[^"]+AuraDictate-macos-arm64\.zip' | head -n 1 || true)"

if [[ -n "$LATEST_URL" ]]; then
    echo "==> Downloading pre-built Apple Silicon release..."
    curl -fL "$LATEST_URL" -o "$TMP_DIR/AuraDictate.zip"
    ditto -x -k "$TMP_DIR/AuraDictate.zip" "$TMP_DIR/"
    if [[ -d "$TMP_DIR/AuraDictate.app" ]]; then
        pkill -x AuraDictate 2>/dev/null || true
        rm -rf "$INSTALL_PATH"
        mv "$TMP_DIR/AuraDictate.app" "$INSTALL_PATH"
        xattr -cr "$INSTALL_PATH" 2>/dev/null || true
        echo "==> Launching Aura Dictate..."
        open "$INSTALL_PATH"
        echo "✓ Aura Dictate is installed and running in your menu bar!"
        exit 0
    fi
fi

# 2. Fallback: Build from source if swiftc is available
if command -v swiftc >/dev/null 2>&1; then
    echo "==> Building natively from source..."
    git clone --depth 1 "https://github.com/$REPO.git" "$TMP_DIR/src"
    pkill -x AuraDictate 2>/dev/null || true
    "$TMP_DIR/src/build.sh" "$INSTALL_PATH"
    xattr -cr "$INSTALL_PATH" 2>/dev/null || true
    open "$INSTALL_PATH"
    echo "✓ Aura Dictate built and running in your menu bar!"
else
    echo "Error: Could not find a pre-built release and Xcode Command Line Tools are not installed."
    exit 1
fi
