import SwiftUI
import Charts

/// Mode A: Unprotected Baseline (Control Group)
/// This view renders sensitive financial data with NO protection applied.
/// All content is fully visible in screen recordings and browser capture.
struct ModeAView: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Security Status Card
            securityStatusCard
            
            // Main content area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Account Information
                    accountInfoSection
                    
                    // Balance Display
                    balanceSection
                    
                    // Transaction History
                    transactionHistorySection
                    
                    // Activity Chart
                    activityChartSection
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Security Status Card
    private var securityStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mode A: Unprotected Baseline")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Standard SwiftUI rendering. No protection applied (control group).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Protection badge
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("EXPOSED")
                        .font(.caption).bold()
                        .foregroundColor(.orange)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
            
            Divider()
            
            Text("RESEARCH NOTE: This mode demonstrates the baseline visibility level. Content is fully visible in all capture modes (tab share, window share, desktop share). This is the control group for comparing protection effectiveness.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .padding(16)
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
                TransactionRow(
                    description: "Salary Deposit",
                    amount: "+$5,000.00",
                    date: "Today",
                    amountColor: .green
                )
                
                Divider()
                
                TransactionRow(
                    description: "Amazon Purchase",
                    amount: "-$87.50",
                    date: "Yesterday",
                    amountColor: .red
                )
                
                Divider()
                
                TransactionRow(
                    description: "Starbucks",
                    amount: "-$6.25",
                    date: "2 days ago",
                    amountColor: .red
                )
                
                Divider()
                
                TransactionRow(
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
    
    // Sample chart data
    private var chartData: [(day: String, amount: Double)] {
        [
            ("1", 1200), ("2", 1500), ("3", 1100), ("4", 1800),
            ("5", 2100), ("6", 1600), ("7", 1900), ("8", 2300),
            ("9", 2100), ("10", 1800), ("11", 2200), ("12", 2500)
        ]
    }
}

// MARK: - Transaction Row Component
private struct TransactionRow: View {
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
    ModeAView()
        .environment(AppModel())
}
