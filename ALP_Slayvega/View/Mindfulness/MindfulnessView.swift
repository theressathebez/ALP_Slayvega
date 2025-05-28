//
//  MindfulnessView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MindfulnessView: View {
    @StateObject private var viewModel = MindfulnessViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mindfulness")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.items) { mind in
                            NavigationLink(
                                destination: destinationView(for: mind)
                            ) {
                                MindfulnessCardView(mind: mind)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView(for mind: MindfulnessModel) -> some View {
        switch mind.title {
        case "Calibrate":
            CheckStressLevelView()  // ganti dengan view yang sesuai jika perlu
        case "Inhale":
            RelaxationView()  // ganti dengan view yang sesuai jika perlu
        default:
            EmptyView()
        }
    }
}

#Preview {
    MindfulnessView()
}
