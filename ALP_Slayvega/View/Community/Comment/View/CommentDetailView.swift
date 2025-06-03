//
//  CommentDetailView.swift
//  ALP_Slayvega
//
//  Created by student on 30/05/25.
//
//

import SwiftUI
import FirebaseAuth

struct CommentDetailView: View {
    let community: CommunityModel
    let authVM: AuthViewModel
    
    @StateObject private var commentVM = CommentViewModel()
    @State private var newCommentText: String = ""
    @State private var showUsername: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Back") {
                    dismiss()
                }
                .foregroundColor(Color.fromHex( "#FFA075"))
                
                Spacer()
                
                Text("Comments")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Placeholder for balance
                Text("Back")
                    .opacity(0)
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // Original Post
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(community.username)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(formatDate(community.communityDates))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(community.communityContent)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if !community.hashtags.isEmpty {
                    Text(community.hashtags)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(Color.fromHex("#FFA075"))
                }
                
                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                    Text("\(community.communityLikeCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "bubble.right")
                        .foregroundColor(.gray)
                    Text("\(commentVM.comments.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Comments Section
            ScrollView {
                LazyVStack(spacing: 12) {
                    if commentVM.isLoading {
                        ProgressView("Loading comments...")
                            .padding()
                    } else if commentVM.comments.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("No comments yet")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text("Be the first to share your thoughts!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(commentVM.comments, id: \.CommentId) { comment in
                            CommentCard(
                                comment: comment,
                                currentUserId: authVM.user?.uid,
                                isLiked: commentVM.isCommentLikedByUser(commentId: comment.CommentId),
                                onDelete: {
                                    commentVM.deleteComment(commentId: comment.CommentId)
                                },
                                onLike: {
                                    commentVM.toggleCommentLike(commentId: comment.CommentId)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            
            // Comment Input
            VStack(spacing: 8) {
                HStack {
                    Toggle(isOn: $showUsername) {
                        Text("Show Username")
                            .font(.caption)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.fromHex("#FFA075")))
                    .scaleEffect(0.8)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $newCommentText, axis: .vertical)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .lineLimit(1...4)
                    
                    Button(action: {
                        sendComment()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(12)
                            .background(
                                newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                Color.gray : Color.fromHex("#FFA075")
                            )
                            .clipShape(Circle())
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1)
        }
        .background(Color(red: 239 / 255, green: 245 / 255, blue: 255 / 255))
        .navigationBarHidden(true)
        .onAppear {
            commentVM.loadComments(for: community.id)
        }
        .onDisappear {
            commentVM.clearComments()
        }
    }
    
    private func sendComment() {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let displayUsername = showUsername ? authVM.myUser.getDisplayName() : "Anonymous"
        
        commentVM.addComment(
            content: newCommentText,
            username: displayUsername,
            communityId: community.id
        )
        
        newCommentText = ""
        showUsername = false
        
        // Hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CommentCard: View {
    let comment: CommentModel
    let currentUserId: String?
    let isLiked: Bool
    let onDelete: () -> Void
    let onLike: () -> Void
    
    @State private var showDeleteAlert: Bool = false
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.Username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(formatCommentDate(comment.CommentDates))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // Delete button for comment owner
                if comment.userId == currentUserId && !comment.userId.isEmpty {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Text(comment.CommentContent)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isAnimating = true
                    }
                    
                    onLike()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isAnimating = false
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                            .font(.system(size: 14))
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                        
                        Text("\(comment.CommentLikeCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        .alert("Delete Comment", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this comment?")
        }
    }
    
    private func formatCommentDate(_ date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h"
        } else {
            let days = Int(timeInterval / 86400)
            if days < 7 {
                return "\(days)d"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter.string(from: date)
            }
        }
    }
}


#Preview {
    CommentDetailView(
        community: CommunityModel(
            username: "TestUser",
            communityContent: "This is a test post for preview",
            hashtags: "#Test #Preview",
            communityLikeCount: 5,
            communityDates: Date()
        ),
        authVM: AuthViewModel()
    )
}
