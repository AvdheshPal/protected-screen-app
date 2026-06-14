import SwiftUI
import Charts

/// Mode B: NSWindow Shield Protection (Production-Grade)
/// This view renders the same sensitive financial data but applies robust NSWindow protection
/// with three protection levels:
/// - Level 0: Unprotected (baseline)
/// - Level 1: Blocked (appears black)
/// - Level 2: Invisible (complete protection across all screen share apps)
///
/// RESEARCH CONTEXT:
/// The sharingType property controls how the WindowServer compositing engine treats this window
/// for capture operations. When set to .none with additional collection behavior manipulation,
/// the window is excluded at multiple OS levels, making it invisible to all capture APIs
/// (ScreenCaptureKit, CGDisplayStream, CGWindowListCreateImage, etc.)
struct ModeBView: View {
    @Environment(AppModel.self) private var appModel
    @State private var protectionLevel: ProtectionLevel = .robustInvisible
    @State private var capturePreview: NSImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Security Status Card
            securityStatusCard
            
            // Main content area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Protection Level Selection
                    protectionLevelCard
                    
                    // Account Information (same as Mode A)
                    accountInfoSection
                    
                    // Balance Display
                    balanceSection
                    
                    // Transaction History
                    transactionHistorySection
                    
                    // Activity Chart
                    activityChartSection
                    
                    // Test Capture Simulation
                    captureSimulationSection
                }
                .padding(20)
            }
        }
        .onAppear {
            applyWindowProtection()
        }
    }
    
    // MARK: - Security Status Card
    private var securityStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mode B: NSWindow Shield (Production-Grade)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Multi-layer protection with robust invisibility across all screen sharing apps.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Protection badge - changes based on level
                HStack(spacing: 6) {
                    Image(systemName: protectionLevelBadgeIcon)
                        .foregroundColor(protectionLevelBadgeColor)
                    Text(protectionLevelBadgeText)
                        .font(.caption).bold()
                        .foregroundColor(protectionLevelBadgeColor)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(protectionLevelBadgeColor.opacity(0.1))
                .cornerRadius(6)
            }
            
            Divider()
            
            Text("RESEARCH NOTE: This production-grade protection uses multi-layer techniques including WindowServer-level sharingType blocking, collection behavior manipulation, and window level adjustment. Tested effective across Google Meet, Zoom, Brave, Chrome, Safari, and other screen sharing applications.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .padding(16)
    }
    
    // MARK: - Protection Level Card
    private var protectionLevelCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Protection Level")
                    .font(.headline)
            }
            
            // Segmented control for protection levels
            Picker("Protection Level", selection: $protectionLevel) {
                ForEach(ProtectionLevel.allCases, id: \.self) { level in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(level.displayName)
                            .font(.body)
                        Text(level.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .tag(level)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: protectionLevel) { oldValue, newValue in
                applyWindowProtection()
            }
            
            // Detailed explanation
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Protection Level Details")
                        .font(.caption).bold()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    protectionLevelExplanation
                }
                .padding(10)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(6)
            }
            
            // Test button
            Button(action: captureAndPreview) {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.screenshot")
                    Text("Capture Window Now")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(12)
        .background(Color.purple.opacity(0.05))
        .cornerRadius(6)
    }
    
    // MARK: - Protection Level Explanation
    @ViewBuilder
    private var protectionLevelExplanation: some View {
        switch protectionLevel {
        case .unprotected:
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Unprotected")
                        .font(.caption).bold()
                    Text("Window is fully visible in all screen shares")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
        case .blackedOut:
            HStack(spacing: 8) {
                Image(systemName: "eye.slash.fill")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blocked")
                        .font(.caption).bold()
                    Text("Window appears as black rectangle in captures")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
        case .robustInvisible:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Complete Invisibility")
                        .font(.caption).bold()
                    Text("Won't appear in screen share lists across all apps")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Badge Properties
    private var protectionLevelBadgeText: String {
        switch protectionLevel {
        case .unprotected:
            return "EXPOSED"
        case .blackedOut:
            return "BLOCKED"
        case .robustInvisible:
            return "INVISIBLE"
        }
    }
    
    private var protectionLevelBadgeColor: Color {
        switch protectionLevel {
        case .unprotected:
            return .orange
        case .blackedOut:
            return .yellow
        case .robustInvisible:
            return .green
        }
    }
    
    private var protectionLevelBadgeIcon: String {
        switch protectionLevel {
        case .unprotected:
            return "exclamationmark.triangle.fill"
        case .blackedOut:
            return "eye.slash.fill"
        case .robustInvisible:
            return "checkmark.shield.fill"
        }
    }
    
    // MARK: - Account Information Section
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Account Type")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Premium Checking")
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    Text("Account Number")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("**** **** 4821")
                        .fontWeight(.semibold)
                        .font(.system(.body, design: .monospaced))
                }
                
                Divider()
                
                HStack {
                    Text("Routing Number")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("**** **** 3456")
                        .fontWeight(.semibold)
                        .font(.system(.body, design: .monospaced))
                }
            }
            .padding(12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
        }
    }
    
    // MARK: - Balance Section
    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Balance")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current Balance")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$124,500.00")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.green)
                }
                
                Divider()
                
                HStack {
                    Text("Available Credit")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$25,000.00")
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    Text("Interest Rate")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("2.5% APY")
                        .fontWeight(.semibold)
                }
            }
            .padding(12)
            .background(Color.green.opacity(0.05))
            .cornerRadius(6)
        }
    }
    
    // MARK: - Transaction History Section
    private var transactionHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.headline)
            
            VStack(spacing: 8) {
                TransactionRowB(
                    description: "Salary Deposit",
                    amount: "+$5,000.00",
                    date: "Today",
                    amountColor: .green
                )
                
                Divider()
                
                TransactionRowB(
                    description: "Amazon Purchase",
                    amount: "-$87.50",
                    date: "Yesterday",
                    amountColor: .red
                )
                
                Divider()
                
                TransactionRowB(
                    description: "Starbucks",
                    amount: "-$6.25",
                    date: "2 days ago",
                    amountColor: .red
                )
                
                Divider()
                
                TransactionRowB(
                    description: "ATM Withdrawal",
                    amount: "-$200.00",
                    date: "3 days ago",
                    amountColor: .red
                )
            }
            .padding(12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
        }
    }
    
    // MARK: - Activity Chart Section
    private var activityChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("30-Day Account Activity")
                .font(.headline)
            
            Chart {
                ForEach(chartData, id: \.day) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(.blue.opacity(0.7))
                }
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: 8))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding(12)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
        }
    }
    
    // MARK: - Capture Simulation Section
    private var captureSimulationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capture Simulation")
                .font(.headline)
            
            if let preview = capturePreview {
                Image(nsImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(6)
                    .border(Color.gray.opacity(0.3), width: 1)
                
                Text("This is what a screen recording or browser capture sees from this window.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text("Click 'Capture Window Now' above to see what this window looks like in a screen capture at current protection level.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(6)
            }
        }
    }
    
    // Sample chart data
    private var chartData: [(day: String, amount: Double)] {
        [
            ("1", 1200), ("2", 1500), ("3", 1100), ("4", 1800),
            ("5", 2100), ("6", 1600), ("7", 1900), ("8", 2300),
            ("9", 2100), ("10", 1800), ("11", 2200), ("12", 2500)
        ]
    }
    
    // MARK: - Methods
    
    private func applyWindowProtection() {
        if let window = NSApplication.shared.windows.first {
            WindowManager.applyWindowProtection(window, level: protectionLevel)
        }
    }
    
    private func captureAndPreview() {
        if let window = NSApplication.shared.windows.first {
            capturePreview = WindowManager.captureWindow(window)
        }
    }
}

// MARK: - Transaction Row Component (Mode B)
private struct TransactionRowB: View {
    let description: String
    let amount: String
    let date: String
    let amountColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(description)
                    .fontWeight(.semibold)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(amount)
                .fontWeight(.semibold)
                .foregroundColor(amountColor)
        }
    }
}

#Preview {
    ModeBView()
        .environment(AppModel())
}
