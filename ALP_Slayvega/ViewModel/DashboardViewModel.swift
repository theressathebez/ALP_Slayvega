//
//  DashboardViewModel.swift
//  ALP_Slayvega
//
//  Created by Joy Luist on 05/06/25.
//

import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var currentStressLevel: Int = 0
    @Published var weeklyAverage: Double = 0.0
    @Published var weeklyRange = (min: 0, max: 0)
    @Published var stressCategory: String = "Low"
    @Published var weeklyData: [StressModel] = []
    @Published var isLoading = true

    private let stressVM = StressQuestionViewModel()

    // MARK: - Computed Properties

    var stressDistribution: (high: Int, medium: Int, normal: Int, low: Int) {
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

    var stressLevelColor: Color {
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

    var ringProgress: Double {
        let level = Double(currentStressLevel) / 10.0
        return min(level / 4.0, 1.0)
    }

    // MARK: - Public Methods

    func loadStressData(for userId: String) {
        guard !userId.isEmpty else { return }

        isLoading = true

        Task {
            await fetchAndProcessStressData()
        }
    }

    func refreshData() {
        Task {
            await fetchAndProcessStressData()
        }
    }

    // MARK: - Private Methods

    private func fetchAndProcessStressData() async {
        // Fetch all stress history for the user
        await stressVM.fetchStressHistory()

        // Debug: Print fetched data
        print(
            "DEBUG: Total stress history count: \(stressVM.stressHistory.count)"
        )
        for (index, stress) in stressVM.stressHistory.enumerated() {
            print(
                "DEBUG: Stress \(index): Level=\(stress.StressLevel), Timestamp=\(stress.timestamp ?? 0)"
            )
        }

        // Get latest stress level
        if let latest = await stressVM.getLatestStressLevel() {
            currentStressLevel = latest.level
            stressCategory = getStressCategory(from: latest.averageScore)
            print(
                "DEBUG: Latest stress - Level: \(latest.level), Category: \(latest.category)"
            )
        } else {
            print("DEBUG: No latest stress level found")
        }

        // Calculate weekly data (last 7 days)
        let weeklyStressData = getWeeklyStressData(from: stressVM.stressHistory)
        print("DEBUG: Weekly data count: \(weeklyStressData.count)")

        weeklyData = weeklyStressData
        calculateWeeklyStats()
        isLoading = false
    }

    private func getWeeklyStressData(from history: [StressModel])
        -> [StressModel]
    {
        let currentTime = Date().timeIntervalSince1970
        let oneWeekAgo = currentTime - (7 * 24 * 60 * 60)

        print("DEBUG: Current time: \(currentTime)")
        print("DEBUG: One week ago: \(oneWeekAgo)")

        let filteredData = history.filter { stress in
            guard let timestamp = stress.timestamp else {
                print("DEBUG: Stress data missing timestamp")
                return false
            }
            let stressTime = Double(timestamp)
            let isWithinWeek = stressTime >= oneWeekAgo
            print(
                "DEBUG: Stress timestamp: \(stressTime), within week: \(isWithinWeek)"
            )
            return isWithinWeek
        }

        print("DEBUG: Filtered weekly data count: \(filteredData.count)")
        return filteredData
    }

    private func calculateWeeklyStats() {
        guard !weeklyData.isEmpty else {
            weeklyAverage = 0.0
            weeklyRange = (min: 0, max: 0)
            return
        }

        let normalizedLevels = weeklyData.map { Double($0.StressLevel) / 10.0 }
        weeklyAverage =
            normalizedLevels.reduce(0, +) / Double(normalizedLevels.count)

        // Range menggunakan stress level asli
        let levels = weeklyData.map { $0.StressLevel }
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

    // Helper function untuk format weekly average dengan kategori yang benar
    var formattedWeeklyAverage: String {
        guard weeklyAverage > 0 else { return "0 Low" }
        let category = getStressCategory(from: weeklyAverage)
        return "\(Int(weeklyAverage * 10)) \(category)"
    }
}
