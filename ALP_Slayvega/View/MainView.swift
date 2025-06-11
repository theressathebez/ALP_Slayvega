//
//Users/monicathebez/Documents/GitHub/ALP_Slayvega/ALP_Slayvega/View
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
        if authViewModel.isSignedIn {
            // Show main app content when user is signed in
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Dashboard")
                    }

                CommunityView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Shares")
                    }

                StartPageView()
                    .tabItem {
                        Label("Mindfulness", systemImage: "brain.head.profile")
                    }

                JournalMainView()
                    .tabItem {
                        Label("Journal", systemImage: "book.closed.fill")
                    }
            }
        } else {
            // Show login/register view when user is not signed in
            LoginRegisterView()
        }
    }
}
