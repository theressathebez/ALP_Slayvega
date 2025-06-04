//
//  MainView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var showAuthSheet = false

    var body: some View {
        TabView {
            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Shares")
                }
            
            StartPageView()
                .tabItem {
                    Label("Mindfulness", systemImage: "brain.head.profile")
                }
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }

            JournalMainView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed.fill")
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
