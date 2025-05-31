//
//  ColorHex.swift
//  ALP_Slayvega
//
//  Created by Kevin  Dwi on 30/05/25.
//


import SwiftUI

extension Color {
    /// Mengonversi kode hex string menjadi warna `Color`.
    static func fromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        case 8: // ARGB
            (a, r, g, b) = ((int >> 24) & 0xff, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        default:
            (a, r, g, b) = (255, 255, 255, 255) // fallback: putih
        }

        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Custom Colors
    static let cardGradientTop = Color.fromHex("#FFEFF2")
    static let cardGradientBottom = Color.fromHex("#FFFFFF")
    static let cardText = Color.fromHex("#4A4A4A")
    static let cardSubtitle = Color.fromHex("#8E8E93")
    static let cardBorder = Color.fromHex("#D9D9D9")
    // Tambahkan ke dalam extension Color
    static let stressLow = Color.fromHex("#78A4EA")     // Biru muda
    static let stressNormal = Color.fromHex("#F36E92")  // Pink
    static let stressMedium = Color.fromHex("#FFE601")  // Kuning
    static let stressHigh = Color.fromHex("#FF8F6D")    // Oranye

}


