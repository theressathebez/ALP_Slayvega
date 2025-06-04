import FirebaseAuth
import SwiftUI

struct DashboardView: View {
    @StateObject private var dashboardVM = DashboardViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isNavigating = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                if dashboardVM.isLoading {
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
                                .trim(from: 0, to: dashboardVM.ringProgress)
                                .stroke(
                                    dashboardVM.stressLevelColor, lineWidth: 16
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 120, height: 120)
                                .animation(
                                    .easeInOut(duration: 1.0),
                                    value: dashboardVM.ringProgress)

                            VStack(spacing: 4) {
                                Text("Stress Level")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(dashboardVM.currentStressLevel)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.fromHex("#2C2C45"))
                                Text(dashboardVM.stressCategory)
                                    .font(.caption2)
                                    .foregroundColor(
                                        dashboardVM.stressLevelColor)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            StressRangeRow(
                                color: .stressHigh,
                                label: "High",
                                range: "35–40",
                                percent:
                                    "\(dashboardVM.stressDistribution.high)%"
                            )
                            StressRangeRow(
                                color: .stressMedium,
                                label: "Medium",
                                range: "28–34",
                                percent:
                                    "\(dashboardVM.stressDistribution.medium)%"
                            )
                            StressRangeRow(
                                color: .stressNormal,
                                label: "Normal",
                                range: "20–27",
                                percent:
                                    "\(dashboardVM.stressDistribution.normal)%"
                            )
                            StressRangeRow(
                                color: .stressLow,
                                label: "Low",
                                range: "10–19",
                                percent:
                                    "\(dashboardVM.stressDistribution.low)%"
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
                            Text(dashboardVM.formattedWeeklyAverage)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.fromHex("#2C2C45"))
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly Range")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(
                                "\(dashboardVM.weeklyRange.min) – \(dashboardVM.weeklyRange.max)"
                            )
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.fromHex("#2C2C45"))
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Tests")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(dashboardVM.weeklyData.count)")
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
                dashboardVM.loadStressData(for: authVM.myUser.uid)
            }
            .onChange(of: authVM.myUser.uid) { _ in
                dashboardVM.loadStressData(for: authVM.myUser.uid)
            }
        }
        .navigationDestination(isPresented: $isNavigating) {
            CheckStressLevelView()
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
