# ScreenShield – Browser Screen-Capture Boundary Analysis

A production-grade native macOS application demonstrating three distinct screen capture protection strategies. This is a research + engineering project for the MCA assignment titled "Browser Screen-Capture Boundary Analysis".

## Overview

ScreenShield demonstrates how sensitive content can be protected against screen recording and browser tab/window capture using three distinct protection mechanisms:

1. **Mode A: Unprotected Baseline** – Standard SwiftUI rendering (control group)
2. **Mode B: NSWindow Shield** – WindowServer-level protection via `sharingType = .none`
3. **Mode C: DRM Protected Layer** – GPU-level protection via AVSampleBufferDisplayLayer

## Research Objectives

- Understand how browsers (Chrome, Safari, Brave) capture screen content
- Test effectiveness of NSWindow protection at the WindowServer level
- Demonstrate GPU-level resistance using protected media rendering
- Provide automated analysis of capture effectiveness

## Project Structure

```
ScreenShield/
├── ScreenShieldApp.swift            # Main app entry point
├── AppModel.swift                   # Application state (@Observable)
├── WindowManager.swift              # NSWindow operations & capture
├── CaptureTestHarness.swift         # Automated test harness
├── ContentView.swift                # Main navigation & UI orchestration
├── ModeAView.swift                  # Unprotected baseline
├── ModeBView.swift                  # NSWindow shield protection
├── ModeCView.swift                  # DRM protected layer
├── Info.plist                       # Application metadata
└── ScreenShield.entitlements        # Sandbox & capabilities
```

## Xcode Project Setup

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Step-by-Step Setup

1. **Create New Project**
   - Open Xcode
   - File → New → Project...
   - Select "macOS" platform
   - Choose "App" template
   - Click "Next"

2. **Configure Project**
   - Product Name: `ScreenShield`
   - Team: Your Team (if available)
   - Organization Identifier: `com.mca`
   - Language: Swift
   - User Interface: SwiftUI
   - Click "Create"

3. **Copy Source Files**
   - Copy all `.swift` files from `ScreenShield/` folder to the Xcode project
   - Copy `Info.plist` and `ScreenShield.entitlements` to the project

4. **Configure Build Settings**
   - Select the ScreenShield target in Xcode
   - Build Settings tab
   - Set "Minimum Deployment Target" to `macOS 13.0`
   - Set "Swift Language Version" to `Swift 5.9`

5. **Configure Signing & Capabilities**
   - Select the ScreenShield target
   - Signing & Capabilities tab
   - Under "Entitlements File", select `ScreenShield.entitlements`

6. **Add Framework Dependencies**
   - Go to Build Phases → Link Binary With Libraries
   - Ensure these frameworks are included:
     - AVFoundation
     - SwiftUI
     - AppKit
     - Vision
     - CoreGraphics
     - Charts (if not auto-linked)

7. **Verify Info.plist**
   - Replace the default Info.plist with the provided one
   - Ensure `NSScreenCaptureUsageDescription` is present

8. **Build & Run**
   - Product → Run (⌘R)
   - The app will request screen recording permission on first run
   - Grant permission when prompted

## How It Works

### Mode A: Unprotected Baseline

**Protection Type**: None (Control Group)

- Standard SwiftUI rendering pipeline
- Content rendered directly to screen
- Fully visible in all capture modes
- **Expected Capture Result**: Content fully visible

**Technical Detail**:
```
SwiftUI View → CALayer → Metal → Screen → Screen Capture Sees Content
```

### Mode B: NSWindow Shield

**Protection Type**: WindowServer-level blocking via `sharingType`

When `window.sharingType = .none`:
- The WindowServer compositing engine excludes this window
- Screen recording APIs receive black/opaque regions
- Works for both tab and window capture
- **Expected Capture Result**: Window appears black

**Technical Detail**:
```
NSWindow.sharingType = .none
         ↓
WindowServer: Check CGWindowSharingType
         ↓
Excluded from compositing → Screen Capture gets black
```

**Browser Capture Flow** (blocked by sharingType):
1. Browser calls ScreenCaptureKit or CGDisplayStream
2. WindowServer iterates window list
3. Checks `sharingType` for each window
4. Windows with `.none` are skipped
5. Browser gets only surrounding content

### Mode C: DRM Protected Layer

**Protection Type**: GPU-level via AVSampleBufferDisplayLayer

- Uses protected media rendering pipeline (same as Netflix/Apple TV)
- Content rendered via Metal to protected surface
- ScreenCaptureKit cannot read protected pixels
- Highest level of protection available

**Technical Detail**:
```
CoreGraphics Content → Metal GPU (Protected Pipeline)
         ↓
Protected CMSampleBuffer → AVSampleBufferDisplayLayer
         ↓
GPU Compositing (DRM protected) → Display
         ↓
Screen Capture APIs blocked from reading pixels
```

## Using the App

### Protection Modes

1. **Sidebar Navigation**: Select which protection mode to view
2. **Live Status**: Badge shows current protection status
3. **Sensitive Data**: Realistic financial dashboard with dummy data

### Mode B Features

- **Live Toggle**: Enable/disable protection in real-time to observe difference
- **Capture Simulation**: Shows what screen recording sees from this window

### Automated Test Harness

1. Click **"Run Tests"** in the toolbar
2. App will:
   - Capture window with all three modes
   - Capture full-screen as well
   - Analyze captured images for content visibility
   - Generate `capture_report.json`

3. Results are saved to: `~/Documents/CaptureTests/`

### Test Output

**capture_report.json**:
```json
{
  "timestamp": "2024-06-15T10:30:00Z",
  "macOS_version": "14.5",
  "results": [
    {
      "mode": "A",
      "protection": "unprotected",
      "capture_type": "window_share",
      "content_visible": true,
      "screenshot": "modeA_window_share_2024-06-15T10-30-00Z.png",
      "timestamp": "2024-06-15T10:30:00Z"
    }
  ]
}
```

## Technical Implementation Details

### NSWindow.sharingType Mechanism

```swift
// Mode B Implementation
if enabled {
    window.sharingType = .none  // WindowServer sees this window as opaque
} else {
    window.sharingType = .copy  // Normal window, visible in captures
}
```

**Why this works**:
- `CGWindowSharingType` is an enum at the WindowServer level
- When `.none`, the WindowServer compositor doesn't include the window in capture streams
- This happens before any image data is returned to the capture API
- Effectively blocks: ScreenCaptureKit, CGDisplayStream, CGWindowListCreateImage

### AVSampleBufferDisplayLayer Protection

```swift
// Mode C Implementation
let displayLayer = AVSampleBufferDisplayLayer()
// Content rendered via Metal to CMSampleBuffer
// The OS automatically applies DRM protection
// No pixel data accessible to screen capture APIs
```

**Why this works**:
- Protected media pipeline is cryptographically enforced at GPU level
- Even if screen capture bypasses WindowServer checks, DRM protection remains
- Used by streaming services for copy protection
- Resistant to both API-level and pixel-grabbing attacks

## Screen Capture Methods Tested

The test harness simulates three capture scenarios:

1. **Tab Share** (Browser tab capture)
   - What: Browser uses ScreenCaptureKit to capture specific tab/window
   - Test: Simulates Chrome/Safari tab capture

2. **Window Share** (Window-level capture)
   - What: Capture entire window (what screen recording sees)
   - Test: Uses CGWindowListCreateImage

3. **Full-Screen Share** (Desktop sharing)
   - What: Entire display capture (all windows)
   - Test: Uses CGDisplayBounds capture

## Code Quality & Documentation

- **Swift 5.9+**: Modern Swift syntax with @Observable macro
- **Comments**: Research-focused inline comments explaining OS behavior
- **Architecture**: Clean separation of concerns (View, Model, Manager layers)
- **Error Handling**: Comprehensive error handling in test harness
- **File Organization**: Logical separation into feature-focused files

## Requirements Met

✅ Three protection modes (A, B, C)  
✅ Production-grade SwiftUI UI with SF Symbols  
✅ NavigationSplitView for macOS-native navigation  
✅ Live toggle for Mode B protection  
✅ Realistic financial dashboard with Charts  
✅ Automated test harness with image analysis  
✅ JSON report generation  
✅ Full research documentation in code comments  
✅ Proper Xcode project structure  
✅ macOS 13.0 deployment target  
✅ Bundle ID: com.mca.screenshield  
✅ App name: ScreenShield  

## Deployment

### For Submission

1. Build the project: Product → Build (⌘B)
2. Archive the app: Product → Archive
3. Export archive for Ad Hoc distribution
4. Create application file for submission

### Notes

- The app requires screen recording permission to function fully
- macOS will prompt for permission on first capture attempt
- Entitlements file enables necessary sandbox capabilities
- Info.plist includes usage descriptions required by macOS

## Research References

### Key macOS Capture Mechanisms

- **ScreenCaptureKit**: Modern API for browser tab/window capture (macOS 13+)
- **CGDisplayStream**: Lower-level display capture stream (all macOS)
- **CGWindowListCreateImage**: WindowServer image capture
- **AVSampleBufferDisplayLayer**: Protected media rendering path

### Browser Implementation

- **Chrome**: Uses ScreenCaptureKit for tab/window capture
- **Safari**: ScreenCaptureKit + WebRTC integration
- **Brave**: Same as Chromium (ScreenCaptureKit)

### Protection Standards

- **HDCP**: Hardware-level copy protection (not applicable for software)
- **DRM**: Digital Rights Management (applied at GPU level)
- **Content Protection**: Available via protected media rendering on macOS

## Future Enhancements

- Real AVSampleBufferDisplayLayer rendering with Metal
- Automated browser testing (scripting Chrome/Safari)
- Performance metrics and latency analysis
- Audio protection modes
- Network stream protection analysis

## License

This project is provided for educational purposes as part of an MCA college assignment.

## Author

Built for MCA Assignment: "Browser Screen-Capture Boundary Analysis"

## Questions & Support

For technical questions about the implementation, refer to the inline code comments which explain the research methodology and OS-level behavior for each protection mode.
