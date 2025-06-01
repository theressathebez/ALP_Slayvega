//
//  GameConfiguration.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Foundation

struct GameConfiguration {
    static let gameDuration: TimeInterval = 180 // 3 minutes
    static let pressureSpawnInterval: TimeInterval = 5.0
    static let breathingRadiusExpanded: CGFloat = 120
    static let breathingRadiusNormal: CGFloat = 80
    
    static let pressureTexts = [
        "Harus sukses sebelum umur 25...",
        "Teman-temanku sudah kerja, aku belum...",
        "Harus posting sesuatu keren tiap hari...",
        "Kenapa aku belum punya pacar?",
        "Semua orang lebih pintar dariku...",
        "Aku harus selalu terlihat bahagia...",
        "Hidupku tidak semenarik orang lain...",
        "Aku tertinggal dari teman-teman...",
        "Harus punya banyak pencapaian...",
        "Kenapa aku tidak sepopuler mereka?"
    ]
    
    static let reflectionMessages = [
        "You are exactly where you need to be.",
        "Your journey is unique and valuable.",
        "Progress isn't always visible, but it's happening.",
        "You don't need to prove anything to anyone.",
        "Your worth isn't measured by others' expectations.",
        "Every small step counts.",
        "You are enough, just as you are."
    ]
    
    static let positiveSymbols = ["🌸", "⭐", "☁️", "🦋", "✨", "🌿"]
}
