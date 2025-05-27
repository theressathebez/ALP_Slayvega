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

            // Tab bar dan konten posting (jika Share)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TabButton(title: "Share", selectedTab: $selectedTab)
                    TabButton(title: "Explore", selectedTab: $selectedTab)
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
                        ExploreContentView()
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
                .foregroundColor(isSelected ? Color(hex: "#FFA075") : Color.gray)
                .fontWeight(.semibold)
                .padding(.vertical, 10)
                .frame(minWidth: 100)
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
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#FFA075")))

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
                    
                    communityVM.createSpot(newCommunity)
                    
                    // Clear form
                    postText = ""
                    hashtags = ""
                    showUsername = false
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 7.5)
                .padding(.horizontal, 10)
                .background(Color(hex: "#FFA075"))
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
            // Show user's posts from Firebase
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
                        // Delete community from Firebase
                        communityVM.removeCommunity(withId: community.id)
                    }
                )
            }
            
            CommunityContentCard(
                username: "Anonymous",
                content: "Hang in there! Even the toughest days have 24 hours. You're stronger than you think and this too shall pass 🌟",
                timestamp: "June 25, 2024",
                initialLikeCount: 323,
                hashtags: ["#KeepGoing", "#StayStrong"],
                communityId: "example1",
                userId: "",
                currentUserId: authVM.user?.uid,
                onDelete: {}
            )

            CommunityContentCard(
                username: "Drphnd",
                content: "Life's challenges can feel overwhelming, but remember that every storm runs out of rain.",
                timestamp: "May 10, 2024",
                initialLikeCount: 112,
                hashtags: ["#MentalHealth", "#StayHopeful"],
                communityId: "example2",
                userId: "",
                currentUserId: authVM.user?.uid,
                onDelete: {}
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

struct ExploreContentView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("Today's Updates")
                    .font(.headline)
                    .foregroundColor(.black)

                VStack(spacing: 16) {
                    TrendingTagRow(tag: "#MorningSelfLove")
                    TrendingTagRow(tag: "#TGIF")
                    TrendingTagRow(tag: "#PositivePeerPressure")
                }
            }
            .padding()
        }
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

// Hex to Color converter
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (
                255, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff
            )
        case 8:
            (a, r, g, b) = (
                (int >> 24) & 0xff, (int >> 16) & 0xff, (int >> 8) & 0xff,
                int & 0xff
            )
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Preview
#Preview {
    CommunityView()
}
