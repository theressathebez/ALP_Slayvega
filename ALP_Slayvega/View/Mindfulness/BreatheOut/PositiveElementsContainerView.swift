//
//  PositiveElementsContainerView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import SwiftUI

struct PositiveElementsContainerView: View {
    let elements: [PositiveElement]

    var body: some View {
        ZStack {
            ForEach(elements) { element in
                PositiveElementView(element: element)
            }
        }
        .frame(height: 100)
    }
}

#Preview {
    PositiveElementsContainerView(elements: [
        PositiveElement(
            symbol: "✨",
            offset: CGSize(width: 0, height: 0),
            opacity: 1.0,
            scale: 1.0
        ),
        PositiveElement(
            symbol: "🌟",
            offset: CGSize(width: 40, height: 20),
            opacity: 0.8,
            scale: 1.2
        ),
        PositiveElement(
            symbol: "💫",
            offset: CGSize(width: -20, height: -30),
            opacity: 0.9,
            scale: 1.1
        ),
    ])
    .background(Color.black)
}
