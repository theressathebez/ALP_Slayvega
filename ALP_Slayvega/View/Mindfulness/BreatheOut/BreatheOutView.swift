//
//  RelaxationView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 28/05/25.
//

import SwiftUI

struct BreatheOutView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            BackgroundView()

            if viewModel.gameState.showReflection {
                ReflectionView(viewModel: viewModel)
            } else {
                GameView()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    BreatheOutView()
}
