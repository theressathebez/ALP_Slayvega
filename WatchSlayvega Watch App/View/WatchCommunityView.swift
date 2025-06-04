// WatchSlayvega Watch App/View/WatchCommunityView.swift
import SwiftUI

struct WatchCommunityReadView: View {
    @StateObject private var connectivity = WatchConnectivity() // Use the refined ViewModel
    @State private var showConnectionInfoSheet = false
    // Search text can be added later if needed, keeping it simple for now

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ConnectionStatusHeaderView(connectivity: connectivity, showInfoSheet: $showConnectionInfoSheet)
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                if connectivity.isLoading && connectivity.communities.isEmpty { // Show loading only if no data yet
                    ProgressView("Fetching Posts...")
                        .frame(maxHeight: .infinity)
                } else if let errorMsg = connectivity.errorMessage, connectivity.communities.isEmpty { // Show error only if no data
                    ErrorDisplayView(
                        message: errorMsg,
                        onRetry: { connectivity.manualRefresh() },
                        onTestConnection: { connectivity.testPingToPhone() }
                    )
                    .frame(maxHeight: .infinity)
                } else if connectivity.communities.isEmpty {
                    EmptyStateDisplayView(onRefresh: { connectivity.manualRefresh() })
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(connectivity.communities) { community in
                            NavigationLink(destination: CommunityPostDetailView(community: community)) {
                                CommunityPostRow(community: community)
                            }
                        }
                    }
                    .listStyle(.carousel) // Or .plain
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Add a refresh button to the toolbar
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        connectivity.manualRefresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(connectivity.isLoading)
                }
            }
            .onAppear {
                // Request data if communities are empty or last sync was long ago
                if connectivity.communities.isEmpty {
                    connectivity.requestCommunitiesData(reason: "")
                }
            }
            .sheet(isPresented: $showConnectionInfoSheet) {
                DetailedConnectionInfoView(connectivity: connectivity)
            }
        }
    }
}

// MARK: - Subviews for WatchCommunityReadView

struct ConnectionStatusHeaderView: View {
    @ObservedObject var connectivity: WatchConnectivity
    @Binding var showInfoSheet: Bool

    var statusColor: Color {
        if !connectivity.isConnectedToPhone { return .red }
        if connectivity.isLoading { return .yellow }
        if connectivity.errorMessage != nil { return .orange }
        return .green
    }

    var body: some View {
        Button(action: { showInfoSheet = true }) {
            HStack(spacing: 4) {
                Circle().fill(statusColor).frame(width: 8, height: 8)
                Text(connectivity.connectionStatusMessage)
                    .font(.system(size: 10)) // Smaller font for watch
                    .lineLimit(1)
                Spacer()
                if connectivity.isLoading {
                    ProgressView().scaleEffect(0.5)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ErrorDisplayView: View {
    let message: String
    let onRetry: () -> Void
    let onTestConnection: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.exclamationmark")
                .font(.title).foregroundColor(.red)
            Text("Error").font(.headline)
            Text(message).font(.caption).multilineTextAlignment(.center).padding(.horizontal)
            Button("Retry", action: onRetry).font(.caption).buttonStyle(.borderedProminent).tint(.blue)
            Button("Test Ping", action: onTestConnection).font(.caption2)
        }
    }
}

struct EmptyStateDisplayView: View {
    let onRefresh: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.title).foregroundColor(.gray)
            Text("No Posts").font(.headline)
            Text("Pull down to refresh or tap button.").font(.caption).foregroundColor(.secondary)
            Button("Refresh", action: onRefresh).font(.caption)
        }
    }
}

struct CommunityPostRow: View {
    let community: WatchCommunityModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(community.username).font(.system(size: 13, weight: .semibold)).foregroundColor(.orange)
                Spacer()
                Text(community.formattedDate).font(.system(size: 10)).foregroundColor(.gray)
            }
            Text(community.communityContent)
                .font(.system(size: 12))
                .lineLimit(2)
            if !community.hashtags.isEmpty {
                Text(community.hashtags).font(.system(size: 10, weight: .medium)).foregroundColor(.blue).lineLimit(1)
            }
            HStack {
                Image(systemName: "heart.fill").font(.system(size: 10)).foregroundColor(.red)
                Text("\(community.communityLikeCount)").font(.system(size: 10))
                Spacer()
            }
        }
        .padding(.vertical, 2)
    }
}

struct CommunityPostDetailView: View {
    let community: WatchCommunityModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(community.username)
                    .font(.headline)
                    .foregroundColor(.orange)
                Text(community.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Divider()
                
                Text(community.communityContent)
                    .font(.body)
                
                if !community.hashtags.isEmpty {
                    Text(community.hashtags)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
                Divider().padding(.vertical, 4)
                HStack {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("\(community.communityLikeCount) likes")
                    Spacer()
                }
                .font(.caption)
            }
            .padding()
        }
        .navigationTitle("Post") // Simple title for detail view
    }
}


struct DetailedConnectionInfoView: View {
    @ObservedObject var connectivity: WatchConnectivity
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("Current Status") {
                    ForEach(connectivity.getConnectionInfo().sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        VStack(alignment: .leading) {
                            Text(key).font(.caption.weight(.semibold))
                            Text(value).font(.caption2)
                        }
                    }
                }
                Section("Actions") {
                    Button("Test Ping to iPhone") { connectivity.testPingToPhone() }
                    Button("Force Refresh Data") { connectivity.manualRefresh() }
                }
            }
            .navigationTitle("Connection Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}


#Preview {
    WatchCommunityReadView()
}
