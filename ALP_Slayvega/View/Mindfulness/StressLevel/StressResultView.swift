//
//  StressResultView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 28/05/25.
//

import FirebaseAuth
import SwiftUI

struct StressResultView: View {
    @ObservedObject var viewModel: StressQuestionViewModel
    @ObservedObject var mindfulnessViewModel: MindfulnessViewModel
    @Environment(\.dismiss) var dismiss
    @State private var navigateToMindfulness = false

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("Calibrate")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                // Placeholder to center title
                Color.clear
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            // Main Content
            VStack(spacing: 40) {
                VStack(spacing: 20) {
                    Text("Your stress level is")
                        .font(.title2)
                        .foregroundColor(.gray)

                    Text(viewModel.stressLevel.uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(viewModel.stressLevelColor)

                    VStack(spacing: 8) {
                        // Progress Bars
                        HStack(spacing: 4) {
                            ForEach(0..<4) { index in
                                Rectangle()
                                    .fill(
                                        index < viewModel.stressLevelBars
                                            ? viewModel.stressLevelColor
                                            : Color.gray.opacity(0.3)
                                    )
                                    .frame(height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 60)

                        HStack {
                            Text("Low")
                            Spacer()
                            Text("Very High")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 60)
                    }
                }

                Text(viewModel.stressDescription)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Continue Button
            NavigationLink(
                destination: MindfulnessView(),
                isActive: $navigateToMindfulness
            ) {
                Button(action: {
                    mindfulnessViewModel.saveStressResult(
                        stressLevel: Int(viewModel.averageScore),
                        userId: Auth.auth().currentUser?.uid ?? "unknown_user"
                    )

                    navigateToMindfulness = true
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    let stressVM = StressQuestionViewModel()
    stressVM.answers = [
        stressVM.questions[0].id: 3,
        stressVM.questions[1].id: 2,
        stressVM.questions[2].id: 4,
        stressVM.questions[3].id: 2,
        stressVM.questions[4].id: 3,
    ]

    let mindfulnessVM = MindfulnessViewModel()

    return StressResultView(
        viewModel: stressVM,
        mindfulnessViewModel: mindfulnessVM
    )
}
