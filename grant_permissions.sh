#!/bin/bash

# Grant permissions to Sherpa app on iPhone 15 simulator
SIMULATOR_ID="195C5211-C190-42A4-97B6-2F0A04986E9D"
BUNDLE_ID="com.example.miceActiveg"

echo "🔐 Granting permissions to Sherpa..."

xcrun simctl privacy $SIMULATOR_ID grant microphone $BUNDLE_ID
xcrun simctl privacy $SIMULATOR_ID grant location $BUNDLE_ID

echo "✅ Permissions granted!"
echo ""
echo "Now press 'R' in your flutter terminal to Hot Restart"
