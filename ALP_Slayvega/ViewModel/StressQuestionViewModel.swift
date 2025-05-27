//
//  StressQuestionViewModel.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import Foundation
import SwiftUI

class StressQuestionViewModel: ObservableObject {
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
}
