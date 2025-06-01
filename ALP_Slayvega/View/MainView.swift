//
//  MainView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel  //add EnvObj
    @State var showAuthSheet = false  //add sheet state

    var body: some View {
        TabView {
            CommunityView()
                .tabItem { Label("Community", systemImage: "people.circle") }
            MindfulnessView()
                .tabItem {
                    Label("Mindfulness", systemImage: "brain.head.profile")
                }
            ProfileView(showAuthSheet: $showAuthSheet, authVM: AuthViewModel())
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .onAppear {
            showAuthSheet = !authViewModel.isSignedIn
        }

        .sheet(isPresented: $showAuthSheet) {
            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
