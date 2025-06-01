//
//  PositiveElementView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import SwiftUI

struct PositiveElementView: View {
    let element: PositiveElement

    var body: some View {
        Text(element.symbol)
            .font(.system(size: 24))
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.blue, Color.orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .offset(element.offset)
            .opacity(element.opacity)
            .scaleEffect(element.scale)
            .shadow(color: Color.blue.opacity(0.2), radius: 5)
            .animation(.easeOut(duration: 2.0), value: element.opacity)
    }
}

#Preview {
    PositiveElementView(
        element: PositiveElement(
            symbol: "✨",
            offset: CGSize(width: 0, height: 0),
            opacity: 1.0,
            scale: 1.0
        )
    )
    .background(Color.black)
}
