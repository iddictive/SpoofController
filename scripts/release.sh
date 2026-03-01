#!/bin/bash
# scripts/release.sh

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./scripts/release.sh v1.0.0"
    exit 1
fi

echo "🚀 Starting release process for ${VERSION}..."

# 1. Build the app
bash build.sh

# 2. Create DMG
bash scripts/create_dmg.sh

# 3. Git operations
git add .
git commit -m "chore: release ${VERSION}"
git tag -a "${VERSION}" -m "Release ${VERSION}"
git push origin main
git push origin "${VERSION}"

# 4. Create GitHub Release (if gh cli is available)
if command -v gh &> /dev/null; then
    echo "Creating GitHub Release..."
    gh release create "${VERSION}" DPIKiller.dmg --title "Release ${VERSION}" --notes "Check README for changelog."
else
    echo "GitHub CLI (gh) not found. Please upload DPIKiller.dmg manually to the GitHub Release page."
fi

echo "Done! 🏎️💨"
