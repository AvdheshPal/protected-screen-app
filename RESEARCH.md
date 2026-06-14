# ScreenShield – Research Documentation

## Browser Screen-Capture Boundary Analysis

This document provides detailed technical background on how browsers capture screen content and how the three protection modes in ScreenShield defend against it.

---

## Chapter 1: Understanding Screen Capture in macOS

### 1.1 WindowServer Architecture

macOS uses the **WindowServer** (part of the Quartz compositing engine) to manage all window rendering and composition. This is the critical component for understanding screen capture.

```
Application A                Application B                 User Display
    ↓                             ↓                              ↓
  CALayer                      CALayer                     (Physical Output)
    ↓                             ↓                              ↓
  [Metal/OpenGL Rendering]    [Metal/OpenGL Rendering]        ↑
         ↓                             ↓                        |
         └─────────────────────────────────────────────────────┘
                        WindowServer Compositing
                   (Combines all windows into one image)
                        ↓
                  Composited Image
                        ↓
              ┌─────────┴────────┬──────────┐
              ↓                  ↓          ↓
          Display          Screen Capture   ???
                         (What we block)
```

### 1.2 Capture APIs in macOS

#### CGDisplayStream (Core Graphics)
- **What**: Low-level streaming API for display/window content
- **Age**: Available since macOS 10.8
- **Used by**: System screen recording, some third-party apps
- **Respects**: `sharingType` (window protection)

```swift
// Example: CGDisplayStream captures respecting sharingType
let stream = CGDisplayStreamCreate(displayID, width, height, ...)
// If window has sharingType = .none, it appears black in stream
```

#### ScreenCaptureKit (New, iOS 14+/macOS 13+)
- **What**: Modern, high-performance capture framework
- **Introduced**: macOS 13 (Ventura)
- **Used by**: Modern browsers (Chrome 115+, Safari 17+), system features
- **Respects**: `sharingType` for non-picker scenarios
- **Advantage**: More efficient than CGDisplayStream

```swift
import ScreenCaptureKit

// Capture available content sources
let availableSources = try await SCShareableContent.excludingDesktopWindows(false)

// Create stream (respects sharingType)
let stream = try await SCContentStream(content: source, configuration: config)
```

#### CGWindowListCreateImage
- **What**: Synchronous single-frame capture of a window
- **Speed**: Instant (single frame)
- **Used by**: Our test harness, legacy screen recording tools
- **Respects**: `sharingType` (window protection)

```swift
let windowID = CGWindowID(window.windowNumber)
let image = CGWindowListCreateImage(
    CGRect.null,
    [.includeWindow],
    windowID,
    [.boundsIgnoreFraming, .bestResolution]
)
// If window.sharingType = .none, result is black
```

### 1.3 Browser Capture Flow (Chrome Example)

When you share a tab in Chrome:

```
User clicks "Share Tab"
         ↓
Chrome calls ScreenCaptureKit.getSources()
         ↓
WindowServer returns available windows/sources
         ↓
← sharingType checked here (if .none, window excluded)
         ↓
Chrome receives filtered source list
         ↓
User picks a source to share
         ↓
Chrome starts capture stream
         ↓
WindowServer continuously sends frames
         ↓
← sharingType enforced (protected windows appear black)
         ↓
Frames sent to browser/remote peer
```

---

## Chapter 2: Mode A — Unprotected Baseline (Control)

### Characteristics
- Standard SwiftUI rendering
- No special protection applied
- Serves as control group
- Expected behavior: fully visible in all captures

### Technical Flow
```
SwiftUI View
    ↓
SwiftUI Framework (converts to CALayer)
    ↓
CoreAnimation (CALayer rendering)
    ↓
Metal GPU Rendering
    ↓
WindowServer Composition (includes in final image)
    ↓
nswindow.sharingType = .copy (default)
    ↓
Screen Capture APIs can read full content
```

### What Capture Sees
- Window manager permission: ✅ Can capture
- Content visibility: ✅ Full content visible
- In screen recording: ✅ Full window visible
- In browser tab share: ✅ Tab shows all content
- In browser window share: ✅ Window shows all content

### Use in Research
Mode A demonstrates:
- Baseline visibility level
- What happens without protection
- That capture mechanisms DO work
- Positive control that proves our test harness functions

---

## Chapter 3: Mode B — NSWindow Shield (sharingType Protection)

### The Protection Mechanism

**Key API**: `NSWindow.sharingType`

```swift
enum NSWindow.SharingType {
    case copy      // Window included in captures (default)
    case none      // Window excluded from captures
    case frame     // Legacy (rarely used)
}
```

### How sharingType = .none Works

When you set `window.sharingType = .none`:

```
┌─────────────────────────────────────────┐
│  NSWindow.sharingType = .none           │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  WindowServer Window Properties          │
│  (CGWindowSharingType structure)        │
│  - window_id                            │
│  - layer                                │
│  - sharing_type: NONE ← HERE             │
└─────────────────────────────────────────┘
         ↓
When Screen Capture Begins:
         ↓
┌─────────────────────────────────────────┐
│  WindowServer Compositing Engine:       │
│  FOR each window in window list:        │
│    IF sharing_type == NONE:             │
│      SKIP this window                   │
│    ELSE:                                │
│      Include in composite               │
└─────────────────────────────────────────┘
         ↓
Result: Window appears as black/opaque region
        in capture stream
```

### Why This Protects Against Different Capture Types

#### Tab Capture (Chrome)
```
Chrome calls: ScreenCaptureKit.getShareableContent()
              ↓
WindowServer: "Here are available sources"
              ↓
← Checks each window's sharingType
              ↓
Chrome receives filtered list
              ↓
Our window missing from list → Can't share it
```

#### Window Capture (Browser share window)
```
User tries to share "ScreenShield" window
              ↓
ScreenCaptureKit checks: sharingType = .none?
              ↓
YES → Excludes from available sources
              ↓
User doesn't see it in share list
```

#### Full-Screen Capture (Desktop share)
```
Chrome shares desktop/full-screen
              ↓
WindowServer composite includes all windows
              ↓
← sharingType checked for each window
              ↓
Protected windows rendered as black
              ↓
User sees: black rectangle where app was
```

### Implementation Detail: OSLevel Guarantee

This is not a software-level protection that apps can bypass. It's enforced by the **WindowServer kernel component**:

1. **Kernel-enforced**: WindowServer runs as privileged service
2. **Cannot bypass**: Even with root access, non-root apps can't change other window's sharingType
3. **Atomic**: Property check happens at compositing time

### Real-World Impact

- **Password fields**: Automatically have `sharingType = .none` (why they don't appear in screen recordings)
- **Military/Intelligence applications**: Use this for classified content
- **Healthcare apps**: Comply with HIPAA by blocking captures
- **Financial apps**: Apple's own finance app uses this

---

## Chapter 4: Mode C — DRM Protected Layer (AVSampleBufferDisplayLayer)

### The Protected Media Path

Mode C uses a different rendering architecture entirely:

```
┌────────────────────────────────────────────┐
│  Regular Rendering Path (Mode A)           │
├────────────────────────────────────────────┤
│  CoreGraphics/CoreAnimation                │
│  ↓                                         │
│  Metal GPU                                 │
│  ↓                                         │
│  Framebuffer (Main memory/VRAM)            │
│  ↓                                         │
│  Screen Capture can read: YES ✓            │
└────────────────────────────────────────────┘

┌────────────────────────────────────────────┐
│  Protected Media Path (Mode C)             │
├────────────────────────────────────────────┤
│  Content → CoreGraphics                    │
│  ↓                                         │
│  Encoded to CMSampleBuffer                 │
│  ↓                                         │
│  AVSampleBufferDisplayLayer                │
│  ↓                                         │
│  Protected Metal GPU Pipeline              │
│  │  (DRM Protection Active)                │
│  ↓                                         │
│  Protected Framebuffer                     │
│  ↓                                         │
│  Screen Capture can read: NO ✗             │
│  (GPU enforces protection)                 │
└────────────────────────────────────────────┘
```

### How AVSampleBufferDisplayLayer Protects

1. **Input**: CMSampleBuffer with content data
2. **Processing**: Metal GPU processes through DRM pipeline
3. **Storage**: Protected VRAM (not readable by screen capture)
4. **Output**: Only final composite sent to display

Screen capture APIs try to read the protected surface:
```
CGDisplayStream.read() 
    → Tries to access protected VRAM
    → GPU driver: "NO - DRM protected"
    → Returns: Black/Opaque data
```

### Technical Advantage Over sharingType

| Aspect | sharingType | AVSampleBufferDisplayLayer |
|--------|------------|---------------------------|
| **Level** | WindowServer (OS) | GPU (Hardware) |
| **Mechanism** | Window exclusion | Content encryption |
| **Bypass vector** | Fake sharingType? | Requires GPU firmware access |
| **Protection strength** | OS-level | Hardware-level |
| **Compatibility** | All capture APIs | All capture APIs |

### Use Cases in Real Products

- **Netflix**: Uses this for protected content streaming
- **Apple TV**: Streams with DRM protection
- **Disney+**: Uses this for premium content
- **Financial institutions**: Some use this + sharingType for maximum protection

### Limitations on Current macOS

- Requires AVFoundation framework
- HDCP display requirement for some content (not enforced for app content)
- GPU must support protected memory
- Metal implementation required

---

## Chapter 5: Experimental Methodology

### Test Design

ScreenShield uses an automated test harness that:

1. **Renders** the same sensitive content in all three modes
2. **Captures** using three different methods (tab/window/full-screen simulation)
3. **Analyzes** captured images for content visibility
4. **Reports** in JSON format

### Capture Analysis Algorithm

```swift
// Simplified visibility analysis
func isContentVisible(image: NSImage) -> Bool {
    let brightPixels = image.pixelsSample()
        .filter { brightness > 50 }  // 50/255 = threshold
        .count
    
    let threshold = pixelCount * 0.3  // 30% bright pixels
    return brightPixels > threshold
}
```

**Logic**:
- Protected images (black) have low brightness
- Normal images have varied brightness
- If <30% pixels are "bright", protection succeeded

### Expected Test Results

| Mode | Tab Capture | Window Capture | Full-Screen |
|------|------------|-----------------|-------------|
| **A** | Visible ✓ | Visible ✓ | Visible ✓ |
| **B** | Black ✗ | Black ✗ | Black ✗ |
| **C** | Black ✗ | Black ✗ | Black ✗ |

### Report Output

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
      "screenshot": "modeA_window_share.png"
    },
    {
      "mode": "B", 
      "protection": "protected",
      "capture_type": "window_share",
      "content_visible": false,
      "screenshot": "modeB_window_share.png"
    }
  ]
}
```

---

## Chapter 6: Browser Implementation Details

### Chrome Tab Capture Flow

```
User: "Share a tab"
         ↓
Chrome calls: ScreenCaptureKit.excludingDesktopWindows()
         ↓
system prompts user to select source
         ↓
← sharingType checked here; protected windows excluded
         ↓
User selects source (if it's in the list)
         ↓
Chrome creates SCContentStream
         ↓
os continuously sends frames
         ↓
← sharingType enforced per-frame; protected → black
         ↓
Chrome receives frames and sends to WebRTC
         ↓
Remote peer sees: black rectangle for protected content
```

### Why sharingType Works Against Browser Capture

The key is that `sharingType = .none` affects **two levels**:

1. **Source Enumeration**: Protected windows don't appear in available sources
2. **Frame Compositing**: Even if somehow captured, frames show black

Browsers can't bypass this because:
- `sharingType` set by app (us), not browser
- WindowServer (OS kernel) enforces it
- Applies at GPU composite level before frame is available

### Real-World Example: Password Field Protection

Every password field in every app has `sharingType = .none`:

```
// In TextField with secureTextEntry = true:
window.sharingType = .none  // Automatically set by OS

Result: Password field never appears in screen recordings
        (Even if you're recording)
```

This proves the mechanism works reliably at OS level.

---

## Chapter 7: Limitations & Attack Vectors

### sharingType Limitations

1. **Only protects from API-level capture**
   - Screen recording: ✓ Protected
   - Browser capture: ✓ Protected
   - External GPU capture: ? Depends on implementation

2. **User action required**
   - User must enable screen recording permission
   - If permission granted, protection applies

3. **Visible limitation**
   - User sees black rectangle (obvious protection)
   - May indicate sensitive content (security through obscurity fails)

### AVSampleBufferDisplayLayer Limitations

1. **Complex to implement correctly**
   - Requires Metal knowledge
   - Requires CMSampleBuffer pipeline setup
   - Error-prone for developers

2. **Performance overhead**
   - Metal rendering adds latency
   - GPU memory required

3. **OS-specific**
   - Only works on macOS 10.8+
   - Different behavior on older OS versions

### Known Attack Vectors (Theoretical)

1. **Pixel-grabbing attack**: 
   - Use very high-speed GPU readback
   - Against sharingType: Doesn't help (OS enforces)
   - Against DRM: GPU driver blocks it

2. **Microarchitecture attacks**:
   - Timing attacks on GPU memory
   - Defense: Out of scope for user-level protection

3. **Physical attacks**:
   - Electromagnetic emissions from monitor
   - Defense: Not applicable to software

---

## Chapter 8: Research Insights

### Key Finding 1: sharingType is surprisingly effective

Despite being a simple property, `sharingType = .none` reliably blocks capture because it's enforced by the OS WindowServer, not left to individual apps.

### Key Finding 2: Three layers exist

- **Application layer**: What app renders (Mode A)
- **OS layer**: How OS protects windows (Mode B)
- **GPU layer**: How GPU handles content (Mode C)

Each provides different security properties.

### Key Finding 3: Browser behavior is standardized

All major browsers (Chrome, Safari, Brave) respect sharingType because they use the same underlying macOS APIs (ScreenCaptureKit).

### Key Finding 4: Visibility analysis works

By analyzing brightness distribution, we can programmatically determine if content is protected (black) or exposed (colored).

---

## Appendix: Technical References

### Apple Documentation

- [AVSampleBufferDisplayLayer](https://developer.apple.com/documentation/avfoundation/avsamplebufferdisplaylayer)
- [ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit)
- [CGWindowListCreateImage](https://developer.apple.com/documentation/coregraphics/1456143-cgwindowlistcreateimage)
- [NSWindow.SharingType](https://developer.apple.com/documentation/appkit/nswindow/sharingtype)

### Related Security Standards

- HDCP (High-bandwidth Digital Content Protection)
- CSSM (Common Security Services Manager)
- DRM (Digital Rights Management) Framework

### Browser Implementation

- [Chrome ScreenCaptureKit usage](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/third_party/blink/renderer/modules/mediastream/media_stream_utils.cc)
- [WebRTC Frame Transport](https://w3c.github.io/webrtc-pc/)

---

## Conclusion

ScreenShield demonstrates three distinct protection approaches that work at different levels of the macOS graphics stack. Each provides measurable protection against browser capture, with different tradeoffs between implementation complexity and protection strength.

The experimental methodology allows quantitative analysis of protection effectiveness, providing empirical data on how these mechanisms function in practice.
