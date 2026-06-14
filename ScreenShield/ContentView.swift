import SwiftUI

/// Main content view with NavigationSplitView for mode selection
/// Integrates the three protection modes and the automated test harness
struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @State private var testHarness: CaptureTestHarness?
    @State private var showTestResults = false
    @State private var selectedResult: CaptureTestResult?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            sidebarContent
        } detail: {
            // Main content area
            detailContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationTitle("ScreenShield")
        .toolbar {
            toolbarContent
        }
        .onAppear {
            testHarness = CaptureTestHarness()
            // Store the main window for capture operations
            if let window = NSApplication.shared.windows.first {
                appModel.mainAppWindow = window
            }
        }
        .sheet(isPresented: $showTestResults) {
            testResultsSheet
        }
    }
    
    // MARK: - Sidebar Content
    @ViewBuilder
    private var sidebarContent: some View {
        List(selection: $appModel.activeMode) {
            Section {
                ForEach(ProtectionMode.allCases, id: \.self) { mode in
                    NavigationLink(value: mode) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.displayName)
                                    .fontWeight(.semibold)
                                
                                HStack(spacing: 6) {
                                    Image(systemName: mode.isProtected ? "shield.fill" : "exclamationmark.triangle.fill")
                                        .font(.caption)
                                    
                                    Text(mode.isProtected ? "Protected" : "Unprotected")
                                        .font(.caption)
                                }
                                .foregroundColor(mode.isProtected ? .green : .orange)
                            }
                            
                            Spacer()
                            
                            // Status indicator badge
                            if mode == appModel.activeMode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Protection Modes")
                    Spacer()
                    if appModel.screenRecordingPermissionGranted {
                        Label("Enabled", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Label("No Permission", systemImage: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    // MARK: - Detail Content (Main View)
    @ViewBuilder
    private var detailContent: some View {
        switch appModel.activeMode {
        case .modeA:
            ModeAView()
        case .modeB:
            ModeBView()
        case .modeC:
            ModeCView()
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            HStack(spacing: 12) {
                // Permission Status
                HStack(spacing: 6) {
                    Image(systemName: appModel.screenRecordingPermissionGranted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(appModel.screenRecordingPermissionGranted ? .green : .orange)
                    
                    Text(appModel.screenRecordingPermissionGranted ? "Recording Permission: Enabled" : "Recording Permission: Request")
                        .font(.caption)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)
                
                Divider()
                    .frame(height: 20)
                
                // Test Harness Button
                Button(action: runTests) {
                    HStack(spacing: 6) {
                        if appModel.isTestRunning {
                            ProgressView()
                                .scaleEffect(0.8, anchor: .center)
                        } else {
                            Image(systemName: "wand.and.rays")
                        }
                        Text(appModel.isTestRunning ? "Running Tests..." : "Run Tests")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(appModel.isTestRunning)
                
                // View Results Button
                if !appModel.captureTestResults.isEmpty {
                    Button(action: { showTestResults = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.bar")
                            Text("Results (\(appModel.captureTestResults.count))")
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - Test Results Sheet
    @ViewBuilder
    private var testResultsSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary stats
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tests Run")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(appModel.captureTestResults.count)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Content Visible")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(appModel.captureTestResults.filter { $0.contentVisible }.count)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Protected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(appModel.captureTestResults.filter { !$0.contentVisible }.count)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
                }
                .padding(16)
                
                Divider()
                
                // Results list
                List(appModel.captureTestResults, id: \.timestamp) { result in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Mode \(result.mode)")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: result.contentVisible ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                    .foregroundColor(result.contentVisible ? .orange : .green)
                                
                                Text(result.contentVisible ? "Exposed" : "Protected")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background((result.contentVisible ? Color.orange : Color.green).opacity(0.1))
                            .cornerRadius(4)
                        }
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Label("Capture: \(result.captureType)", systemImage: "camera.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Label(result.screenshot, systemImage: "photo")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Text(formatDate(result.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                }
                .listStyle(.inset)
            }
            .navigationTitle("Capture Test Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showTestResults = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: openTestDirectory) {
                        Label("Open Results", systemImage: "folder")
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func runTests() {
        guard let harness = testHarness, let window = appModel.mainAppWindow else { return }
        
        appModel.isTestRunning = true
        appModel.testErrorMessage = nil
        
        harness.runAllTests(appWindow: window) { results, error in
            appModel.captureTestResults = results
            appModel.isTestRunning = false
            
            if let error = error {
                appModel.testErrorMessage = error.localizedDescription
            }
        }
    }
    
    private func openTestDirectory() {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let testsURL = docsURL.appendingPathComponent("CaptureTests")
        NSWorkspace.shared.open(testsURL)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    ContentView()
        .environment(AppModel())
}
