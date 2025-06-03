//
//  BackgroundView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import SwiftUI

struct BackgroundView: View {
    @State private var animateGradient = false

    var body: some View {
        TimelineView(.animation) { timeline in
            let date = timeline.date.timeIntervalSinceReferenceDate
            let xOffset = CGFloat(sin(date / 6) * 0.15)
            let yOffset = CGFloat(cos(date / 8) * 0.1)

            ZStack {
                // Moving gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.2),
                        Color.purple.opacity(0.2),
                        Color.orange.opacity(0.2),
                        Color.white.opacity(0.1),
                    ]),
                    startPoint: UnitPoint(x: 0.0 + xOffset, y: 0.0 + yOffset),
                    endPoint: UnitPoint(x: 1.0 + xOffset, y: 1.0 + yOffset)
                )
                .ignoresSafeArea()

                // Soft overlay for depth
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.05),
                        Color.clear,
                    ]),
                    center: UnitPoint(x: 0.5 - xOffset, y: 0.4 - yOffset),
                    startRadius: 100,
                    endRadius: 500
                )
                .blendMode(.overlay)
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    BackgroundView()
}
