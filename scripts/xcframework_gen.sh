#!/bin/bash
cd ../AuthSDK
set -e

# Check required commands exist
command -v xcodegen >/dev/null 2>&1 || { echo >&2 "xcodegen not installed."; exit 1; }
command -v xcodebuild >/dev/null 2>&1 || { echo >&2 "xcodebuild not installed."; exit 1; }

# Move to script directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

# Generate Xcode project
xcodegen

SCHEME="AuthSDK-Dev"

echo "Choose environment to build:"
options=("Dev" "Staging" "Production")

select opt in "${options[@]}"; do
    case $opt in
        "Dev") 
            SCHEME="AuthSDK-Dev"; break;;
        "Staging")
            SCHEME="AuthSDK-Staging"; break;;
        "Production")
            SCHEME="AuthSDK-Production"; break;;
        *) 
            echo "Invalid option";;
    esac
done

echo "Building scheme: $SCHEME"

# Paths definition
IPHONEOS_ARCHIVE="../build/${SCHEME}-iphoneos.xcarchive"
SIMULATOR_ARCHIVE="../build/${SCHEME}-iphonesimulator.xcarchive"
XCFRAMEWORK_OUTPUT="../outputs/AuthSDK.xcframework"
DERIVED_DATA="../build/DerivedData"

# Ensure clean directories
rm -rf "../build" "$XCFRAMEWORK_OUTPUT"

# Clean project
xcodebuild clean -scheme "$SCHEME" -project AuthSDK.xcodeproj -destination 'generic/platform=iOS'
xcodebuild clean -scheme "$SCHEME" -project AuthSDK.xcodeproj -destination 'generic/platform=iOS Simulator'
rm -rf $DERIVED_DATA

# Resolve dependencies
xcodebuild -resolvePackageDependencies -project AuthSDK.xcodeproj

# # Ensure clean directories
# rm -rf "./build" "$XCFRAMEWORK_OUTPUT" "./demo/Frameworks/AuthSDK.xcframework"
# mkdir -p outputs demo/Frameworks

# # Clean project
# xcodebuild clean -scheme "$SCHEME" -project AuthSDK.xcodeproj
# rm -rf "./build/DerivedData"

# Resolve dependencies
xcodebuild -resolvePackageDependencies -project AuthSDK.xcodeproj -scheme "$SCHEME"

# # Build archives
# xcodebuild archive \
#   -project AuthSDK.xcodeproj \
#   -scheme "$SCHEME" \
#   -configuration Release \
#   -destination 'generic/platform=iOS' \
#   -archivePath "$IPHONEOS_ARCHIVE" \
#   -derivedDataPath "./build/DerivedData" \
#   SKIP_INSTALL=NO \
#   BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# xcodebuild archive \
#   -project AuthSDK.xcodeproj \
#   -scheme "$SCHEME" \
#   -configuration Release \
#   -destination 'generic/platform=iOS Simulator' \
#   -archivePath "$SIMULATOR_ARCHIVE" \
#   -derivedDataPath "./build/DerivedData" \
#   SKIP_INSTALL=NO \
#   BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# # Create XCFramework
# xcodebuild -create-xcframework \
#   -framework "$SIMULATOR_ARCHIVE/Products/Library/Frameworks/AuthSDK.framework" \
#   -framework "$IPHONEOS_ARCHIVE/Products/Library/Frameworks/AuthSDK.framework" \
#   -output "$XCFRAMEWORK_OUTPUT"

# # Copy to demo
# cp -r "$XCFRAMEWORK_OUTPUT" "./demo/Frameworks"

# echo "✅ XCFramework successfully built and copied!"


# Build archives
xcodebuild archive \
  -project AuthSDK.xcodeproj \
  -scheme "$SCHEME" \
  -destination 'generic/platform=iOS' \
  -archivePath "$IPHONEOS_ARCHIVE" \
  -derivedDataPath "$DERIVED_DATA" \
  SWIFT_VERIFY_EMITTED_MODULE_INTERFACE=NO

xcodebuild archive \
  -project AuthSDK.xcodeproj \
  -scheme "$SCHEME" \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath "$SIMULATOR_ARCHIVE" \
  -derivedDataPath "$DERIVED_DATA" \
  SWIFT_VERIFY_EMITTED_MODULE_INTERFACE=NO

# Create XCFramework
xcodebuild -create-xcframework \
  -framework "$SIMULATOR_ARCHIVE/Products/Library/Frameworks/AuthSDK.framework" \
  -framework "$IPHONEOS_ARCHIVE/Products/Library/Frameworks/AuthSDK.framework" \
  -output "$XCFRAMEWORK_OUTPUT"

echo "✅ XCFramework successfully built!"