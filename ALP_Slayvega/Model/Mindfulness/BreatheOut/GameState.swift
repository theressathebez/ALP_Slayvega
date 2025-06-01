//
//  GameState.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Foundation
import SwiftUI

struct GameState {
    var isBreathing = false
    var breathingRadius: CGFloat = 80
    var activePressures: [PeerPressure] = []
    var positiveElements: [PositiveElement] = []
    var backgroundColors: [Color] = [Color.gray.opacity(0.8), Color.gray.opacity(0.6)]
    var progress: Double = 0.0
    var showReflection = false
    var currentReflection = ""
    var reflectionScale: CGFloat = 1.0
    var gameStartTime: Date?
    
    var isGameActive: Bool {
        !showReflection && gameStartTime != nil
    }
}
