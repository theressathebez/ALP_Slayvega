//
//  ReflectionView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import SwiftUI

struct ReflectionView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.1),
                                Color.orange.opacity(0.1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Text("🌸")
                    .font(.system(size: 60))
                    .scaleEffect(viewModel.gameState.reflectionScale)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(
                            autoreverses: true),
                        value: viewModel.gameState.reflectionScale
                    )
            }

            // Reflection Text
            VStack(spacing: 24) {
                Text("Well Done!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text(viewModel.gameState.currentReflection)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Text("Remember: It's okay to go at your own pace.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Modern CTA Button
            Button(action: viewModel.resetGame) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Breathe Again")
                        .font(
                            .system(
                                size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 5)
            }
            .padding(.bottom, 60)
        }
        .onAppear {
            viewModel.startReflectionAnimation()
        }
    }
}

#Preview {
    ReflectionView(viewModel: GameViewModel())
        .background(Color.white)
}
