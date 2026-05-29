
#!/usr/bin/env bash


cd ../PaymentSDK

# 1) generate with XcodeGen
xcodegen

# 2) install blank header-macro into PaymentSDK.xcodeproj
WORKSPACE=$(find . -maxdepth 1 -type d -name "*.xcodeproj" | head -n 1)
SHARED_DATA="$WORKSPACE/xcshareddata"
mkdir -p "$SHARED_DATA"
cp -f ../scripts/IDETemplateMacros.plist "$SHARED_DATA/IDETemplateMacros.plist"

# 3) resolve SwiftPM dependencies
xcodebuild -resolvePackageDependencies

# go back up
cd ../PaymentSDKExample

### Example
# re-generate
# rm -rf PaymentSDKExample/PaymentSDKExample.xcodeproj

# 1) generate with XcodeGen
xcodegen

# 2) install blank header-macro into PaymentSDKExample.xcodeproj
WORKSPACE=$(find . -maxdepth 1 -type d -name "*.xcodeproj" | head -n 1)
SHARED_DATA="$WORKSPACE/xcshareddata"
mkdir -p "$SHARED_DATA"
cp -f ../scripts/IDETemplateMacros.plist "$SHARED_DATA/IDETemplateMacros.plist"

# 3) resolve SwiftPM dependencies & open
xcodebuild -resolvePackageDependencies -project "$WORKSPACE" -scheme PaymentSDKExample
open "$WORKSPACE"

# done
