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
        case "How Stressed Are You?":
            CheckStressLevelView()
        case "Breathe Out":
            BreatheOutView()
        case "Social Chameleon":
            SocialChameleonView()
        default:
            EmptyView()
        }
    }
}

#Preview {
    MindfulnessView()
}
