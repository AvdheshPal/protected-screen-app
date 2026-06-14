# ScreenShield – File Reference Guide

Complete reference of all files in the ScreenShield project with descriptions and purposes.

---

## Swift Source Files (Core Application)

### ScreenShieldApp.swift (24 lines)
**Purpose**: Main application entry point

**Key Components**:
- `@main` attribute marking this as the app entry point
- `ScreenShieldApp` struct conforming to `App`
- WindowGroup scene with main ContentView
- Command overrides for app settings

**When to modify**: Changing app-level behavior, adding additional windows, modifying key commands

---

### AppModel.swift (73 lines)
**Purpose**: Application state management using Swift 5.9 @Observable macro

**Key Components**:
- `@Observable` class managing:
  - Active protection mode (A, B, or C)
  - Screen recording permission status
  - Test results and test running state
  - Error messages
  - Capture preview image
  - Mode B protection toggle state
- `ProtectionMode` enum with all three modes
- `CaptureTestResult` struct for test data

**When to modify**: Adding new app state, changing data structures, adding new features

**Important**: Uses @Observable (Swift 5.9+), must keep AppModel as Environment value

---

### ContentView.swift (206 lines)
**Purpose**: Main content view with navigation and test harness UI

**Key Components**:
- NavigationSplitView for sidebar + detail layout
- Sidebar with mode selection and permission status
- Detail area showing active mode view
- Toolbar with:
  - Permission status indicator
  - "Run Tests" button
  - "Results" button (when tests available)
- Test results sheet
- Methods:
  - `runTests()`: Triggers test harness
  - `openTestDirectory()`: Opens capture results folder
  - `formatDate()`: Formats timestamps

**When to modify**: Changing navigation structure, adding toolbar items, modifying test UI

---

### ModeAView.swift (175 lines)
**Purpose**: Unprotected Baseline mode - control group UI

**Key Components**:
- Security status card with "EXPOSED" badge
- Account information section
- Balance display section
- Transaction history (4 fake transactions)
- 30-day activity chart using Swift Charts
- Research explanation in comments

**What it demonstrates**: Baseline visibility level - all content visible in captures

**When to modify**: Changing appearance of unprotected view, updating dummy data, adjusting chart

**Important**: This is the CONTROL GROUP - should not have protection applied

---

### ModeBView.swift (245 lines)
**Purpose**: NSWindow Shield Protection mode with live toggle

**Key Components**:
- Security status card with "PROTECTED" badge
- Live protection toggle (enable/disable in real-time)
- "Capture Window Now" button for simulation
- Same financial dashboard UI as Mode A
- Capture preview display
- Methods:
  - `applyWindowProtection()`: Applies/removes sharingType protection
  - `captureAndPreview()`: Takes window capture for preview

**What it demonstrates**: 
- NSWindow.sharingType = .none protection
- Live toggle to show difference
- Visual comparison of what capture sees

**When to modify**: Changing protection UI, updating capture preview feature

**Important**: This is where the actual NSWindow protection is applied to the app window

---

### ModeCView.swift (231 lines)
**Purpose**: DRM Protected Layer mode explanation

**Key Components**:
- Security status card with "DRM PROTECTED" badge
- Protection explanation card with 4 key points
- Same financial dashboard UI
- Technical implementation details section
- Supporting components:
  - `ProtectionExplanationRow`
  - `TechnicalDetailRow`
  - `ProtectedDisplayLayer` class (placeholder)

**What it demonstrates**:
- Explanation of AVSampleBufferDisplayLayer
- Protected media rendering path
- GPU-level DRM protection concept

**When to modify**: Updating explanation text, adding technical details, implementing actual DRM layer

**Important**: Currently educational/explanatory - full AVSampleBufferDisplayLayer implementation would require Metal/GPU code

---

### WindowManager.swift (69 lines)
**Purpose**: Handles NSWindow operations including capture and protection

**Key Methods**:
- `applyWindowSharing(_:enabled:)`: Set window.sharingType
- `getWindowSharingType(_:)`: Get current sharing type
- `captureWindow(_:)`: Capture single window using CGWindowListCreateImage
- `captureFullScreen()`: Capture entire display

**Technical Detail**: 
- Uses CGWindowListCreateImage for synchronous capture
- Respects sharingType in results
- Returns NSImage for preview/analysis

**When to modify**: Adding new capture types, changing capture parameters, implementing new protection methods

**Important**: This is called by Mode B to apply protection and by test harness for capture

---

### CaptureTestHarness.swift (168 lines)
**Purpose**: Automated capture testing and analysis

**Key Components**:
- `CaptureTestHarness` class managing test execution
- Methods:
  - `runAllTests()`: Run all tests across all modes
  - `testMode()`: Test single mode with 3 capture types
  - `captureAndAnalyze()`: Capture and check if content visible
  - `analyzeContentVisibility()`: Image brightness analysis
  - `generateReport()`: Create JSON report

**Test Flow**:
1. For each mode (A, B, C)
2. For each capture type (tab, window, full-screen)
3. Capture the window
4. Analyze if content visible (brightness > threshold)
5. Save screenshot to ~/Documents/CaptureTests/
6. Generate capture_report.json

**When to modify**: Adding new analysis methods, changing detection thresholds, adding new capture types

**Important**: Runs on background thread (DispatchQueue.global), reports back on main thread

---

## Configuration Files

### Info.plist
**Purpose**: Application metadata and permissions

**Key Settings**:
- Bundle identifier: `com.mca.screenshield`
- Bundle name: ScreenShield
- Minimum macOS: 13.0
- `NSScreenCaptureUsageDescription`: Explains why app needs screen recording permission
- `NSLocalNetworkUsageDescription`: Local network usage explanation

**When to modify**: Changing app name, bundle ID, version, or permission descriptions

**Important**: Must be present for macOS to show permission prompts

---

### ScreenShield.entitlements
**Purpose**: App sandbox and security entitlements

**Key Entitlements**:
- `com.apple.security.app-sandbox`: Enable sandbox
- `com.apple.security.files.user-selected.read-write`: Access user-selected files
- `com.apple.security.files.downloads.read-write`: Access Downloads
- `com.apple.security.network.server/client`: Network access

**When to modify**: Adding camera/microphone, changing file access, modifying network permissions

**Important**: Must be linked in Xcode build settings under "Entitlements File"

---

## Documentation Files

### README.md (~300 lines)
**Purpose**: Main project documentation for users and developers

**Sections**:
- Project overview
- Research objectives
- Project structure
- Xcode setup instructions
- How each mode works (detailed)
- Using the app
- Technical implementation details
- Code quality notes
- Deployment instructions
- Future enhancements

**When to read**: First document to understand project scope and setup

**When to modify**: Updating instructions, adding new features, clarifying technical details

---

### XCODE_SETUP.md (~400 lines)
**Purpose**: Step-by-step Xcode integration guide

**Sections**:
- Prerequisites
- Create new project (detailed steps)
- Add source files
- Configure build settings
- Set up signing & capabilities
- Verify framework links
- Build & run
- Verify installation
- Troubleshooting (common issues and solutions)
- Development tips

**When to read**: Before creating Xcode project - comprehensive walkthrough

**When to modify**: If Xcode changes, if new frameworks needed, if new build settings required

---

### RESEARCH.md (~500 lines)
**Purpose**: Technical research documentation on screen capture in macOS

**Chapters**:
1. **Understanding Screen Capture**: WindowServer, capture APIs
2. **Mode A – Unprotected Baseline**: Technical flow, control group explanation
3. **Mode B – NSWindow Shield**: sharingType mechanism, how it protects
4. **Mode C – DRM Protected Layer**: AVSampleBufferDisplayLayer, GPU protection
5. **Experimental Methodology**: Test design, analysis algorithm
6. **Browser Implementation**: Chrome/Safari flow, why protections work
7. **Limitations & Attack Vectors**: Known weaknesses, theoretical attacks
8. **Research Insights**: Key findings
9. **Appendices**: References and documentation links

**When to read**: Understanding technical background, research questions, theoretical attacks

**When to modify**: Adding new research findings, updating technical details, adding references

---

### PROJECT_COMPLETION.md (~400 lines)
**Purpose**: Project summary and completion checklist

**Sections**:
- What has been built (features)
- File structure overview
- How to build & run
- Key technical implementations
- User experience flow
- Code architecture
- Documentation summary
- Deployment checklist
- Next steps for research

**When to read**: Getting overview of entire project, checklist before submission

---

### ARCHITECTURE.md (This file)
**Purpose**: Reference guide for all files and their purposes

**When to read**: Looking up specific file purposes, understanding project organization

---

## File Organization in Xcode

After setup, your Xcode project should look like:

```
ScreenShield
├── ScreenShield (Source Files Group)
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
├── ScreenShield.xcodeproj
│   ├── project.pbxproj
│   └── (scheme and workspace files)
├── README.md
├── XCODE_SETUP.md
├── RESEARCH.md
├── PROJECT_COMPLETION.md
└── ARCHITECTURE.md (this file)
```

---

## How Files Work Together

### Launch Sequence

```
1. ScreenShieldApp.swift
   ↓ (creates)
2. ContentView.swift
   ↓ (uses environment)
3. AppModel.swift (state)
   ↓ (shows)
4. ModeAView / ModeBView / ModeCView
   ↓ (calls when needed)
5. WindowManager.swift (protection/capture)
   ↓ (calls when testing)
6. CaptureTestHarness.swift (generates)
7. ~/Documents/CaptureTests/capture_report.json
```

### Data Flow

```
User selects mode
  ↓
AppModel.activeMode = .modeB
  ↓
ContentView updates detail view
  ↓
ModeBView displays with protection
  ↓
User clicks "Run Tests"
  ↓
CaptureTestHarness.runAllTests()
  ↓
WindowManager.captureWindow()
  ↓
Analyze with CaptureTestHarness.analyzeContentVisibility()
  ↓
AppModel.captureTestResults = results
  ↓
ContentView displays results sheet
```

---

## Modification Guide

### To add a new protection mode:

1. Create `ModeXView.swift` (copy ModeAView.swift as template)
2. Add `.modeX` to `ProtectionMode` enum in `AppModel.swift`
3. Add case in `ContentView.detailContent`
4. Add test in `CaptureTestHarness.runAllTests()`

### To modify UI appearance:

1. Edit colors in the respective ModeXView.swift
2. Modify chart data in chartData property
3. Change dummy financial data

### To change test harness behavior:

1. Edit `CaptureTestHarness.swift`
2. Modify brightness threshold in `analyzeContentVisibility()`
3. Change capture types tested

### To add new permissions:

1. Add to `Info.plist`
2. Add to `ScreenShield.entitlements`
3. Update `AppModel.checkScreenRecordingPermission()`

---

## File Statistics

| Category | Files | Lines |
|----------|-------|-------|
| Swift Source | 8 | ~1,200 |
| Configuration | 2 | ~50 |
| Documentation | 5 | ~2,000 |
| **Total** | **15** | **~3,250** |

---

## Dependencies

### External Frameworks (Standard Apple)

- **SwiftUI**: UI framework
- **AppKit**: NSWindow support
- **AVFoundation**: AVSampleBufferDisplayLayer
- **CoreGraphics**: CGWindowListCreateImage, image capture
- **Vision**: (imported for future image analysis)
- **Charts**: Swift Charts for data visualization
- **Foundation**: JSON encoding/decoding

### Project-Internal Dependencies

```
ScreenShieldApp
  → ContentView
    → AppModel
    → ModeAView
    → ModeBView (uses WindowManager)
    → ModeCView
    → CaptureTestHarness (uses WindowManager)
  → WindowManager (standalone utility)
```

---

## Next: How to Continue

1. **Understand the architecture**: Review this file
2. **Set up in Xcode**: Follow XCODE_SETUP.md
3. **Run the app**: Follow README.md
4. **Understand the code**: Read inline comments
5. **Understand the research**: Read RESEARCH.md
6. **Modify for your needs**: Use this reference guide

---

## Questions to Ask While Reading Code

- **Why is AppModel using @Observable instead of @State?** 
  → For shared state across multiple views

- **Why does Mode B have a live toggle?**
  → To demonstrate the protection in real-time

- **Why analyze image brightness in test harness?**
  → To programmatically detect if content is visible or protected

- **Why three capture types in tests?**
  → To simulate different real-world sharing scenarios

- **Why is CaptureTestHarness on a background thread?**
  → To avoid blocking the UI during image analysis

---

For detailed code-level questions, refer to the inline comments in each `.swift` file.

**Status**: Project complete and documented ✅
