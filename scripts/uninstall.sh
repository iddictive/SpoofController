#!/bin/bash
# scripts/uninstall.sh

APP_NAME="SpoofController"
APP_PATH="/Applications/${APP_NAME}.app"

echo "Uninstalling ${APP_NAME}..."

# 1. Stop the process if running
echo "Stopping background processes..."
pkill -f "spoofdpi"
pkill -f "${APP_NAME}"

# 2. Remove the app bundle
if [ -d "${APP_PATH}" ]; then
    echo "Removing ${APP_PATH}..."
    sudo rm -rf "${APP_PATH}"
else
    echo "App not found in /Applications"
fi

# 3. Remove Login Item (macOS persistent approach)
echo "Removing from Login Items..."
osascript -e "tell application \"System Events\" to delete login item \"${APP_NAME}\"" 2>/dev/null

# 4. Clean up user data
echo "Cleaning up user defaults and logs..."
defaults delete com.iddictive.${APP_NAME} 2>/dev/null
rm -rf ~/Library/Logs/${APP_NAME} 2>/dev/null

echo "Uninstallation complete. 🧹"
