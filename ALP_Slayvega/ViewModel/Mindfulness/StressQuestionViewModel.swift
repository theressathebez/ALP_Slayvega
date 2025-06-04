//
//  StressQuestionViewModel.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation
import SwiftUI

class StressQuestionViewModel: ObservableObject {
    private let database = Database.database().reference()
    
    @Published var questions: [StressQuestionModel] = [
        StressQuestionModel(
            questionText:
                "When there is a problem, I can always look on the bright side"
        ),
        StressQuestionModel(
            questionText: "I feel overwhelmed with my daily responsibilities"
        ),
        StressQuestionModel(
            questionText: "I find it difficult to relax even during free time"
        ),
        StressQuestionModel(
            questionText: "I get irritated easily over small things"
        ),
        StressQuestionModel(
            questionText: "I feel anxious even without a clear reason"
        ),
        StressQuestionModel(
            questionText: "I struggle to sleep due to racing thoughts"
        ),
        StressQuestionModel(questionText: "I can handle whatever comes my way"),
        StressQuestionModel(
            questionText: "I feel confident in my ability to solve problems"
        ),
        StressQuestionModel(
            questionText: "I worry about things that are out of my control"
        ),
        StressQuestionModel(
            questionText: "I feel physically tense most of the time"
        ),
    ]

    @Published var answers: [UUID: Int] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var stressHistory: [StressModel] = []

    var totalScore: Int {
        answers.values.reduce(0, +)
    }

    var averageScore: Double {
        guard !answers.isEmpty else { return 0 }
        return Double(totalScore) / Double(answers.count)
    }

    var stressLevel: String {
        let average = averageScore
        switch average {
        case 0..<2.0:
            return "Low Stress"
        case 2.0..<2.8:
            return "Moderate Stress"
        case 2.8..<3.5:
            return "High Stress"
        default:
            return "Very High Stress"
        }
    }

    var stressLevelBars: Int {
        switch stressLevel {
        case "Low Stress": return 1
        case "Moderate Stress": return 2
        case "High Stress": return 3
        case "Very High Stress": return 4
        default: return 0
        }
    }

    var stressDescription: String {
        switch stressLevel {
        case "Low Stress":
            return "You're managing stress well. Keep up the good work!"
        case "Moderate Stress":
            return
                "You're experiencing some stress. Consider incorporating relaxation techniques."
        case "High Stress":
            return
                "You're experiencing significant stress. It may be helpful to explore stress management strategies."
        case "Very High Stress":
            return
                "You're experiencing very high levels of stress. Consider speaking with a mental health professional."
        default:
            return "Assessment incomplete."
        }
    }

    var completionPercentage: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(answers.count) / Double(questions.count)
    }

    var isComplete: Bool {
        return answers.count == questions.count
    }

    func resetAssessment() {
        answers.removeAll()
    }

    // Method to get stress level color
    var stressLevelColor: Color {
        switch stressLevel {
        case "Low Stress":
            return .green
        case "Moderate Stress":
            return .yellow
        case "High Stress":
            return .orange
        case "Very High Stress":
            return .red
        default:
            return .gray
        }
    }
    
    // MARK: - Firebase Database Methods
    
    // Save stress result to Firebase Realtime Database
    func saveStressResult() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "No user logged in"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let stressLevelInt = Int(averageScore * 10) // Convert to integer for storage
        
        let stressData: [String: Any] = [
            "StressLevel": stressLevelInt,
            "averageScore": averageScore,
            "stressCategory": stressLevel,
            "userId": userId,
            "timestamp": timestamp,
            "createdAt": ISO8601DateFormatter().string(from: Date())
        ]
        
        // Generate unique key for this stress result
        let stressResultRef = database.child("users").child(userId).child("stress_results").childByAutoId()
        let stressId = stressResultRef.key ?? UUID().uuidString
        
        do {
            // Save to stress_results
            try await stressResultRef.setValue(stressData)
            
            // Update user's latest stress information
            let userLatestStress: [String: Any] = [
                "latestStressLevel": stressLevelInt,
                "latestStressCategory": stressLevel,
                "latestAverageScore": averageScore,
                "lastStressCheckDate": ISO8601DateFormatter().string(from: Date()),
                "lastStressCheckTimestamp": timestamp
            ]
            
            try await database.child("users").child(userId).child("stressInfo").setValue(userLatestStress)
            
            DispatchQueue.main.async {
                self.isLoading = false
                print("Stress result saved successfully with ID: \(stressId)")
            }
            
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to save stress result: \(error.localizedDescription)"
                print("Error saving stress result: \(error)")
            }
        }
    }
    
    // Fetch user's stress history from Firebase
    func fetchStressHistory() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "No user logged in"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let snapshot = try await database.child("users").child(userId).child("stress_results")
                .queryOrdered(byChild: "userId")
                .queryEqual(toValue: userId)
                .getData()
            
            var history: [StressModel] = []
            
            if let data = snapshot.value as? [String: [String: Any]] {
                for (key, value) in data {
                    let stress = StressModel(
                        StressId: key,
                        StressLevel: value["StressLevel"] as? Int ?? 0,
                        userId: value["userId"] as? String ?? "",
                        timestamp: value["timestamp"] as? Int
                    )
                    history.append(stress)
                }
                
                // Sort by timestamp descending (newest first)
                history.sort { ($0.timestamp ?? 0) > ($1.timestamp ?? 0) }
            }
            
            DispatchQueue.main.async {
                self.stressHistory = history
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to fetch stress history: \(error.localizedDescription)"
                print("Error fetching stress history: \(error)")
            }
        }
    }
    
    // Get user's latest stress level
    func getLatestStressLevel() async -> (level: Int, category: String, averageScore: Double)? {
        guard let userId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "No user logged in"
            }
            return nil
        }
        
        do {
            let snapshot = try await database.child("users").child(userId).child("stressInfo").getData()
            
            if let data = snapshot.value as? [String: Any] {
                let level = data["latestStressLevel"] as? Int ?? 0
                let category = data["latestStressCategory"] as? String ?? ""
                let averageScore = data["latestAverageScore"] as? Double ?? 0.0
                return (level: level, category: category, averageScore: averageScore)
            }
            
            return nil
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch latest stress level: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    // Delete a specific stress result (if needed)
    func deleteStressResult(stressId: String) async {
        guard Auth.auth().currentUser != nil else {
            DispatchQueue.main.async {
                self.errorMessage = "No user logged in"
            }
            return
        }
        
        do {
            try await database.child("stress_results").child(stressId).removeValue()
            
            // Refresh the history after deletion
            await fetchStressHistory()
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete stress result: \(error.localizedDescription)"
            }
        }
    }
    
    // Get stress statistics (average, trend, etc.)
    func getStressStatistics() -> (average: Double, trend: String, totalAssessments: Int) {
        guard !stressHistory.isEmpty else {
            return (average: 0, trend: "No data", totalAssessments: 0)
        }
        
        let levels = stressHistory.map { Double($0.StressLevel) / 10.0 }
        let average = levels.reduce(0, +) / Double(levels.count)
        
        var trend = "Stable"
        if stressHistory.count >= 2 {
            let recent = Array(levels.prefix(3)) // Last 3 assessments
            let older = Array(levels.suffix(from: min(3, levels.count)))
            
            let recentAvg = recent.reduce(0, +) / Double(recent.count)
            let olderAvg = older.reduce(0, +) / Double(older.count)
            
            if recentAvg > olderAvg + 0.3 {
                trend = "Increasing"
            } else if recentAvg < olderAvg - 0.3 {
                trend = "Decreasing"
            }
        }
        
        return (average: average, trend: trend, totalAssessments: stressHistory.count)
    }
    
    // MARK: - Dashboard Integration Methods
    
    // Get weekly stress data for dashboard
    func getWeeklyStressData() async -> [StressModel] {
        await fetchStressHistory()
        
        let oneWeekAgo = Date().timeIntervalSince1970 - (7 * 24 * 60 * 60)
        
        return stressHistory.filter { stress in
            guard let timestamp = stress.timestamp else { return false }
            return Double(timestamp) >= oneWeekAgo
        }
    }
    
    // Get monthly stress data for trends
    func getMonthlyStressData() async -> [StressModel] {
        await fetchStressHistory()
        
        let oneMonthAgo = Date().timeIntervalSince1970 - (30 * 24 * 60 * 60)
        
        return stressHistory.filter { stress in
            guard let timestamp = stress.timestamp else { return false }
            return Double(timestamp) >= oneMonthAgo
        }
    }
    
    // Calculate stress distribution for dashboard
    func calculateStressDistribution(from data: [StressModel]) -> (high: Int, medium: Int, normal: Int, low: Int) {
        guard !data.isEmpty else { return (0, 0, 0, 100) }
        
        let total = data.count
        var high = 0, medium = 0, normal = 0, low = 0
        
        for stress in data {
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
    
    // Get current user's latest stress data for dashboard
    func getCurrentUserStressData() async -> (level: Int, category: String, weeklyAvg: Double, range: (Int, Int))? {
        guard Auth.auth().currentUser != nil else { return nil }
        
        // Get latest stress level
        guard let latest = await getLatestStressLevel() else { return nil }
        
        // Get weekly data
        let weeklyData = await getWeeklyStressData()
        
        var weeklyAvg: Double = 0.0
        var range = (0, 0)
        
        if !weeklyData.isEmpty {
            let levels = weeklyData.map { $0.StressLevel }
            weeklyAvg = Double(levels.reduce(0, +)) / Double(levels.count)
            range = (levels.min() ?? 0, levels.max() ?? 0)
        }
        
        return (
            level: latest.level,
            category: latest.category,
            weeklyAvg: weeklyAvg,
            range: range
        )
    }
    
    // Check if user needs to calibrate (no recent stress data)
    func shouldPromptCalibration() async -> Bool {
        guard Auth.auth().currentUser != nil else { return false }
        
        let threeDaysAgo = Date().timeIntervalSince1970 - (3 * 24 * 60 * 60)
        
        do {
            let snapshot = try await database.child("users")
                .child(Auth.auth().currentUser?.uid ?? "")
                .child("stressInfo")
                .child("lastStressCheckTimestamp")
                .getData()
            
            if let lastCheck = snapshot.value as? Int {
                return Double(lastCheck) < threeDaysAgo
            }
            
            return true // No previous check found
        } catch {
            return true // Error fetching, suggest calibration
        }
    }
    
    // Get stress trend (increasing, decreasing, stable)
    func getStressTrend() -> String {
        guard stressHistory.count >= 3 else { return "Insufficient data" }
        
        let recentData = Array(stressHistory.prefix(3)) // Last 3 assessments
        let levels = recentData.map { Double($0.StressLevel) / 10.0 }
        
        // Calculate trend
        let firstHalf = levels[0]
        let lastHalf = levels[2]
        
        let difference = lastHalf - firstHalf
        
        if difference > 0.5 {
            return "Increasing"
        } else if difference < -0.5 {
            return "Decreasing"
        } else {
            return "Stable"
        }
    }
    
    // Format stress level for display
    func formatStressLevel(_ level: Int) -> String {
        let normalizedLevel = Double(level) / 10.0
        switch normalizedLevel {
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
    
    // Get color for stress level
    func getColorForStressLevel(_ level: Int) -> Color {
        let normalizedLevel = Double(level) / 10.0
        switch normalizedLevel {
        case 0..<2.0:
            return .green
        case 2.0..<2.8:
            return .blue
        case 2.8..<3.5:
            return .orange
        default:
            return .red
        }
    }
}
