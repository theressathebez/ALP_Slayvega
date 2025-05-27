//
//  CommunityContentCard.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//
import SwiftUI

struct CommunityContentCard: View {
    var username: String
    var content: String
    var timestamp: String
    var initialLikeCount: Int
    var hashtags: [String]
    var communityId: String
    var userId: String // Add userId to identify post owner
    var currentUserId: String? // Current logged in user ID
    var onDelete: () -> Void
    
    @State private var isLiked: Bool = false
    @State private var currentLikeCount: Int = 0
    @State private var showDeleteAlert: Bool = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(username)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Delete button (only show for user's own posts)
                    if userId == currentUserId && userId != "" {
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 5)

                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.bottom, 1)
                
                Text(hashtags.joined(separator: " "))
                    .fontWeight(.bold)

                HStack {
                    Text(timestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    // Comment Button
                    Button(action: {
                        print("Comment button tapped")
                    }) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Like Button
                    Button(action: {
                        isLiked.toggle()
                        currentLikeCount += isLiked ? 1 : -1
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                            .font(.system(size: 18))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text("\(currentLikeCount)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            .padding(25)
            .background(Color(.white))
            .cornerRadius(30)
            .shadow(radius: 1)
        }
        .onAppear {
            currentLikeCount = initialLikeCount
        }
        .alert("Delete Post", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this post?")
        }
    }
}

#Preview {
    CommunityContentCard(
        username: "Anonymous",
        content: "Hang in there! Even the toughest days have 24 hours. You're stronger than you think and this too shall pass 🌟",
        timestamp: "June 25, 2024",
        initialLikeCount: 10,
        hashtags: ["#KeepGoing", "#StayStrong"],
        communityId: "preview",
        userId: "",
        currentUserId: nil,
        onDelete: {}
    )
}
