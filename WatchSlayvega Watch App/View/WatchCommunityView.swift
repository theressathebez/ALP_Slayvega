import SwiftUI

struct WatchCommunityReadView: View {
    @StateObject private var connectivity = WatchConnectivity()
    @State private var searchText = ""
    @State private var showConnectionInfo = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Connection Status Header
                ConnectionStatusView(connectivity: connectivity, showInfo: $showConnectionInfo)
                
                // Main Content
                if connectivity.isLoading {
                    LoadingView()
                } else if let error = connectivity.errorMessage {
                    ErrorView(error: error, connectivity: connectivity)
                } else if connectivity.communities.isEmpty {
                    EmptyStateView(connectivity: connectivity)
                } else {
                    CommunityListView(connectivity: connectivity, searchText: searchText)
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                connectivity.requestCommunities()
            }
            .refreshable {
                connectivity.refreshCommunities()
            }
            .sheet(isPresented: $showConnectionInfo) {
                ConnectionInfoView(connectivity: connectivity)
            }
        }
    }
}

struct ConnectionStatusView: View {
    @ObservedObject var connectivity: WatchConnectivity
    @Binding var showInfo: Bool
    
    var statusColor: Color {
        if connectivity.isConnected {
            return .green
        } else if connectivity.isLoading {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        Button(action: { showInfo = true }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(connectivity.connectionStatus)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if connectivity.isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                }
                
                Spacer()
                
                if connectivity.lastSyncDate != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.lightGray))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading Posts...")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Syncing with iPhone")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let error: String
    let connectivity: WatchConnectivity
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.orange)
            
            Text("Connection Issue")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                Button("Retry Sync") {
                    connectivity.refreshCommunities()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(16)
                
                Button("Test Connection") {
                    connectivity.testConnection()
                }
                .font(.caption2)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let connectivity: WatchConnectivity
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No Community Posts")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Posts from the iPhone app will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Refresh") {
                connectivity.requestCommunities()
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(16)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CommunityListView: View {
    @ObservedObject var connectivity: WatchConnectivity
    var searchText: String
    
    var filteredCommunities: [WatchCommunityModel] {
        if searchText.isEmpty {
            return connectivity.communities
        }
        return connectivity.searchCommunities(by: searchText)
    }
    
    var body: some View {
        List {
            // Stats header
            if !connectivity.communities.isEmpty {
                StatsHeaderView(totalPosts: connectivity.communities.count, lastSync: connectivity.lastSyncDate)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            // Community posts
            ForEach(filteredCommunities) { community in
                NavigationLink(
                    destination: CommunityDetailReadView(community: community)
                ) {
                    CommunityRowView(community: community)
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct StatsHeaderView: View {
    let totalPosts: Int
    let lastSync: Date?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(totalPosts) Posts")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                if let lastSync = lastSync {
                    Text("Updated \(timeAgo(from: lastSync))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "arrow.clockwise")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.lightGray))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else {
            return "\(Int(interval / 3600))h ago"
        }
    }
}

struct CommunityRowView: View {
    let community: WatchCommunityModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(community.username)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text(community.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Content
            Text(community.communityContent)
                .font(.caption)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Hashtags
            if !community.hashtags.isEmpty {
                Text(community.hashtags)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                    
                    Text("\(community.communityLikeCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail View
struct CommunityDetailReadView: View {
    let community: WatchCommunityModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header for watchOS
            HStack {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Post Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Invisible spacer to balance the layout
                Text("Back")
                    .font(.caption)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.lightGray))
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(community.username)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text(community.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Content Section
                    Text(community.communityContent)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Hashtags Section
                    if !community.hashtags.isEmpty {
                        Text(community.hashtags)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.vertical, 4)
                    }
                    
                    Divider()
                    
                    // Statistics Section
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .font(.body)
                                .foregroundColor(.red)
                            
                            Text("\(community.communityLikeCount) likes")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

// MARK: - Connection Info View
struct ConnectionInfoView: View {
    @ObservedObject var connectivity: WatchConnectivity
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                Text("Connection Info")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.lightGray))
            
            // Content
            List {
                Section("Connection Status") {
                    ForEach(Array(connectivity.getConnectionInfo().keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(connectivity.getConnectionInfo()[key] ?? "")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Section("Actions") {
                    Button("Test Connection") {
                        connectivity.testConnection()
                    }
                    .font(.caption)
                    
                    Button("Refresh Data") {
                        connectivity.refreshCommunities()
                    }
                    .font(.caption)
                }
            }
        }
    }
}

#Preview {
    WatchCommunityReadView()
}
