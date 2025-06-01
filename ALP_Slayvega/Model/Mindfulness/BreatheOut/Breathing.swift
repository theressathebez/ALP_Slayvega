//
//  Breathing.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Foundation

enum Breathing: CaseIterable {
    case inhale, hold, exhale
    
    var title: String {
        switch self {
        case .inhale: return "Breath In"
        case .hold: return "Hold"
        case .exhale: return "Breath Out"
        }
    }
    
    var duration: Double {
        switch self {
        case .inhale: return 4.0
        case .hold: return 7.0
        case .exhale: return 8.0
        }
    }
}
