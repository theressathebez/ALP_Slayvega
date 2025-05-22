//
//  CheckStressLevelView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct CheckStressLevelView: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Check Stress Level")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)

                Text("Let’s take a few moments to reflect.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 30)
            .padding(.trailing, 40)

            Spacer()

            Image("Stress")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(red: 1.0, green: 0.56, blue: 0.427))
                .padding(.bottom, 8)

            VStack(spacing: 12) {
                Text("How This Works")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)

                Text(
                    """
                    Before checking your stress level, take a moment to relax. Our system will guide you through a few questions. Please answer them honestly. Based on your answers, we’ll show you how stressed you might currently be.
                    """
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }
            .padding(.bottom, 24)

            NavigationLink(destination: StressQuestionView()) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 1.0, green: 0.56, blue: 0.427))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            }
            .padding(.bottom, 30)
            
            Spacer()
        }
        .navigationTitle("Calibrate")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
}

#Preview {
    CheckStressLevelView()
}
