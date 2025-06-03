//
//  MainView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var communityVM = CommunityViewModel()
    @StateObject var journalVM = JournalViewModel()
    @State var showAuthSheet = false //add sheet state
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            MindfulnessView()
                .tabItem {
                    Label("Mindfulness", systemImage: "brain.head.profile")
                }

            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Shares")
                }
            
            JournalMainView()
                .environmentObject(journalVM)
                .tabItem {
                    Label("Journal", systemImage: "book.closed.fill")
                }
        }
        .accentColor(Color.fromHex("#FF8F6D"))
        .onAppear {
            showAuthSheet = !authViewModel.isSignedIn
        }

        .sheet(isPresented: $showAuthSheet) {
            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
        }
    }
}

//#Preview {
//    MainTabView()
//        .environmentObject(AuthViewModel())
//        .environmentObject(CommentViewModel())
//}
