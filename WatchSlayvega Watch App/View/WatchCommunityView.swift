//
//  WatchCommunityView.swift
//  WatchSlayvega Watch App
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct WatchCommunityView: View {
    @StateObject private var connectivity = WatchConnectivity()
    @State private var selectedCommunity: WatchCommunityModel?
    
    var body: some View {
        NavigationView {
            VStack {
                if connectivity.isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading...")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if connectivity.communities.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "wifi.slash")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("No Connection")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button("Refresh") {
                            connectivity.requestCommunities()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(connectivity.communities) { community in
                            NavigationLink(
                                destination: WatchCommunityDetailView(
                                    community: community,
                                    connectivity: connectivity
                                )
                            ) {
                                WatchCommunityRowView(community: community)
                            }
                        }
                    }
                    .refreshable {
                        connectivity.refreshCommunities()
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if connectivity.communities.isEmpty {
                    connectivity.requestCommunities()
                }
            }
        }
    }
}

struct WatchCommunityRowView: View {
    let community: WatchCommunityModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            if !community.hashtags.isEmpty {
                Text(community.hashtags)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            HStack {
                Image(systemName: "heart")
                    .font(.caption2)
                    .foregroundColor(.red)
                
                Text("\(community.communityLikeCount)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "bubble.right")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 2)
    }
}

struct WatchCommunityDetailView: View {
    let community: WatchCommunityModel
    @ObservedObject var connectivity: WatchConnectivity
    @State private var showComments = false
    
    var body: some View {
        ScrollView {
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
                    .multilineTextAlignment(.leading)
                
                // Hashtags
                if !community.hashtags.isEmpty {
                    Text(community.hashtags)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                // Stats
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                        
                        Text("\(community.communityLikeCount)")
                            .font(.caption2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showComments.toggle()
                        if showComments {
                            connectivity.requestComments(for: community.id)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.right")
                                .font(.caption2)
                            
                            Text("Comments")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.top, 4)
                
                // Comments Section
                if showComments {
                    Divider()
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comments")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        if connectivity.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.6)
                                Text("Loading comments...")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } else if connectivity.comments.isEmpty {
                            Text("No comments yet")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(connectivity.comments) { comment in
                                WatchCommentRowView(comment: comment)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WatchCommentRowView: View {
    let comment: WatchCommentModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.username)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text(comment.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.commentContent)
                .font(.caption2)
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "heart")
                        .font(.caption2)
                        .foregroundColor(.red)
                    
                    Text("\(comment.commentLikeCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.gray))
        .cornerRadius(8)
    }
}

#Preview {
    WatchCommunityView()
}
