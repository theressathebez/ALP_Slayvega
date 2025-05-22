//
//  MainView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            MindfulnessView()
                .tabItem {
                    Label("Mindfulness", systemImage: "brain.head.profile")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    MainView()
}
