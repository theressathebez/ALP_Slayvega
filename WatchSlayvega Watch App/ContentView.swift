//
//  ContentView.swift
//  WatchSlayvega Watch App
//
//  Created by student on 03/06/25.


import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WatchCommunityReadView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Community")
                }
            
            WatchStatusView()
                .tabItem {
                    Image(systemName: "heart.circle")
                    Text("Status")
                }
        }
    }
}

struct WatchStatusView: View {
    @StateObject private var connectivity = WatchConnectivity()
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: connectivity.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title)
                .foregroundColor(connectivity.isConnected ? .green : .red)
            
            Text(connectivity.isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .fontWeight(.semibold)
            
            Text("iPhone Connection")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if connectivity.isConnected {
                VStack(spacing: 4) {
                    Text("\(connectivity.communities.count) Posts")
                        .font(.caption2)
                    
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            
            Button("Refresh") {
                connectivity.requestCommunities()
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .navigationTitle("Status")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
