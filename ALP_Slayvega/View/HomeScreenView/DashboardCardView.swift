import SwiftUI

struct DashboardView: View {
    let stressLevel: Int = 27
    let weeklyAverage: Int = 27
    let weeklyRange = (15, 65)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Ring Chart + Stress Info
            HStack(alignment: .center, spacing: 24) {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: 0.67)
                        .stroke(Color.stressLow, lineWidth: 16)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0.67, to: 0.97)
                        .stroke(Color.stressNormal, lineWidth: 16)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0.97, to: 1.0)
                        .stroke(Color.stressMedium, lineWidth: 16)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 120, height: 120)

                    VStack(spacing: 4) {
                        Text("Stress Level")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(stressLevel)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.fromHex("#2C2C45"))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    StressRangeRow(color: .stressHigh, label: "High", range: "80–99", percent: "0%")
                    StressRangeRow(color: .stressMedium, label: "Medium", range: "60–79", percent: "3%")
                    StressRangeRow(color: .stressNormal, label: "Normal", range: "30–59", percent: "30%")
                    StressRangeRow(color: .stressLow, label: "Low", range: "01–29", percent: "67%")
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
                    Text("\(weeklyAverage) Low")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.fromHex("#2C2C45"))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Range")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(weeklyRange.0) – \(weeklyRange.1)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.fromHex("#2C2C45"))
                }
            }

            // Calibrate Button
            Button(action: {
                // Action here
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
}
