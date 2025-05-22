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
        StressQuestionModel(questionText: "I feel overwhelmed with my daily responsibilities."),
        StressQuestionModel(questionText: "I find it difficult to relax."),
        StressQuestionModel(questionText: "I get irritated easily."),
        StressQuestionModel(questionText: "I feel anxious even without a clear reason."),
        StressQuestionModel(questionText: "I struggle to sleep due to racing thoughts.")
    ]
    
    @Published var answers: [UUID: Int] = [:]

    var totalScore: Int {
        answers.values.reduce(0, +)
    }
    
    var stressLevel: String {
        let average = Double(totalScore) / Double(questions.count)
        switch average {
        case 0..<1.5:
            return "Low"
        case 1.5..<2.5:
            return "Moderate"
        case 2.5..<3.5:
            return "High"
        default:
            return "Very High"
        }
    }
}
