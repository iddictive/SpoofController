#!/bin/bash
set -e
APP_NAME="DPIKiller"
APP_BUNDLE="${APP_NAME}.app"

# Clean old build
rm -rf "${APP_BUNDLE}"

# Create structure
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Compile code directly into bundle
swift_sources=("main.swift")
while IFS= read -r file; do
    swift_sources+=("$file")
done < <(find Sources -name '*.swift' | sort)

MODULE_CACHE_DIR="${TMPDIR:-/tmp}/dpikiller-module-cache"
mkdir -p "${MODULE_CACHE_DIR}"

swiftc -module-cache-path "${MODULE_CACHE_DIR}" -o "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}" "${swift_sources[@]}" -framework Cocoa -framework Foundation -framework WebKit -framework Network

# Update version in Info.plist (v2.x)
VERSION_FILE=".version"
if [ ! -f "$VERSION_FILE" ]; then
    echo "0" > "$VERSION_FILE"
fi
BUILD_NUM=$(cat "$VERSION_FILE")
BUILD_NUM=$((BUILD_NUM + 1))
echo "$BUILD_NUM" > "$VERSION_FILE"
FULL_VERSION="2.0.${BUILD_NUM}"

# Use plutil to update Info.plist if available, else use sed
if command -v plutil >/dev/null 2>&1; then
    plutil -replace CFBundleShortVersionString -string "$FULL_VERSION" Info.plist
else
    sed -i '' "s/<string>1.2.0<\/string>/<string>$FULL_VERSION<\/string>/" Info.plist
fi

# Copy Info.plist, Icon, and Assets
cp Info.plist "${APP_BUNDLE}/Contents/Info.plist"
cp assets/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
cp README.md "${APP_BUNDLE}/Contents/Resources/README.md"
mkdir -p "${APP_BUNDLE}/Contents/Resources/assets"
cp assets/banner.png "${APP_BUNDLE}/Contents/Resources/assets/banner.png"

# Copy patched spoofdpi binary
if [ -f "spoofdpi-patched" ]; then
    cp spoofdpi-patched "${APP_BUNDLE}/Contents/MacOS/spoofdpi-binary"
    chmod +x "${APP_BUNDLE}/Contents/MacOS/spoofdpi-binary"
fi

echo "Build complete: ${APP_BUNDLE}"

if [[ "$1" == "--dmg" ]]; then
    bash scripts/create_dmg.sh
fi

echo "To add to Login Items, run: osascript -e 'tell application \"System Events\" to make login item at end with properties {path:\"$(pwd)/${APP_BUNDLE}\", hidden:false}'"
