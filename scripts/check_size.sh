#!/bin/bash
# Build Release and check app bundle size
set -e

echo "Building pdfClaw Release..."
xcodebuild -project pdfClaw.xcodeproj -scheme pdfClaw -configuration Release \
    -derivedDataPath build_check \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=NO \
    -quiet 2>/dev/null

APP_PATH="build_check/Build/Products/Release/pdfClaw.app"

if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: Build failed — app not found"
    exit 1
fi

SIZE_KB=$(du -sk "$APP_PATH" | cut -f1)
SIZE_MB=$(echo "scale=2; $SIZE_KB / 1024" | bc)

echo ""
echo "=== pdfClaw Size Report ==="
echo "App bundle: ${SIZE_MB} MB (${SIZE_KB} KB)"
echo ""

if [ "$SIZE_KB" -gt 5120 ]; then
    echo "WARNING: App exceeds 5 MB target!"
    echo "Current: ${SIZE_MB} MB | Target: < 5 MB"
    exit 1
else
    echo "PASS: Under 5 MB target"
fi

# Cleanup
rm -rf build_check
