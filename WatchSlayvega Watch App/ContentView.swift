// WatchSlayvega Watch App/ContentView.swift
import SwiftUI

struct ContentView: View {
    // You can inject the connectivity object here if needed for other tabs
    // or let each tab manage its own instance if they are independent.
    // For simplicity, WatchCommunityReadView creates its own instance for now.

    var body: some View {
        TabView {
            WatchCommunityReadView()
                .tabItem {
                    Label("Community", systemImage: "bubble.left.and.bubble.right.fill")
                }
            
            // Simple Status View using the SAME WatchConnectivity instance
            // if you want shared status. For now, this is separate.
            // WatchAppStatusView()
            //    .tabItem {
            //        Label("Status", systemImage: "heart.circle.fill")
            //    }
        }
    }
}

// Example of a separate status view (can be expanded)
// struct WatchAppStatusView: View {
//     @StateObject private var connectivity = WatchConnectivity() // Separate instance for this tab
//
//     var body: some View {
//         VStack {
//             Text("Connectivity Status")
//                 .font(.headline)
//             Text(connectivity.connectionStatusMessage)
//                 .font(.caption)
//             if let errMsg = connectivity.errorMessage {
//                 Text("Error: \(errMsg)")
//                     .font(.caption2)
//                     .foregroundColor(.red)
//             }
//             Button("Test Ping") {
//                 connectivity.testPingToPhone()
//             }
//         }
//         .onAppear {
//             if !connectivity.isConnectedToPhone { // Request if not connected to try establishing
//                 connectivity.requestCommunitiesData()
//             }
//         }
//     }
// }

#Preview {
    ContentView()
}
