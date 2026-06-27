#!/bin/bash
set -e

echo "Building MenuSwitch in release mode..."
swift build -c release

APP_NAME="MenuSwitch"
BUILD_DIR=".build/release"
APP_BUNDLE="build/${APP_NAME}.app"

echo "Packaging ${APP_NAME}.app..."
rm -rf "build"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Compile icns if icon png exists
if [ -f "Resources/AppIcon.png" ]; then
    if [ ! -f "Resources/AppIcon.icns" ] || [ "Resources/AppIcon.png" -nt "Resources/AppIcon.icns" ]; then
        echo "Compiling AppIcon.icns from Resources/AppIcon.png..."
        ICONSET="Resources/AppIcon.iconset"
        mkdir -p "$ICONSET"
        sips -s format png -z 16 16     Resources/AppIcon.png --out "$ICONSET/icon_16x16.png" >/dev/null 2>&1
        sips -s format png -z 32 32     Resources/AppIcon.png --out "$ICONSET/icon_16x16@2x.png" >/dev/null 2>&1
        sips -s format png -z 32 32     Resources/AppIcon.png --out "$ICONSET/icon_32x32.png" >/dev/null 2>&1
        sips -s format png -z 64 64     Resources/AppIcon.png --out "$ICONSET/icon_32x32@2x.png" >/dev/null 2>&1
        sips -s format png -z 128 128   Resources/AppIcon.png --out "$ICONSET/icon_128x128.png" >/dev/null 2>&1
        sips -s format png -z 256 256   Resources/AppIcon.png --out "$ICONSET/icon_128x128@2x.png" >/dev/null 2>&1
        sips -s format png -z 256 256   Resources/AppIcon.png --out "$ICONSET/icon_256x256.png" >/dev/null 2>&1
        sips -s format png -z 512 512   Resources/AppIcon.png --out "$ICONSET/icon_256x256@2x.png" >/dev/null 2>&1
        sips -s format png -z 512 512   Resources/AppIcon.png --out "$ICONSET/icon_512x512.png" >/dev/null 2>&1
        sips -s format png -z 1024 1024 Resources/AppIcon.png --out "$ICONSET/icon_512x512@2x.png" >/dev/null 2>&1
        iconutil -c icns "$ICONSET"
        rm -rf "$ICONSET"
    fi
    cp "Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
fi

cat <<EOF > "${APP_BUNDLE}/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.chien.MenuSwitch</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon.icns</string>
</dict>
</plist>
EOF

echo "✓ ${APP_NAME}.app successfully packaged inside build/"
