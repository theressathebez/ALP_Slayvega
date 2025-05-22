//
//  StresLevelView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct StresLevelView: View {
    var title: String

    var body: some View {
        Text("\(title) Page")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    StresLevelView(title: "Inhale")
}
