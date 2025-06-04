// ALP_Slayvega/ALP_SlayvegaApp.swift
import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct ALP_SlayvegaApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var quotesVM = QuotesViewModel()
    @StateObject var communityVM = CommunityViewModel()
    @StateObject var iosConnectivity = iOSConnectivity.shared // Initialize the shared instance

    init() {
        FirebaseApp.configure()
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        // The iOSConnectivity.shared is already initialized by now.
        // You can call methods on it if needed, e.g., iosConnectivity.manualSyncWithWatch()
        // but it should activate itself.
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authViewModel)
                .environmentObject(quotesVM)
                .environmentObject(communityVM)
                .environmentObject(iosConnectivity) // Optional: if views need to observe it
        }
    }
}
