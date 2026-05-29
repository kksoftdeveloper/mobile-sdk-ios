# TrackingSDK Setup with XcodeGen

This guide explains how to generate and build the TrackingSDK Xcode project using XcodeGen.

## Prerequisites

1. **XcodeGen**: Install XcodeGen if you haven't already
   ```bash
   brew install xcodegen
   ```

2. **Xcode**: Make sure you have Xcode installed (version 14.0 or later recommended)

## Generate Xcode Project

1. Navigate to the TrackingSDK directory:
   ```bash
   cd TrackingSDK
   ```

2. Generate the Xcode project from `project.yml`:
   ```bash
   xcodegen generate
   ```

   This will create `TrackingSDK.xcodeproj` in the TrackingSDK directory.

## Build the SDK

### Using Xcode

1. Open the generated project:
   ```bash
   open TrackingSDK.xcodeproj
   ```

2. Select a scheme:
   - `TrackingSDK-Dev` (Debug configuration)
   - `TrackingSDK-Staging` (Release configuration)
   - `TrackingSDK-Production` (Release configuration)

3. Build the project:
   - Press `Cmd + B` or select Product → Build

### Using Command Line

```bash
# Build for device (Release)
xcodebuild -project TrackingSDK.xcodeproj \
           -scheme TrackingSDK-Production \
           -configuration Production \
           -destination 'generic/platform=iOS' \
           clean build

# Build for simulator (Debug)
xcodebuild -project TrackingSDK.xcodeproj \
           -scheme TrackingSDK-Dev \
           -configuration Dev \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           clean build
```

## Run Tests

### Using Xcode

1. Open the project in Xcode
2. Select the `TrackingSDKTests` scheme
3. Press `Cmd + U` or select Product → Test

### Using Command Line

```bash
xcodebuild test -project TrackingSDK.xcodeproj \
                -scheme TrackingSDK-Dev \
                -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Regenerate Project

If you make changes to `project.yml`, regenerate the project:

```bash
xcodegen generate
```

**Note**: This will overwrite the existing `.xcodeproj` file. Make sure to commit your `project.yml` changes before regenerating.

## Project Structure

After generation, you'll have:

```
TrackingSDK/
├── TrackingSDK.xcodeproj/     # Generated Xcode project
├── project.yml                 # XcodeGen configuration
├── Package.swift               # Swift Package Manager config
├── Sources/
│   ├── TrackingSDK/           # Main SDK source code
│   └── TrackingSDKTests/      # Test source code
└── README.md                   # SDK documentation
```

## Troubleshooting

### XcodeGen not found
```bash
brew install xcodegen
```

### Package resolution issues
If you encounter package resolution issues:
1. Open the project in Xcode
2. Go to File → Packages → Reset Package Caches
3. Go to File → Packages → Resolve Package Versions

### Build errors
1. Clean build folder: `Cmd + Shift + K`
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Regenerate project: `xcodegen generate`
4. Rebuild

## Configuration Options

The `project.yml` file supports three build configurations:

- **Dev**: Debug build with `DEV` compilation condition
- **Staging**: Release build with `STAGING` compilation condition  
- **Production**: Release build with `PRODUCTION` compilation condition

You can switch between configurations in Xcode by selecting different schemes.

