import SwiftUI
import Charts

/// Mode B: NSWindow Shield Protection
/// This view renders the same sensitive financial data but applies NSWindow.sharingType = .none
/// protection, which prevents the window from appearing in screen recordings and browser capture.
///
/// RESEARCH CONTEXT:
/// The sharingType property controls how the WindowServer compositing engine treats this window
/// for capture operations. When set to .none, the window is excluded at the OS level before
/// any capture data is composed, effectively rendering it invisible to screen recording APIs
/// like those used by browsers (Chrome, Safari, Brave).
struct ModeBView: View {
    @Environment(AppModel.self) private var appModel
    @State private var protectionActive = true
    @State private var capturePreview: NSImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Security Status Card
            securityStatusCard
            
            // Main content area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Live Protection Toggle
                    protectionToggleCard
                    
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
                    Text("Mode B: NSWindow Shield")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("NSWindow.sharingType set to .none. Blocks screen capture at WindowServer level.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Protection badge
                HStack(spacing: 6) {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.green)
                    Text(protectionActive ? "PROTECTED" : "EXPOSED")
                        .font(.caption).bold()
                        .foregroundColor(protectionActive ? .green : .orange)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background((protectionActive ? Color.green : Color.orange).opacity(0.1))
                .cornerRadius(6)
            }
            
            Divider()
            
            Text("RESEARCH NOTE: NSWindow protection is applied at the WindowServer level. When screen recording begins, the WindowServer checks each window's sharingType. Windows with .none are rendered as opaque black regions in the capture stream, similar to how password input fields appear.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .padding(16)
    }
    
    // MARK: - Protection Toggle Card
    private var protectionToggleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Live Protection Toggle")
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $protectionActive)
                    .onChange(of: protectionActive) { oldValue, newValue in
                        applyWindowProtection()
                    }
            }
            
            Text("Toggle to observe the difference in capture behavior. When enabled, screen captures will show black. When disabled, content becomes visible.")
                .font(.caption)
                .foregroundColor(.secondary)
            
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
        .background(Color.blue.opacity(0.05))
        .cornerRadius(6)
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
                Text("Click 'Capture Window Now' above to see what this window looks like in a screen capture.")
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
            WindowManager.applyWindowSharing(window, enabled: protectionActive)
        }
    }
    
    private func captureAndPreview() {
        if let window = NSApplication.shared.windows.first {
            capturePreview = WindowManager.captureWindow(window)
        }
    }
}

// MARK: - Transaction Row Component
private struct TransactionRowB: View {
    let description: String
    let amount: String
    let date: String
    let amountColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
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
