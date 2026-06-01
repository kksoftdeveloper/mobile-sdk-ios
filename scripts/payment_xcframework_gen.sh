#!/bin/bash
cd ../PaymentSDK
set -e

# Check required commands exist
command -v xcodegen >/dev/null 2>&1 || { echo >&2 "xcodegen not installed."; exit 1; }
command -v xcodebuild >/dev/null 2>&1 || { echo >&2 "xcodebuild not installed."; exit 1; }

# Move to script directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Generate Xcode project
xcodegen

SCHEME="PaymentSDK-Dev"

echo "Choose environment to build:"
options=("Dev" "Staging" "Production")

select opt in "${options[@]}"; do
    case $opt in
        "Dev") 
            SCHEME="PaymentSDK-Dev"; break;;
        "Staging")
            SCHEME="PaymentSDK-Staging"; break;;
        "Production")
            SCHEME="PaymentSDK-Production"; break;;
        *) 
            echo "Invalid option";;
    esac
done

echo "Building scheme: $SCHEME"

# Paths definition
IPHONEOS_ARCHIVE="../build/${SCHEME}-iphoneos.xcarchive"
SIMULATOR_ARCHIVE="../build/${SCHEME}-iphonesimulator.xcarchive"
XCFRAMEWORK_OUTPUT="../outputs/PaymentSDK.xcframework"
DERIVED_DATA="../build/DerivedData"

# Ensure clean directories
rm -rf "../build" "$XCFRAMEWORK_OUTPUT"

# Clean project
xcodebuild clean -scheme "$SCHEME" -project PaymentSDK.xcodeproj -destination 'generic/platform=iOS'
xcodebuild clean -scheme "$SCHEME" -project PaymentSDK.xcodeproj -destination 'generic/platform=iOS Simulator'
rm -rf $DERIVED_DATA

# Resolve dependencies
xcodebuild -resolvePackageDependencies -project PaymentSDK.xcodeproj

# # Ensure clean directories
# rm -rf "./build" "$XCFRAMEWORK_OUTPUT" "./demo/Frameworks/PaymentSDK.xcframework"
# mkdir -p outputs demo/Frameworks

# # Clean project
# xcodebuild clean -scheme "$SCHEME" -project PaymentSDK.xcodeproj
# rm -rf "./build/DerivedData"

# Resolve dependencies
xcodebuild -resolvePackageDependencies -project PaymentSDK.xcodeproj -scheme "$SCHEME"

# # Build archives
# xcodebuild archive \
#   -project PaymentSDK.xcodeproj \
#   -scheme "$SCHEME" \
#   -configuration Release \
#   -destination 'generic/platform=iOS' \
#   -archivePath "$IPHONEOS_ARCHIVE" \
#   -derivedDataPath "./build/DerivedData" \
#   SKIP_INSTALL=NO \
#   BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# xcodebuild archive \
#   -project PaymentSDK.xcodeproj \
#   -scheme "$SCHEME" \
#   -configuration Release \
#   -destination 'generic/platform=iOS Simulator' \
#   -archivePath "$SIMULATOR_ARCHIVE" \
#   -derivedDataPath "./build/DerivedData" \
#   SKIP_INSTALL=NO \
#   BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# # Create XCFramework
# xcodebuild -create-xcframework \
#   -framework "$SIMULATOR_ARCHIVE/Products/Library/Frameworks/PaymentSDK.framework" \
#   -framework "$IPHONEOS_ARCHIVE/Products/Library/Frameworks/PaymentSDK.framework" \
#   -output "$XCFRAMEWORK_OUTPUT"

# # Copy to demo
# cp -r "$XCFRAMEWORK_OUTPUT" "./demo/Frameworks"

# echo "✅ XCFramework successfully built and copied!"


# Build archives
xcodebuild archive \
  -project PaymentSDK.xcodeproj \
  -scheme "$SCHEME" \
  -destination 'generic/platform=iOS' \
  -archivePath "$IPHONEOS_ARCHIVE" \
  -derivedDataPath "$DERIVED_DATA" \
  SWIFT_VERIFY_EMITTED_MODULE_INTERFACE=NO \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  DEVELOPMENT_TEAM="" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  -verbose

xcodebuild archive \
  -project PaymentSDK.xcodeproj \
  -scheme "$SCHEME" \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath "$SIMULATOR_ARCHIVE" \
  -derivedDataPath "$DERIVED_DATA" \
  SWIFT_VERIFY_EMITTED_MODULE_INTERFACE=NO \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  DEVELOPMENT_TEAM="" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  -verbose

# Create XCFramework
xcodebuild -create-xcframework \
  -framework "$SIMULATOR_ARCHIVE/Products/Library/Frameworks/PaymentSDK.framework" \
  -framework "$IPHONEOS_ARCHIVE/Products/Library/Frameworks/PaymentSDK.framework" \
  -output "$XCFRAMEWORK_OUTPUT"

echo "✅ XCFramework successfully built!"
