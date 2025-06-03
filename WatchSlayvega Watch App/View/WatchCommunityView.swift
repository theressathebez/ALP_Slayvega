import SwiftUI

struct WatchCommunityReadView: View {
    @StateObject private var connectivity = WatchConnectivity()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
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
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading posts...")
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
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.red)
            
            Text("Error")
                .font(.caption)
                .fontWeight(.medium)
            
            Text(error)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                connectivity.refreshCommunities()
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let connectivity: WatchConnectivity
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("No Posts Yet")
                .font(.caption)
                .fontWeight(.medium)
            
            Text("Check back later for community updates")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Refresh") {
                connectivity.requestCommunities()
            }
            .font(.caption)
            .foregroundColor(.blue)
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
            ForEach(filteredCommunities) { community in
                NavigationLink(
                    destination: CommunityDetailReadView(community: community)
                ) {
                    CommunityRowView(community: community)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct CommunityRowView: View {
    let community: WatchCommunityModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
            
            Text(community.communityContent)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if !community.hashtags.isEmpty {
                Text(community.hashtags)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                    
                    Text("\(community.communityLikeCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 2)
    }
}

struct CommunityDetailReadView: View {
    let community: WatchCommunityModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                PostHeaderView(community: community)
                PostContentView(community: community)
                PostStatsView(community: community)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostHeaderView: View {
    let community: WatchCommunityModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(community.username)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Spacer()
            }
            
            Text(community.formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 4)
    }
}

struct PostContentView: View {
    let community: WatchCommunityModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(community.communityContent)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            if !community.hashtags.isEmpty {
                Text(community.hashtags)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct PostStatsView: View {
    let community: WatchCommunityModel
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                
                Text("\(community.communityLikeCount) likes")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("Read Only")
                .font(.caption2)
                .foregroundColor(.gray)
                .italic()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

#Preview {
    WatchCommunityReadView()
}
