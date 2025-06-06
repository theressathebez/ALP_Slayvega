//
//  CommunityView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var communityVM = CommunityViewModel()
    @StateObject private var authVM = AuthViewModel()
    @State private var selectedTab: String = "Share"

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                TextField("Search...", text: .constant(""))
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        HStack {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    )
                    .padding(.horizontal)
            }
            .padding(.bottom, 25)

            // Tab bar and post content (if Share)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TabButton(title: "Share", selectedTab: $selectedTab)
                    TabButton(title: "My Posts", selectedTab: $selectedTab)
                }
                .background(Color.white)

                if selectedTab == "Share" {
                    ShareHeaderView(communityVM: communityVM, authVM: authVM)
                        .background(Color.white)
                }
            }

            ScrollView {
                VStack(spacing: 10) {
                    if selectedTab == "Share" {
                        SharePostsView(communities: communityVM.communities, communityVM: communityVM, authVM: authVM)
                    } else {
                        MyPostsView(communities: communityVM.userCommunities, communityVM: communityVM, authVM: authVM)
                    }
                }
            }

            Spacer()
        }
        .background(Color(red: 239 / 255, green: 245 / 255, blue: 255 / 255))  // Light blue
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct SegmentedTabView: View {
    @Binding var selectedTab: String
    let tabs: [String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs, id: \.self) { tab in
                TabButton(title: tab, selectedTab: $selectedTab)
            }
        }
        .padding(4)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct TabButton: View {
    let title: String
    @Binding var selectedTab: String

    var isSelected: Bool {
        selectedTab == title
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = title
            }
        }) {
            Text(title)
                .foregroundColor(isSelected ? Color.fromHex("#FFA075") : Color.gray)
                .fontWeight(.semibold)
                .padding(.vertical, 10)
                .frame(minWidth: 80)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isSelected {
                            Color.white
                                .clipShape(RoundedRectangle(cornerRadius: 0))
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        } else {
                            Color.clear
                        }
                    }
                )
        }
        .foregroundColor(.black)
    }
}

struct ShareHeaderView: View {
    let communityVM: CommunityViewModel
    let authVM: AuthViewModel
    @State private var showUsername: Bool = false
    @State private var postText: String = ""
    @State private var hashtags: String = ""

    var body: some View {
        VStack(spacing: 10) {
            TextEditor(text: $postText)
                .frame(minHeight: 80, maxHeight: 150)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    Group {
                        if postText.isEmpty {
                            Text("What's on your mind?")
                                .foregroundColor(.gray)
                                .padding(.leading, 16)
                                .padding(.top, 12)
                                .allowsHitTesting(false)
                        }
                    }, alignment: .topLeading
                )

            // Hashtags input
            TextField("Add hashtags (e.g., #MentalHealth #StayStrong)", text: $hashtags)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)

            HStack {
                Toggle(isOn: $showUsername) {
                    Text("Show Username?")
                        .font(.subheadline)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.fromHex("#FFA075")))
                
                Spacer()

                Button("Post") {
                    guard !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    
                    // Determine username based on toggle
                    let displayUsername = showUsername ? authVM.myUser.getDisplayName() : "Anonymous"
                    
                    let newCommunity = CommunityModel(
                        username: displayUsername,
                        communityContent: postText,
                        hashtags: hashtags,
                        communityLikeCount: 0,
                        communityDates: Date()
                    )
                    communityVM.createCommunity(newCommunity)
                    
                    postText = ""
                    hashtags = ""
                    showUsername = false
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 7.5)
                .padding(.horizontal, 10)
                .background(Color.fromHex("#FFA075"))
                .cornerRadius(15)
            }
        }
        .padding()
    }
}

struct SharePostsView: View {
    let communities: [CommunityModel]
    let communityVM: CommunityViewModel
    let authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            // Show all posts from all users (sorted by date)
            ForEach(communities.sorted(by: { $0.communityDates > $1.communityDates })) { community in
                CommunityContentCard(
                    username: community.username,
                    content: community.communityContent,
                    timestamp: formatDate(community.communityDates),
                    initialLikeCount: community.communityLikeCount,
                    hashtags: parseHashtags(community.hashtags),
                    communityId: community.id,
                    userId: community.userId,
                    currentUserId: authVM.user?.uid,
                    onDelete: {
                        // Only allow delete if it's user's own post
                        if community.userId == authVM.user?.uid {
                            communityVM.removeCommunity(withId: community.id)
                        }
                    },
                    community: community, // Pass the complete community model
                    authVM: authVM, // Pass the AuthViewModel
                    communityVM: communityVM // Pass the CommunityViewModel for like functionality
                )
            }
            
            // Example posts (you can remove these if you want only real posts)
            let exampleCommunity1 = CommunityModel(
                id: "example1",
                username: "Anonymous",
                communityContent: "Hang in there! Even the toughest days have 24 hours. You're stronger than you think and this too shall pass 🌟",
                hashtags: "#KeepGoing #StayStrong",
                communityLikeCount: 323,
                communityDates: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                userId: ""
            )
            
            CommunityContentCard(
                username: exampleCommunity1.username,
                content: exampleCommunity1.communityContent,
                timestamp: "June 25, 2024",
                initialLikeCount: exampleCommunity1.communityLikeCount,
                hashtags: parseHashtags(exampleCommunity1.hashtags),
                communityId: exampleCommunity1.id,
                userId: exampleCommunity1.userId,
                currentUserId: authVM.user?.uid,
                onDelete: {},
                community: exampleCommunity1,
                authVM: authVM,
                communityVM: communityVM
            )

            let exampleCommunity2 = CommunityModel(
                id: "example2",
                username: "Drphnd",
                communityContent: "Life's challenges can feel overwhelming, but remember that every storm runs out of rain.",
                hashtags: "#MentalHealth #StayHopeful",
                communityLikeCount: 112,
                communityDates: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                userId: ""
            )
            
            CommunityContentCard(
                username: exampleCommunity2.username,
                content: exampleCommunity2.communityContent,
                timestamp: "May 10, 2024",
                initialLikeCount: exampleCommunity2.communityLikeCount,
                hashtags: parseHashtags(exampleCommunity2.hashtags),
                communityId: exampleCommunity2.id,
                userId: exampleCommunity2.userId,
                currentUserId: authVM.user?.uid,
                onDelete: {},
                community: exampleCommunity2,
                authVM: authVM,
                communityVM: communityVM
            )
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func parseHashtags(_ hashtagString: String) -> [String] {
        return hashtagString.components(separatedBy: " ").filter { !$0.isEmpty }
    }
}

// Updated MyPostsView to pass CommunityViewModel
struct MyPostsView: View {
    let communities: [CommunityModel]
    let communityVM: CommunityViewModel
    let authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            if communities.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No posts yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Start sharing your thoughts with the community!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
            } else {
                // Show only user's posts
                ForEach(communities.sorted(by: { $0.communityDates > $1.communityDates })) { community in
                    CommunityContentCard(
                        username: community.username,
                        content: community.communityContent,
                        timestamp: formatDate(community.communityDates),
                        initialLikeCount: community.communityLikeCount,
                        hashtags: parseHashtags(community.hashtags),
                        communityId: community.id,
                        userId: community.userId,
                        currentUserId: authVM.user?.uid,
                        onDelete: {
                            communityVM.removeCommunity(withId: community.id)
                        },
                        community: community, // Pass the complete community model
                        authVM: authVM, // Pass the AuthViewModel
                        communityVM: communityVM // Pass the CommunityViewModel for like functionality
                    )
                }
            }
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func parseHashtags(_ hashtagString: String) -> [String] {
        return hashtagString.components(separatedBy: " ").filter { !$0.isEmpty }
    }
}

struct TrendingTagRow: View {
    let tag: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tag)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text("8,500 posts")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "ellipsis")
                .foregroundColor(.gray)
        }
        .padding(.bottom, 15)
        .overlay(Divider(), alignment: .bottom)
    }
}

// Preview
#Preview {
    CommunityView()
}
