//
//  StartPageView.swift
//  ALP_Slayvega
//
//  Created by Joy Luist on 04/06/25.
//

import SwiftUI

struct StartPageView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Deep Breathe 4-7-8")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 30)

                Image("Stress")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    Text("How This Works")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)

                    Text(
                        """
                        The 4-7-8 breathing technique helps you relax by slowing down your breath. 
                        Breathe in quietly through your nose for 4 seconds, hold your breath for 7 seconds, 
                        then exhale forcefully through your mouth for 8 seconds. Repeat this cycle a few times to calm your mind and body.
                        """
                    )
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)

                NavigationLink(destination: BreatheOutView()) {
                    Text("Start Breathing")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(red: 0.27, green: 0.52, blue: 0.96))  // Warna biru kalem
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .padding(.horizontal)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                }
                .padding(.bottom, 30)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    StartPageView()
}
