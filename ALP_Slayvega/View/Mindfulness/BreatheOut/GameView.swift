//
//  GameView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Enjoy 5 deep breathing")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(0.8))

                if !viewModel.isCompleted {
                    Text(
                        "Set \(viewModel.currentSet) of \(viewModel.totalSets)"
                    )
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                }
            }
            .padding(.top,40)

            Spacer()

            PressureCloudContainerView(
                pressures: viewModel.gameState.activePressures)

            Spacer()

            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 280, height: 280)

                // Breathing circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.orange.opacity(0.4),
                                Color.blue.opacity(0.3),
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 140
                        )
                    )
                    .frame(
                        width: getBreathingCircleSize(),
                        height: getBreathingCircleSize()
                    )
                    .animation(
                        .easeInOut(duration: 0.5),
                        value: viewModel.breathingProgress)

                // Phase text and timer
                VStack(spacing: 8) {
                    if viewModel.isCompleted {
                        Text("Complete!")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    } else {
                        Text(viewModel.currentPhase.title)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        Text(
                            String(
                                format: "%02d:%02d",
                                viewModel.timeRemaining / 60,
                                viewModel.timeRemaining % 60)
                        )
                        .font(.title3)
                        .fontWeight(.light)
                        .foregroundColor(.white.opacity(0.8))
                    }
                }
            }

            Spacer()

            // Control Button
            Button(action: {
                if viewModel.isCompleted {
                    viewModel.resetBreathing()
                } else if viewModel.isActive {
                    viewModel.pauseBreathing()
                } else {
                    viewModel.startBreathing()
                }
            }) {
                Text(getButtonTitle())
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 40)

            Spacer(minLength: 40)

            PositiveElementsContainerView(
                elements: viewModel.gameState.positiveElements)

        }
        .onAppear {
            viewModel.startGame()
        }
    }

    private func getBreathingCircleSize() -> CGFloat {
        let baseSize: CGFloat = 120
        let maxSize: CGFloat = 200

        if viewModel.isCompleted {
            return maxSize
        }

        let progress = viewModel.breathingProgress

        switch viewModel.currentPhase {
        case .inhale:
            return baseSize + (maxSize - baseSize) * progress
        case .hold:
            return maxSize
        case .exhale:
            return maxSize - (maxSize - baseSize) * progress
        @unknown default:
            return baseSize
        }
    }

    private func getButtonTitle() -> String {
        if viewModel.isCompleted {
            return "Start Again"
        } else if viewModel.isActive {
            return "Pause"
        } else {
            return "Start"
        }
    }
}

#Preview {
    GameView()
}
