//
//  StressQuestionView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct StressQuestionView: View {
    @StateObject private var viewModel = StressQuestionViewModel()
    @State private var currentQuestionIndex = 0
    @State private var navigateToResult = false
    @Environment(\.presentationMode) var presentationMode

    let choices = [
        (text: "Strongly Agree", emoji: "😊", value: 4),
        (text: "Agree", emoji: "😐", value: 3),
        (text: "Disagree", emoji: "😕", value: 2),
        (text: "Strongly Disagree", emoji: "😞", value: 1),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    if currentQuestionIndex > 0 {
                        currentQuestionIndex -= 1
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
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

                // Invisible placeholder for balance
                Image(systemName: "xmark")
                    .font(.title2)
                    .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // Progress indicator (optional)
            HStack {
                ForEach(0..<viewModel.questions.count, id: \.self) { index in
                    Rectangle()
                        .fill(
                            index <= currentQuestionIndex
                                ? Color(red: 1.0, green: 0.56, blue: 0.427)
                                : Color.gray.opacity(0.3)
                        )
                        .frame(height: 3)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            if currentQuestionIndex < viewModel.questions.count {
                // Question Content
                VStack(spacing: 40) {
                    VStack(spacing: 20) {
                        Text(
                            "How well does the following statement describe you?"
                        )
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                        Text(
                            "\(viewModel.questions[currentQuestionIndex].questionText)"
                        )
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .foregroundColor(.primary)
                    }

                    // Answer Options
                    VStack(spacing: 15) {
                        ForEach(choices, id: \.value) { choice in
                            Button(action: {
                                selectAnswer(choice.value)
                            }) {
                                HStack {
                                    Text(choice.emoji)
                                        .font(.title2)

                                    Text(choice.text)
                                        .font(.body)
                                        .fontWeight(.medium)

                                    Spacer()
                                }
                                .padding(.horizontal, 25)
                                .padding(.vertical, 18)
                                .background(
                                    isAnswerSelected(choice.value)
                                        ? Color(
                                            red: 1.0, green: 0.56, blue: 0.427)
                                        : Color(.systemGray6)
                                )
                                .foregroundColor(
                                    isAnswerSelected(choice.value)
                                        ? .white
                                        : .primary
                                )
                                .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }

            Spacer()

            // Bottom indicator (optional page dots)
            HStack(spacing: 8) {
                ForEach(0..<viewModel.questions.count, id: \.self) { index in
                    Circle()
                        .fill(
                            index == currentQuestionIndex
                                ? Color.primary : Color.gray.opacity(0.3)
                        )
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 50)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .background(
            NavigationLink(
                destination: StressResultView(
                    viewModel: viewModel,
                    mindfulnessViewModel: MindfulnessViewModel()
                ),
                isActive: $navigateToResult
            ) {
                EmptyView()
            }
        )

    }

    private func isAnswerSelected(_ value: Int) -> Bool {
        guard currentQuestionIndex < viewModel.questions.count else {
            return false
        }
        let questionId = viewModel.questions[currentQuestionIndex].id
        return viewModel.answers[questionId] == value
    }

    private func selectAnswer(_ value: Int) {
        let questionId = viewModel.questions[currentQuestionIndex].id
        viewModel.answers[questionId] = value

        // Auto-advance to next question after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if currentQuestionIndex < viewModel.questions.count - 1 {
                currentQuestionIndex += 1
            } else {
                // All questions answered, show result
                navigateToResult = true
            }
        }
    }
}

#Preview {
    NavigationView {
        StressQuestionView()
    }
}
