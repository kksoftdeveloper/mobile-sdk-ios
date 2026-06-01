#!/usr/bin/env bash

### AuthSDK
# re-generate
# rm -rf AuthSDK/AuthSDK.xcodeproj

cd ../AuthSDK

# 1) generate with XcodeGen
xcodegen

# 2) install blank header-macro into AuthSDK.xcodeproj
WORKSPACE=$(find . -maxdepth 1 -type d -name "*.xcodeproj" | head -n 1)
SHARED_DATA="$WORKSPACE/xcshareddata"
mkdir -p "$SHARED_DATA"
cp -f ../scripts/IDETemplateMacros.plist "$SHARED_DATA/IDETemplateMacros.plist"

# 3) resolve SwiftPM dependencies
xcodebuild -resolvePackageDependencies

# go back up
cd ../AuthSDKExample

### Example
# re-generate
# rm -rf AuthSDKExample/AuthSDKExample.xcodeproj

# 1) generate with XcodeGen
xcodegen

# 2) install blank header-macro into AuthSDKExample.xcodeproj
WORKSPACE=$(find . -maxdepth 1 -type d -name "*.xcodeproj" | head -n 1)
SHARED_DATA="$WORKSPACE/xcshareddata"
mkdir -p "$SHARED_DATA"
cp -f ../scripts/IDETemplateMacros.plist "$SHARED_DATA/IDETemplateMacros.plist"

# 3) resolve SwiftPM dependencies & open
xcodebuild -resolvePackageDependencies -project "$WORKSPACE" -scheme AuthSDKExample
open "$WORKSPACE"

# done
