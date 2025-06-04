//
//  StressQuestionView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct StressQuestionView: View {
    @StateObject private var viewModel = StressQuestionViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    if viewModel.canGoBack() {
                        viewModel.goBack()
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

            // Progress indicator
            HStack {
                ForEach(
                    Array(viewModel.progressBarData.enumerated()), id: \.offset
                ) { index, isActive in
                    Rectangle()
                        .fill(
                            isActive
                                ? Color(red: 1.0, green: 0.56, blue: 0.427)
                                : Color.gray.opacity(0.3)
                        )
                        .frame(height: 3)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            if let currentQuestion = viewModel.currentQuestion {
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

                        Text(currentQuestion.questionText)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .foregroundColor(.primary)
                    }

                    // Answer Options
                    VStack(spacing: 15) {
                        ForEach(viewModel.choices, id: \.value) { choice in
                            Button(action: {
                                viewModel.selectAnswer(choice.value)
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
                                    viewModel.isAnswerSelected(choice.value)
                                        ? Color(
                                            red: 1.0, green: 0.56, blue: 0.427)
                                        : Color(.systemGray6)
                                )
                                .foregroundColor(
                                    viewModel.isAnswerSelected(choice.value)
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

            // Bottom indicator (page dots)
            HStack(spacing: 8) {
                ForEach(
                    Array(viewModel.pageIndicatorData.enumerated()),
                    id: \.offset
                ) { index, isActive in
                    Circle()
                        .fill(
                            isActive
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
                    viewModel: viewModel
                ),
                isActive: $viewModel.shouldNavigateToResult
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    NavigationView {
        StressQuestionView()
    }
}
