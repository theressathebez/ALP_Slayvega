//
//  Color.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import Foundation
import SwiftUI

extension Color {
    func mix(with color: Color, amount: Double) -> Color {
        let clampedAmount = max(0, min(1, amount))
        return Color(
            red: self.components.red * (1 - clampedAmount) + color.components
                .red * clampedAmount,
            green: self.components.green * (1 - clampedAmount) + color
                .components.green * clampedAmount,
            blue: self.components.blue * (1 - clampedAmount) + color.components
                .blue * clampedAmount
        )
    }

    var components: (red: Double, green: Double, blue: Double, alpha: Double) {
        #if canImport(UIKit)
            let uiColor = UIColor(self)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return (Double(red), Double(green), Double(blue), Double(alpha))
        #else
            return (0, 0, 0, 1)  // Fallback for non-UIKit platforms
        #endif
    }
}
