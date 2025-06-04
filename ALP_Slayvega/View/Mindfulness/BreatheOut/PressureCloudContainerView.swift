//
//  PressureCloudContainerView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import SwiftUI

struct PressureCloudContainerView: View {
    let pressures: [PeerPressure]

    var body: some View {
        ZStack {
            ForEach(pressures) { pressure in
                PressureCloudView(pressure: pressure)
            }
        }
        .frame(height: 200)
    }
}

#Preview {
    PressureCloudContainerView(pressures: [
        PeerPressure(
            text: "You should do this",
            offset: CGSize(width: 0, height: 0)
        ),
        PeerPressure(
            text: "Everyone is doing it",
            offset: CGSize(width: 50, height: 30)
        ),
        PeerPressure(
            text: "Just this once",
            offset: CGSize(width: -30, height: -20)
        ),
    ])
    .background(Color.gray.opacity(0.3))
}
