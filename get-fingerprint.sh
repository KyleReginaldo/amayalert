#!/bin/bash

# Script to get SHA256 fingerprint for Android App Links
# Run this script to get the fingerprint needed for assetlinks.json

echo "Getting SHA256 fingerprint for Android App Links..."
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "Error: keytool not found. Make sure Java JDK is installed and in PATH."
    exit 1
fi

echo "=== DEBUG KEYSTORE FINGERPRINT ==="
echo "Getting fingerprint for debug keystore..."
echo ""

# Get debug keystore fingerprint
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "Debug keystore found at: $DEBUG_KEYSTORE"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android | grep -A1 "SHA256:"
else
    echo "Debug keystore not found. You may need to run 'flutter run' first to generate it."
fi

echo ""
echo "=== INSTRUCTIONS ==="
echo "1. Copy the SHA256 fingerprint from above"
echo "2. Remove all colons (:) from the fingerprint"
echo "3. Update web/.well-known/assetlinks.json with this fingerprint"
echo ""
echo "For release builds, you'll need to get the fingerprint from your release keystore:"
echo "keytool -list -v -keystore /path/to/your/release-keystore.jks -alias your-key-alias"
echo ""
echo "=== CURRENT ASSETLINKS.JSON ==="
echo "File location: web/.well-known/assetlinks.json"
if [ -f "web/.well-known/assetlinks.json" ]; then
    cat web/.well-known/assetlinks.json
else
    echo "File not found!"
fi