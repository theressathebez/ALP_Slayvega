//
//  MindfulnessCardView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MindfulnessCardView: View {
    var mind: MindfulnessModel

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: mind.iconName)
                .font(.title2)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 4) {
                Text(mind.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(mind.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 1.0, green: 0.56, blue: 0.427))
        .cornerRadius(12)
    }
}

#Preview {
    MindfulnessCardView(
        mind: MindfulnessModel(
            iconName: "wind",
            title: "Inhale",
            description: "Breathe in slowly and deeply."
        )
    )
}
