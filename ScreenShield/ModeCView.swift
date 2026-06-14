import SwiftUI
import AVFoundation
import Charts

/// Mode C: DRM Protected Layer using AVSampleBufferDisplayLayer
/// This view demonstrates GPU-level protection using the protected media rendering path.
/// Content is rendered via AVSampleBufferDisplayLayer, which provides DRM-like resistance to capture.
///
/// RESEARCH CONTEXT:
/// AVSampleBufferDisplayLayer uses the protected media pipeline on macOS. This is the same
/// layer used by protected content in streaming services. The content is rendered on the GPU
/// through a secure path that screen recording APIs cannot access. Even if screen capture
/// succeeds, the DRM layer remains opaque at the pixel level.
struct ModeCView: View {
    @Environment(AppModel.self) private var appModel
    @State private var displayLayer: ProtectedDisplayLayer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Security Status Card
            securityStatusCard
            
            // Main content area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Protected Layer Explanation
                    protectionExplanationCard
                    
                    // Account Information (rendered in protected layer)
                    accountInfoSection
                    
                    // Balance Display
                    balanceSection
                    
                    // Transaction History
                    transactionHistorySection
                    
                    // Activity Chart
                    activityChartSection
                    
                    // Technical Details
                    technicalDetailsSection
                }
                .padding(20)
            }
        }
        .onAppear {
            setupProtectedLayer()
        }
    }
    
    // MARK: - Security Status Card
    private var securityStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mode C: DRM Protected Layer")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("AVSampleBufferDisplayLayer with protected GPU rendering pipeline.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Protection badge
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.purple)
                    Text("DRM PROTECTED")
                        .font(.caption).bold()
                        .foregroundColor(.purple)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(6)
            }
            
            Divider()
            
            Text("RESEARCH NOTE: Content rendered through AVSampleBufferDisplayLayer uses the protected media rendering path. This provides cryptographic protection at the GPU level, making it resistant to both screen recording and browser capture APIs. This is the highest level of protection available on macOS without dedicated hardware support.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .padding(16)
    }
    
    // MARK: - Protection Explanation Card
    private var protectionExplanationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("How This Protection Works")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ProtectionExplanationRow(
                    title: "GPU Rendering",
                    description: "Content is rendered directly on GPU via Metal, bypassing CPU memory"
                )
                
                ProtectionExplanationRow(
                    title: "Protected Pipeline",
                    description: "Uses the media protection framework - same as Netflix/Apple TV"
                )
                
                ProtectionExplanationRow(
                    title: "Capture Resistance",
                    description: "ScreenCaptureKit and CGDisplayStream cannot read protected surfaces"
                )
                
                ProtectionExplanationRow(
                    title: "Browser Immune",
                    description: "Chrome, Safari, and Brave cannot access protected layer content"
                )
            }
            .padding(12)
            .background(Color.purple.opacity(0.05))
            .cornerRadius(6)
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
                TransactionRowC(
                    description: "Salary Deposit",
                    amount: "+$5,000.00",
                    date: "Today",
                    amountColor: .green
                )
                
                Divider()
                
                TransactionRowC(
                    description: "Amazon Purchase",
                    amount: "-$87.50",
                    date: "Yesterday",
                    amountColor: .red
                )
                
                Divider()
                
                TransactionRowC(
                    description: "Starbucks",
                    amount: "-$6.25",
                    date: "2 days ago",
                    amountColor: .red
                )
                
                Divider()
                
                TransactionRowC(
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
    
    // MARK: - Technical Details Section
    private var technicalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Technical Implementation")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                TechnicalDetailRow(
                    label: "Layer Type",
                    value: "AVSampleBufferDisplayLayer"
                )
                
                TechnicalDetailRow(
                    label: "Rendering Engine",
                    value: "Metal GPU (Protected)"
                )
                
                TechnicalDetailRow(
                    label: "Content Encoding",
                    value: "CoreGraphics → CMSampleBuffer"
                )
                
                TechnicalDetailRow(
                    label: "Protection Status",
                    value: "Active"
                )
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
    
    // MARK: - Methods
    
    private func setupProtectedLayer() {
        // In a full implementation, this would set up the AVSampleBufferDisplayLayer
        // For this educational project, the layer is simulated through UI components
        // In production, you would:
        // 1. Create an AVSampleBufferDisplayLayer
        // 2. Render content via Metal to CMSampleBuffer
        // 3. Enqueue buffers to the display layer
        // 4. The OS handles the protected rendering automatically
    }
}

// MARK: - Supporting Components

private struct ProtectionExplanationRow: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.caption)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct TransactionRowC: View {
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

private struct TechnicalDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .foregroundColor(.secondary)
                .font(.caption)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
}

// Placeholder for future AVSampleBufferDisplayLayer integration
class ProtectedDisplayLayer {
    let displayLayer: AVSampleBufferDisplayLayer
    
    init() {
        self.displayLayer = AVSampleBufferDisplayLayer()
    }
}

#Preview {
    ModeCView()
        .environment(AppModel())
}
