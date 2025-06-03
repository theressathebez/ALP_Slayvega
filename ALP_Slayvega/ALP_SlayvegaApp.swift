//
//  ALP_SlayvegaApp.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct ALP_SlayvegaApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var quotesVM = QuotesViewModel()
    @StateObject var communityVM = CommunityViewModel()
    
    init(){
        FirebaseApp.configure()
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authViewModel)
                .environmentObject(quotesVM)
                .environmentObject(communityVM)
        }
    }
}
