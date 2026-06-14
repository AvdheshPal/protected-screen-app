# ScreenShield – Xcode Setup Guide

This guide provides step-by-step instructions to create and configure the ScreenShield project in Xcode.

## Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later (available on App Store)
- Swift 5.9 or later (included with Xcode)
- Basic familiarity with Xcode

## Part 1: Create Xcode Project

### Step 1: Launch Xcode

1. Open Xcode (from Applications/Utilities or Spotlight)
2. Wait for the Welcome window to appear

### Step 2: Create New Project

1. Click **"Create a new Xcode project"** or use File → New → Project
2. Select **macOS** platform (at the top)
3. Choose the **App** template
4. Click **Next**

### Step 3: Configure Project Settings

In the project configuration sheet, fill in:

| Field | Value |
|-------|-------|
| Product Name | `ScreenShield` |
| Team | Your Team (or None) |
| Organization Identifier | `com.mca` |
| Bundle Identifier | `com.mca.screenshield` |
| Language | Swift |
| User Interface | SwiftUI |
| Include Tests | Unchecked |

4. Click **Create**
5. Choose a location (e.g., `~/Desktop/Projects/protected-screen-app`)

## Part 2: Add Source Files

### Step 1: Prepare Source Files

You should have these Swift files ready:

```
ScreenShield/
├── ScreenShieldApp.swift
├── AppModel.swift
├── WindowManager.swift
├── CaptureTestHarness.swift
├── ContentView.swift
├── ModeAView.swift
├── ModeBView.swift
├── ModeCView.swift
├── Info.plist
└── ScreenShield.entitlements
```

### Step 2: Add Swift Files to Xcode

1. In Xcode, open the Project Navigator (left sidebar)
2. Right-click on the ScreenShield folder in the navigator
3. Select **"Add Files to ScreenShield..."**
4. Navigate to your source files folder
5. Select **all `.swift` files** (not .plist or .entitlements yet)
6. Ensure:
   - ✅ "Copy items if needed" is checked
   - ✅ "Create groups" is selected
   - ✅ "Add to targets: ScreenShield" is checked
7. Click **Add**

### Step 3: Replace Info.plist

1. In Project Navigator, find `Info.plist`
2. Right-click → **Delete** → **Remove Reference**
3. Right-click on ScreenShield folder → **Add Files to ScreenShield...**
4. Find and select the provided `Info.plist`
5. Ensure same checkboxes as above
6. Click **Add**

### Step 4: Add Entitlements File

1. Right-click on ScreenShield folder in Project Navigator
2. Select **Add Files to ScreenShield...**
3. Find and select `ScreenShield.entitlements`
4. Ensure same checkboxes
5. Click **Add**

## Part 3: Configure Build Settings

### Step 1: Select Target

1. In Xcode, click on the project name in the navigator (top of the tree)
2. Select the **ScreenShield** target
3. Click the **Build Settings** tab

### Step 2: Set Minimum Deployment Target

1. Search for "Minimum Deployment"
2. Set **macOS Deployment Target** to `13.0`

### Step 3: Set Swift Language Version

1. Search for "Swift Language"
2. Set **Swift Language Version** to `Swift 5.9` (or later)

### Step 4: Verify Architectures

1. Search for "Architectures"
2. Ensure **Architectures** includes `arm64` (Apple Silicon) and/or `x86_64` (Intel)

## Part 4: Configure Signing & Capabilities

### Step 1: Select Capabilities Tab

1. Select the **ScreenShield** target
2. Click the **Signing & Capabilities** tab

### Step 2: Set Team (if available)

1. Under **Signing**, set your **Team**
2. If no team, you can test unsigned or create a free Apple ID account

### Step 3: Set Entitlements File

1. Look for **Entitlements File** setting
2. Change the value to: `ScreenShield/ScreenShield.entitlements`
3. Or double-click to browse and select it

## Part 5: Verify Framework Links

### Step 1: Build Phases

1. Select the **ScreenShield** target
2. Click **Build Phases** tab
3. Expand **Link Binary With Libraries**

### Step 2: Verify Frameworks

Ensure these frameworks are present (if not, add them):

- ✅ SwiftUI
- ✅ AppKit
- ✅ AVFoundation
- ✅ CoreGraphics
- ✅ Vision
- ✅ Charts

To add a missing framework:

1. Click the **+** button at bottom
2. Search for the framework name
3. Select it and click **Add**

## Part 6: Build & Run

### Step 1: Set Build Target

1. At the top of Xcode, ensure:
   - Scheme: `ScreenShield` 
   - Device: `My Mac`

### Step 2: Build

1. Press **⌘B** or Product → Build
2. Wait for build to complete (no errors expected)

### Step 3: Run

1. Press **⌘R** or Product → Run
2. The app will launch

### Step 4: Grant Permissions

First run will prompt:
- "ScreenShield would like to record your screen"
- Click **Allow**

The app is now ready to use!

## Part 7: Verify Installation

Once the app launches:

1. ✅ See sidebar with "Mode A", "Mode B", "Mode C"
2. ✅ Main area shows financial dashboard UI
3. ✅ Toolbar shows "Recording Permission: Enabled"
4. ✅ Can click "Run Tests" button

If all these are working, the installation is complete.

## Troubleshooting

### Build Fails: Module not found

**Error**: `Cannot find module in scope`

**Solution**:
1. Clean build folder: ⇧⌘K
2. Delete derived data: Xcode → Settings → Locations → Derived Data (click folder)
3. Delete the folder shown
4. Rebuild: ⌘B

### Build Fails: Invalid entitlements

**Error**: `Invalid entitlements` or `Signing error`

**Solution**:
1. Go to Signing & Capabilities
2. Verify Entitlements File points to correct path
3. If Team is set to "None", remove the entitlements file reference temporarily

### Runtime Error: sharingType not available

**Error**: `Value of type 'NSWindow' has no member 'sharingType'`

**Solution**:
1. Verify Swift Language Version is 5.9
2. Verify Minimum macOS is 13.0
3. Check that you're targeting macOS, not iOS

### Permission Not Granted

**Error**: Screen recording permission still shows as not granted

**Solution**:
1. Open System Settings
2. Privacy & Security → Screen Recording
3. Add Xcode to the list
4. Quit and relaunch Xcode
5. Rebuild and run

## Project Structure After Setup

After following all steps, your Xcode project should have:

```
ScreenShield/
├── ScreenShield/
│   ├── ScreenShieldApp.swift
│   ├── ContentView.swift
│   ├── AppModel.swift
│   ├── WindowManager.swift
│   ├── CaptureTestHarness.swift
│   ├── ModeAView.swift
│   ├── ModeBView.swift
│   ├── ModeCView.swift
│   ├── Info.plist
│   └── ScreenShield.entitlements
├── ScreenShield.xcodeproj/
└── README.md
```

## Development Tips

### Running Tests

1. Click **Run Tests** in the toolbar
2. Tests run in background
3. Results appear in sheet after completion
4. Results saved to `~/Documents/CaptureTests/`

### Viewing Capture Results

1. After running tests, click **Results** button
2. See summary of what was captured
3. Click **"Open Results"** to view generated JSON and images

### Modifying Protection Modes

- **Mode A**: Edit `ModeAView.swift` for UI changes
- **Mode B**: Edit `ModeBView.swift`, protection toggle is already there
- **Mode C**: Edit `ModeCView.swift` to implement actual AVSampleBufferDisplayLayer

### Adding New Features

1. Create new Swift file: File → New → File
2. Choose macOS → Swift File
3. Name it appropriately
4. Add to ScreenShield target
5. Import SwiftUI if needed

## Next Steps

1. ✅ Complete this setup
2. Explore the app UI
3. Run the automated tests
4. Analyze capture_report.json output
5. Modify protection modes as needed for your research

## Additional Resources

- [Apple AVFoundation Documentation](https://developer.apple.com/documentation/avfoundation)
- [WindowServer & Screen Capture](https://developer.apple.com/documentation/screencapturekit)
- [macOS Security Framework](https://developer.apple.com/documentation/security)

---

For questions about the implementation, refer to inline code comments in the Swift files.
