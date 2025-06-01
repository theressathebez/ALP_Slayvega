//
//  PressureCloudView.swift
//  ALP_Slayvega
//
//  Created by Michelle Wijaya on 01/06/25.
//

import SwiftUI

struct PressureCloudView: View {
    let pressure: PeerPressure

    var body: some View {
        Text(pressure.text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        Color.gray.opacity(pressure.isDisappearing ? 0.2 : 0.6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
            )
            .opacity(pressure.opacity)
            .offset(pressure.offset)
            .scaleEffect(pressure.isDisappearing ? 1.2 : 1.0)
            .animation(.easeOut(duration: 1.0), value: pressure.isDisappearing)
    }
}

#Preview {
    PressureCloudView(
        pressure: PeerPressure(
            text: "You should do this",
            offset: CGSize(width: 0, height: 0)
        )
    )
    .background(Color.gray.opacity(0.3))
}
