//
//  StressQuestionView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct StressQuestionView: View {
    @StateObject private var viewModel = StressQuestionViewModel()
    @State private var showResult = false

    let choices = [
        (text: "Strongly Disagree", value: 1),
        (text: "Disagree", value: 2),
        (text: "Agree", value: 3),
        (text: "Strongly Agree", value: 4),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stress Assessment")
                .font(.largeTitle.bold())
                .padding(.top)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(viewModel.questions) { question in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(question.questionText)
                                .font(.headline)

                            HStack {
                                ForEach(choices, id: \.value) { choice in
                                    Button(action: {
                                        viewModel.answers[question.id] =
                                            choice.value
                                    }) {
                                        Text(choice.text)
                                            .font(.caption)
                                            .padding(8)
                                            .background(
                                                viewModel.answers[question.id]
                                                    == choice.value
                                                    ? Color(
                                                        red: 1.0,
                                                        green: 0.56,
                                                        blue: 0.427
                                                    ) : Color(.systemGray5)
                                            )
                                            .foregroundColor(.primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Button(action: {
                showResult = true
            }) {
                Text("Submit")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(red: 1.0, green: 0.56, blue: 0.427))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal)
            }
            .padding(.bottom, 30)
            .disabled(viewModel.answers.count < viewModel.questions.count)
            .opacity(
                viewModel.answers.count < viewModel.questions.count ? 0.5 : 1
            )
            .alert(isPresented: $showResult) {
                Alert(
                    title: Text("Stress Level"),
                    message: Text(
                        "Your stress level is: \(viewModel.stressLevel)"
                    ),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle("Stress Questions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    StressQuestionView()
}
