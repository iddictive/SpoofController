#!/bin/bash
set -e
APP_NAME="SpoofController"
APP_BUNDLE="${APP_NAME}.app"

# Clean old build
rm -rf "${APP_BUNDLE}"

# Create structure
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Compile code directly into bundle
swiftc -o "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}" main.swift -framework Cocoa -framework Foundation

# Copy Info.plist and Icon
cp Info.plist "${APP_BUNDLE}/Contents/Info.plist"
cp assets/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
cp README.md "${APP_BUNDLE}/Contents/Resources/README.md"

echo "Build complete: ${APP_BUNDLE}"

if [[ "$1" == "--dmg" ]]; then
    bash scripts/create_dmg.sh
fi

echo "To add to Login Items, run: osascript -e 'tell application \"System Events\" to make login item at end with properties {path:\"$(pwd)/${APP_BUNDLE}\", hidden:false}'"
