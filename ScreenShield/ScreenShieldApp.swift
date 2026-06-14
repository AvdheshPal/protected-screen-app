import SwiftUI

/// Main application entry point for ScreenShield
/// This is a research + engineering project for MCA assignment: "Browser Screen-Capture Boundary Analysis"
///
/// The app demonstrates three distinct screen capture protection strategies:
/// 1. Mode A: Unprotected baseline (control group)
/// 2. Mode B: NSWindow sharingType protection (WindowServer-level blocking)
/// 3. Mode C: AVSampleBufferDisplayLayer (GPU-level DRM-like protection)
///
/// Research focus: Testing visibility under browser tab sharing, window sharing, and desktop sharing
@main
struct ScreenShieldApp: App {
    @State private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .frame(minWidth: 1200, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Preferences") {
                    // Placeholder for future preferences window
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
