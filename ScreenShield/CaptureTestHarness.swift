import Foundation
import AppKit
import Vision

/// Automated capture test harness
/// Performs programmatic screen captures and analyzes content visibility
/// Outputs results to JSON report at ~/Documents/CaptureTests/capture_report.json
class CaptureTestHarness {
    /// Results from all capture attempts
    private var results: [CaptureTestResult] = []
    
    /// Directory for saving test artifacts
    private let testsDirectory: URL
    
    init() {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.testsDirectory = docDir.appendingPathComponent("CaptureTests")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: testsDirectory, withIntermediateDirectories: true)
    }
    
    /// Run all capture tests (simulating tab share, window share, and full-screen share)
    func runAllTests(appWindow: NSWindow, completion: @escaping ([CaptureTestResult], Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var allResults: [CaptureTestResult] = []
            
            // Test Mode A with all capture types
            allResults.append(contentsOf: self.testMode(mode: .modeA, window: appWindow))
            
            // Test Mode B with all capture types
            allResults.append(contentsOf: self.testMode(mode: .modeB, window: appWindow))
            
            // Test Mode C with all capture types
            allResults.append(contentsOf: self.testMode(mode: .modeC, window: appWindow))
            
            // Generate JSON report
            self.generateReport(results: allResults)
            
            DispatchQueue.main.async {
                completion(allResults, nil)
            }
        }
    }
    
    /// Test a specific mode with different capture types
    /// For Mode B, also tests each protection level separately
    private func testMode(mode: ProtectionMode, window: NSWindow) -> [CaptureTestResult] {
        var modeResults: [CaptureTestResult] = []
        
        // For Mode B, test each protection level separately
        if mode == .modeB {
            for protectionLevel in ProtectionLevel.allCases {
                // Apply the protection level
                WindowManager.applyWindowProtection(window, level: protectionLevel)
                
                // Wait briefly for the protection to be applied
                Thread.sleep(forTimeInterval: 0.2)
                
                // Test with each capture type
                let tabCaptureResult = captureAndAnalyze(
                    mode: mode,
                    protectionLevel: protectionLevel,
                    captureType: "tab_share",
                    window: window
                )
                modeResults.append(tabCaptureResult)
                
                let windowCaptureResult = captureAndAnalyze(
                    mode: mode,
                    protectionLevel: protectionLevel,
                    captureType: "window_share",
                    window: window
                )
                modeResults.append(windowCaptureResult)
                
                let fullScreenCaptureResult = captureAndAnalyze(
                    mode: mode,
                    protectionLevel: protectionLevel,
                    captureType: "full_screen_share",
                    window: window
                )
                modeResults.append(fullScreenCaptureResult)
            }
        } else {
            // For Modes A and C, use standard testing
            let tabCaptureResult = captureAndAnalyze(
                mode: mode,
                captureType: "tab_share",
                window: window
            )
            modeResults.append(tabCaptureResult)
            
            let windowCaptureResult = captureAndAnalyze(
                mode: mode,
                captureType: "window_share",
                window: window
            )
            modeResults.append(windowCaptureResult)
            
            let fullScreenCaptureResult = captureAndAnalyze(
                mode: mode,
                captureType: "full_screen_share",
                window: window
            )
            modeResults.append(fullScreenCaptureResult)
        }
        
        return modeResults
    }
    
    /// Capture window and analyze if content is visible
    private func captureAndAnalyze(
        mode: ProtectionMode,
        protectionLevel: ProtectionLevel? = nil,
        captureType: String,
        window: NSWindow
    ) -> CaptureTestResult {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let levelSuffix = protectionLevel != nil ? "_\(protectionLevel!.displayName)" : ""
        let filename = "mode\(mode.rawValue.uppercased())\(levelSuffix)_\(captureType)_\(timestamp.replacingOccurrences(of: ":", with: "-")).png"
        
        // Capture the window
        var capturedImage: NSImage?
        var contentVisible = false
        
        if captureType == "full_screen_share" {
            capturedImage = WindowManager.captureFullScreen()
        } else {
            capturedImage = WindowManager.captureWindow(window)
        }
        
        // Analyze if content is visible
        if let image = capturedImage {
            contentVisible = analyzeContentVisibility(image)
            
            // Save the screenshot
            if let tiffData = image.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                let filePath = testsDirectory.appendingPathComponent(filename)
                try? pngData.write(to: filePath)
            }
        }
        
        return CaptureTestResult(
            mode: mode.rawValue,
            protection: protectionLevel != nil ? protectionLevel!.displayName : (mode.isProtected ? "protected" : "unprotected"),
            captureType: captureType,
            contentVisible: contentVisible,
            screenshot: filename,
            timestamp: timestamp
        )
    }
    
    /// Analyze captured image to determine if content is visible
    /// Returns true if non-trivial content is detected (not all black/uniform)
    private func analyzeContentVisibility(_ image: NSImage) -> Bool {
        // RESEARCH METHODOLOGY:
        // We analyze the captured image histogram. If the image is predominantly black
        // (as would be the case with sharingType = .none), the histogram will show
        // most pixels in the 0-20 brightness range.
        // Non-protected content will have a more distributed histogram.
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return false
        }
        
        // Create a simple brightness analysis
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        guard let ctx = context else { return false }
        
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = ctx.data else { return false }
        
        let buffer = data.assumingMemoryBound(to: UInt8.self)
        var brightPixels = 0
        let pixelCount = width * height
        
        // Sample pixels to determine if image is mostly uniform (black = protected, colored = visible)
        for i in stride(from: 0, to: pixelCount * 4, by: 4) {
            let r = buffer[i]
            let g = buffer[i + 1]
            let b = buffer[i + 2]
            
            // Calculate brightness (luminance)
            let brightness = Int(Double(r) * 0.299 + Double(g) * 0.587 + Double(b) * 0.114)
            
            if brightness > 50 {  // Threshold for "bright enough to indicate content"
                brightPixels += 1
            }
        }
        
        // If more than 30% of pixels are above the brightness threshold, content is visible
        let contentVisibilityThreshold = Double(pixelCount) * 0.3
        return Double(brightPixels) > contentVisibilityThreshold
    }
    
    /// Generate JSON report of all test results
    private func generateReport(results: [CaptureTestResult]) {
        let macOSVersion = ProcessInfo.processInfo.operatingSystemVersionString
        
        let reportData: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "macOS_version": macOSVersion,
            "results": results.map { result -> [String: Any] in
                [
                    "mode": result.mode,
                    "protection": result.protection,
                    "capture_type": result.captureType,
                    "content_visible": result.contentVisible,
                    "screenshot": result.screenshot,
                    "timestamp": result.timestamp
                ]
            }
        ]
        
        let reportURL = testsDirectory.appendingPathComponent("capture_report.json")
        
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: reportData,
                options: [.prettyPrinted, .sortedKeys]
            )
            try jsonData.write(to: reportURL)
        } catch {
            print("Failed to write report: \(error)")
        }
    }
}
