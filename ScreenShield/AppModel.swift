import SwiftUI
import Combine
import AVFoundation

/// Application state model using Swift 5.9 @Observable macro
/// Manages protection modes, test harness state, and permission tracking
@Observable
final class AppModel {
    /// Current active protection mode (A, B, or C)
    var activeMode: ProtectionMode = .modeA
    
    /// Tracks whether screen recording permission is granted
    var screenRecordingPermissionGranted: Bool = false
    
    /// Current capture test results
    var captureTestResults: [CaptureTestResult] = []
    
    /// Whether a test is currently running
    var isTestRunning: Bool = false
    
    /// Error message from last test run, if any
    var testErrorMessage: String?
    
    /// Live capture preview from CGWindowListCreateImage
    var capturePreviewImage: NSImage?
    
    /// Protection level for Mode B (0 = unprotected, 1 = blacked out, 2 = invisible)
    var modeBProtectionLevel: ProtectionLevel = .robustInvisible
    
    /// Reference to the main app window for capture operations
    var mainAppWindow: NSWindow?
    
    init() {
        checkScreenRecordingPermission()
    }
    
    /// Check if screen recording permission is granted by testing CGWindowListCreateImage
    private func checkScreenRecordingPermission() {
        DispatchQueue.global().async {
            let windows = CGWindowListCopyWindowInfo([.excludeDesktopElements], kCGNullWindowID)
            if windows != nil {
                DispatchQueue.main.async {
                    self.screenRecordingPermissionGranted = true
                }
            }
        }
    }
    
    /// Request screen recording permission (OS 14.0+)
    func requestScreenRecordingPermission() {
        // In macOS, screen recording permission is typically requested automatically
        // when first using screen capture APIs. This is a placeholder for future
        // permission UI if needed.
        checkScreenRecordingPermission()
    }
}

/// Enum representing the three protection modes
enum ProtectionMode: String, CaseIterable {
    case modeA = "A"
    case modeB = "B"
    case modeC = "C"
    
    var displayName: String {
        switch self {
        case .modeA:
            return "Mode A: Unprotected Baseline"
        case .modeB:
            return "Mode B: NSWindow Shield (Robust)"
        case .modeC:
            return "Mode C: DRM Protected Layer"
        }
    }
    
    var description: String {
        switch self {
        case .modeA:
            return "Standard SwiftUI rendering. Content is fully visible in all capture modes (control group)."
        case .modeB:
            return "Robust NSWindow protection with multi-layer invisibility. Works across all screen sharing apps."
        case .modeC:
            return "AVSampleBufferDisplayLayer with protected media pipeline. GPU-level resistance to capture."
        }
    }
    
    var isProtected: Bool {
        self != .modeA
    }
}

/// Protection levels for Mode B - increasingly robust invisibility
enum ProtectionLevel: Int, CaseIterable {
    case unprotected = 0
    case blackedOut = 1
    case robustInvisible = 2
    
    var displayName: String {
        switch self {
        case .unprotected:
            return "Unprotected (Visible)"
        case .blackedOut:
            return "Blocked (Shows Black)"
        case .robustInvisible:
            return "Invisible (Complete Protection)"
        }
    }
    
    var description: String {
        switch self {
        case .unprotected:
            return "Content fully visible - control baseline"
        case .blackedOut:
            return "Appears as black rectangle in captures"
        case .robustInvisible:
            return "Completely invisible - won't appear in any screen share"
        }
    }
}

/// Result from a single capture test
struct CaptureTestResult: Codable {
    let mode: String
    let protection: String
    let captureType: String
    let contentVisible: Bool
    let screenshot: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case mode, protection
        case captureType = "capture_type"
        case contentVisible = "content_visible"
        case screenshot, timestamp
    }
}
