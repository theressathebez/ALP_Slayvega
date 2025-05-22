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
            }

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.items) { mind in
                        NavigationLink(
                            destination: StresLevelView(title: mind.title)
                        ) {
                            MindfulnessCardView(mind: mind)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    MindfulnessView()
}
