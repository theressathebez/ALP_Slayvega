import FirebaseAuth
import SwiftUI

struct DashboardView: View {
    @StateObject private var stressVM = StressQuestionViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    @State private var currentStressLevel: Int = 0
    @State private var weeklyAverage: Double = 0.0
    @State private var weeklyRange = (min: 0, max: 0)
    @State private var stressCategory: String = "Low"
    @State private var weeklyData: [StressModel] = []
    @State private var isNavigating = false
    @State private var isLoading = true

    // Calculate stress distribution percentages
    private var stressDistribution:
        (high: Int, medium: Int, normal: Int, low: Int)
    {
        guard !weeklyData.isEmpty else { return (0, 0, 0, 100) }

        let total = weeklyData.count
        var high = 0
        var medium = 0
        var normal = 0
        var low = 0

        for stress in weeklyData {
            let level = Double(stress.StressLevel) / 10.0
            switch level {
            case 3.5...:
                high += 1
            case 2.8..<3.5:
                medium += 1
            case 2.0..<2.8:
                normal += 1
            default:
                low += 1
            }
        }

        return (
            high: Int((Double(high) / Double(total)) * 100),
            medium: Int((Double(medium) / Double(total)) * 100),
            normal: Int((Double(normal) / Double(total)) * 100),
            low: Int((Double(low) / Double(total)) * 100)
        )
    }

    // Get stress level color based on current level
    private var stressLevelColor: Color {
        let level = Double(currentStressLevel) / 10.0
        switch level {
        case 3.5...:
            return .stressHigh
        case 2.8..<3.5:
            return .stressMedium
        case 2.0..<2.8:
            return .stressNormal
        default:
            return .stressLow
        }
    }

    // Calculate ring progress based on stress level
    private var ringProgress: Double {
        let level = Double(currentStressLevel) / 10.0
        return min(level / 4.0, 1.0)  // Normalize to 0-1 range
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                if isLoading {
                    // Loading state
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading stress data...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    // Ring Chart + Stress Info
                    HStack(alignment: .center, spacing: 24) {
                        ZStack {
                            // Background circle
                            Circle()
                                .trim(from: 0, to: 1)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                                .frame(width: 120, height: 120)

                            // Progress circle
                            Circle()
                                .trim(from: 0, to: ringProgress)
                                .stroke(stressLevelColor, lineWidth: 16)
                                .rotationEffect(.degrees(-90))
                                .frame(width: 120, height: 120)
                                .animation(
                                    .easeInOut(duration: 1.0),
                                    value: ringProgress)

                            VStack(spacing: 4) {
                                Text("Stress Level")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(currentStressLevel)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.fromHex("#2C2C45"))
                                Text(stressCategory)
                                    .font(.caption2)
                                    .foregroundColor(stressLevelColor)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            StressRangeRow(
                                color: .stressHigh,
                                label: "High",
                                range: "35–40",
                                percent: "\(stressDistribution.high)%"
                            )
                            StressRangeRow(
                                color: .stressMedium,
                                label: "Medium",
                                range: "28–34",
                                percent: "\(stressDistribution.medium)%"
                            )
                            StressRangeRow(
                                color: .stressNormal,
                                label: "Normal",
                                range: "20–27",
                                percent: "\(stressDistribution.normal)%"
                            )
                            StressRangeRow(
                                color: .stressLow,
                                label: "Low",
                                range: "10–19",
                                percent: "\(stressDistribution.low)%"
                            )
                        }
                        .padding(.trailing, 10)
                    }

                    Divider()

                    // Weekly Summary
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly Avg.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(
                                "\(Int(weeklyAverage)) \(getStressCategory(from: weeklyAverage))"
                            )
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.fromHex("#2C2C45"))
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly Range")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(weeklyRange.min) – \(weeklyRange.max)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.fromHex("#2C2C45"))
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Tests")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(weeklyData.count)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.fromHex("#2C2C45"))
                        }
                    }
                }

                // Calibrate Button
                Button(action: {
                    isNavigating.toggle()
                }) {
                    Text("Calibrate")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.fromHex("#FF8F6D"))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .onAppear {
                loadStressData()
            }
            .onChange(of: authVM.myUser.uid) { _ in
                // Reload data when user changes
                loadStressData()
            }
        }
        .navigationDestination(isPresented: $isNavigating) {
            CheckStressLevelView()
        }
    }

    // MARK: - Helper Methods

    private func loadStressData() {
        guard !authVM.myUser.uid.isEmpty else { return }

        isLoading = true

        Task {
            // Fetch all stress history for the user
            await stressVM.fetchStressHistory()

            // Get latest stress level
            if let latest = await stressVM.getLatestStressLevel() {
                await MainActor.run {
                    currentStressLevel = latest.level
                    stressCategory = getStressCategory(
                        from: latest.averageScore)
                }
            }

            // Calculate weekly data (last 7 days)
            let weeklyStressData = getWeeklyStressData(
                from: stressVM.stressHistory)

            await MainActor.run {
                weeklyData = weeklyStressData
                calculateWeeklyStats()
                isLoading = false
            }
        }
    }

    private func getWeeklyStressData(from history: [StressModel])
        -> [StressModel]
    {
        let oneWeekAgo = Date().timeIntervalSince1970 - (7 * 24 * 60 * 60)

        return history.filter { stress in
            guard let timestamp = stress.timestamp else { return false }
            return Double(timestamp) >= oneWeekAgo
        }
    }

    private func calculateWeeklyStats() {
        guard !weeklyData.isEmpty else {
            weeklyAverage = 0.0
            weeklyRange = (min: 0, max: 0)
            return
        }

        let levels = weeklyData.map { $0.StressLevel }
        weeklyAverage = Double(levels.reduce(0, +)) / Double(levels.count)
        weeklyRange = (min: levels.min() ?? 0, max: levels.max() ?? 0)
    }

    private func getStressCategory(from score: Double) -> String {
        switch score {
        case 0..<2.0:
            return "Low"
        case 2.0..<2.8:
            return "Normal"
        case 2.8..<3.5:
            return "Medium"
        default:
            return "High"
        }
    }
}

struct StressRangeRow: View {
    let color: Color
    let label: String
    let range: String
    let percent: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(range)
                .font(.caption)
                .foregroundColor(.gray)
            Text(percent)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
