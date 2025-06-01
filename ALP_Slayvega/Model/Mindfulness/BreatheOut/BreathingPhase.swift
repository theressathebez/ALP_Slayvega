//
//  BreathingPhase.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Foundation

enum BreathingPhase: CaseIterable {
    case inhale  // 4 seconds
    case hold  // 7 seconds
    case exhale  // 8 seconds
    case pause  // 2 seconds between cycles

    var duration: Double {
        switch self {
        case .inhale: return 4.0
        case .hold: return 7.0
        case .exhale: return 8.0
        case .pause: return 2.0
        }
    }

    var instruction: String {
        switch self {
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        case .pause: return "Relax"
        }
    }

    var description: String {
        switch self {
        case .inhale: return "Inhale through nose"
        case .hold: return "Hold your breath"
        case .exhale: return "Exhale through mouth"
        case .pause: return "Prepare for next cycle"
        }
    }
}
