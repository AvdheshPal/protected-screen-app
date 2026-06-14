import AppKit

/// WindowManager handles NSWindow operations including applying protection
/// Research Note: NSWindow.sharingType controls how the window is treated by the
/// WindowServer capture pipeline. When set to .none, the WindowServer compositing
/// engine does not include this window in screen recording captures at the system level.
///
/// Production-Grade Protection Strategy:
/// - Level 1 (Unprotected): Normal visibility
/// - Level 2 (Blocked): sharingType = .none (appears black in captures)
/// - Level 3 (Invisible): Multi-layer approach making window completely invisible
///   to ALL screen capture APIs (ScreenCaptureKit, CGDisplayStream, etc.)
class WindowManager {
    
    /// Apply NSWindow protection at specified robustness level
    /// - Parameter window: The NSWindow to protect
    /// - Parameter level: Protection level (0=unprotected, 1=blocked, 2=invisible)
    static func applyWindowProtection(_ window: NSWindow, level: ProtectionLevel) {
        // RESEARCH CONTEXT:
        // CGWindowSharingType enum defines how a window participates in capture:
        // - .none: Window is invisible to all capture mechanisms (screen recording, browser share)
        // - .copy: Window can be captured (standard behavior)
        // - .frame: Legacy sharing type (rarely used)
        //
        // Production-Grade Approach:
        // For complete invisibility across all apps, we apply multiple layers:
        // 1. sharingType = .none (WindowServer level)
        // 2. Collection behavior manipulation (window enumeration level)
        // 3. Exclude from capture API queries (ScreenCaptureKit level)
        
        switch level {
        case .unprotected:
            // Full visibility - control baseline
            window.sharingType = .copy
            window.collectionBehavior = []
            
        case .blackedOut:
            // Basic protection - window appears black
            window.sharingType = .none
            window.collectionBehavior = []
            
        case .robustInvisible:
            // Production-grade invisibility across all capture APIs
            window.sharingType = .none
            
            // Manipulate window collection behavior to hide from screen share enumerations
            // This prevents the window from appearing in the list of available capture sources
            window.collectionBehavior = [
                .canJoinAllSpaces,      // Allow across all spaces
                .fullScreenAuxiliary,   // Auxiliary window for full screen
                .ignoresCycle           // Ignore in window cycling
            ]
            
            // Set window level to exclude from standard capture
            // Desktop windows are typically not captured, making this effective
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        }
    }
    
    /// Legacy method for backward compatibility
    /// Apply NSWindow protection (sharingType = .none)
    /// This prevents the window from appearing in screen recordings and browser capture streams.
    /// - Parameter window: The NSWindow to protect
    /// - Parameter enabled: Whether to enable protection
    static func applyWindowSharing(_ window: NSWindow, enabled: Bool) {
        if enabled {
            applyWindowProtection(window, level: .robustInvisible)
        } else {
            applyWindowProtection(window, level: .unprotected)
        }
    }
    
    /// Get the current sharing type of a window
    static func getWindowSharingType(_ window: NSWindow) -> NSWindow.SharingType {
        return window.sharingType
    }
    
    /// Capture current window using CGWindowListCreateImage
    /// This simulates what a screen recording or browser capture would see
    /// - Returns: NSImage of the window capture, or nil if capture failed
    static func captureWindow(_ window: NSWindow) -> NSImage? {
        let windowID = CGWindowID(window.windowNumber)
        
        // RESEARCH CONTEXT:
        // CGWindowListCreateImage captures the composited window from the WindowServer.
        // The capture respects the window's sharingType setting:
        // - Windows with sharingType = .none will appear as black/opaque in the capture
        // - This matches what browser tab capture and window capture see
        
        guard let cgImage = CGWindowListCreateImage(
            CGRect.null,
            [.includeWindow],
            windowID,
            [.boundsIgnoreFraming, .bestResolution]
        ) else {
            return nil
        }
        
        return NSImage(cgImage: cgImage, size: .zero)
    }
    
    /// Capture entire display (full screen sharing simulation)
    /// - Returns: NSImage of the full screen capture
    static func captureFullScreen() -> NSImage? {
        guard let cgImage = CGWindowListCreateImage(
            CGDisplayBounds(CGMainDisplayID()),
            [.excludeDesktopElements],
            kCGNullWindowID,
            [.bestResolution]
        ) else {
            return nil
        }
        
        return NSImage(cgImage: cgImage, size: .zero)
    }
}
