import AppKit

/// WindowManager handles NSWindow operations including applying protection
/// Research Note: NSWindow.sharingType controls how the window is treated by the
/// WindowServer capture pipeline. When set to .none, the WindowServer compositing
/// engine does not include this window in screen recording captures at the system level.
class WindowManager {
    /// Apply NSWindow protection (sharingType = .none)
    /// This prevents the window from appearing in screen recordings and browser capture streams.
    /// - Parameter window: The NSWindow to protect
    /// - Parameter enabled: Whether to enable protection
    static func applyWindowSharing(_ window: NSWindow, enabled: Bool) {
        // RESEARCH CONTEXT:
        // CGWindowSharingType enum defines how a window participates in capture:
        // - .none: Window is invisible to all capture mechanisms (screen recording, browser share)
        // - .copy: Window can be captured (standard behavior)
        // - .frame: Legacy sharing type (rarely used)
        //
        // When browsers (Chrome, Safari, Brave) use ScreenCaptureKit or CGDisplayStream APIs,
        // they iterate through the WindowServer's window list. Windows with sharingType = .none
        // are excluded at the WindowServer level before the image is even composited.
        
        if enabled {
            window.sharingType = .none
        } else {
            window.sharingType = .copy
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
