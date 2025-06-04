// ALP_Slayvega/ALP_SlayvegaApp.swift
import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct ALP_SlayvegaApp: App { //
    @StateObject var authViewModel = AuthViewModel() //
    @StateObject var quotesVM = QuotesViewModel() //
    @StateObject var communityVM = CommunityViewModel() //
    @StateObject var iosConnectivity = iOSConnectivity.shared // Inisialisasi shared instance

    init(){ //
        FirebaseApp.configure() //
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory() //
        AppCheck.setAppCheckProviderFactory(providerFactory) //
        #endif
        // iOSConnectivity.shared akan otomatis mengaktifkan sesi WCSession karena inisialisasinya.
        print("ALP_SlayvegaApp: iOSConnectivity shared instance accessed, WCSession should be activating if supported.")
    }
    
    var body: some Scene { //
        WindowGroup { //
            MainView() //
                .environmentObject(authViewModel) //
                .environmentObject(quotesVM) //
                .environmentObject(communityVM) //
                .environmentObject(iosConnectivity) 
        }
    }
}
