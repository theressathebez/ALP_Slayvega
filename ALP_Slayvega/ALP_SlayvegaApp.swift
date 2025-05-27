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
    @StateObject private var authViewModel = AuthViewModel()
    
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
        }
    }
}
