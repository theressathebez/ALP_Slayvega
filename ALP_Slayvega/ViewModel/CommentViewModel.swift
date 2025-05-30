//
//  CommentViewModel.swift
//  ALP_Slayvega
//
//  Created by student on 30/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class CommentViewModel: ObservableObject {
    @Published var comments: [CommentModel] = []
    @Published var isLoading: Bool = false
    
    private var dbRef = Database.database().reference().child("comments")
    private var commentsListener: DatabaseHandle?
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    deinit {
        if let handle = commentsListener {
            dbRef.removeObserver(withHandle: handle)
        }
    }
    
    // Load comments for specific community post
    func loadComments(for communityId: String) {
        // Remove existing listener if any
        if let handle = commentsListener {
            dbRef.removeObserver(withHandle: handle)
        }
        
        isLoading = true
        
        commentsListener = dbRef
            .queryOrdered(byChild: "CommunityId")
            .queryEqual(toValue: communityId)
            .observe(.value) { [weak self] snapshot in
                guard let self = self else { return }
                var fetchedComments: [CommentModel] = []
                
                for case let child as DataSnapshot in snapshot.children {
                    if let data = child.value as? [String: Any] {
                        // Handle date parsing from Firebase
                        var commentDate = Date()
                        if let timestamp = data["CommentDates"] as? TimeInterval {
                            commentDate = Date(timeIntervalSince1970: timestamp / 1000)
                        } else if let dateString = data["CommentDates"] as? String {
                            let formatter = ISO8601DateFormatter()
                            commentDate = formatter.date(from: dateString) ?? Date()
                        }
                        
                        let comment = CommentModel(
                            CommentId: data["CommentId"] as? String ?? child.key,
                            Username: data["Username"] as? String ?? "",
                            CommentContent: data["CommentContent"] as? String ?? "",
                            CommentLikeCount: data["CommentLikeCount"] as? Int ?? 0,
                            CommentDates: commentDate,
                            userId: data["userId"] as? String ?? "",
                            CommunityId: data["CommunityId"] as? String ?? ""
                        )
                        fetchedComments.append(comment)
                    }
                }
                
                DispatchQueue.main.async {
                    // Sort comments by date (newest first)
                    self.comments = fetchedComments.sorted { $0.CommentDates > $1.CommentDates }
                    self.isLoading = false
                }
            }
    }
    
    // Add new comment
    func addComment(content: String, username: String, communityId: String) {
        guard let uid = userId, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let commentId = UUID().uuidString
        let newComment = CommentModel(
            CommentId: commentId,
            Username: username,
            CommentContent: content,
            CommentLikeCount: 0,
            CommentDates: Date(),
            userId: uid,
            CommunityId: communityId
        )
        
        // Convert to dictionary for Firebase
        let commentDict: [String: Any] = [
            "CommentId": newComment.CommentId,
            "Username": newComment.Username,
            "CommentContent": newComment.CommentContent,
            "CommentLikeCount": newComment.CommentLikeCount,
            "CommentDates": newComment.CommentDates.timeIntervalSince1970 * 1000, // Convert to milliseconds
            "userId": newComment.userId,
            "CommunityId": newComment.CommunityId
        ]
        
        dbRef.child(commentId).setValue(commentDict) { error, _ in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }
    
    // Delete comment (only by comment owner)
    func deleteComment(commentId: String) {
        dbRef.child(commentId).removeValue { error, _ in
            if let error = error {
                print("Error deleting comment: \(error.localizedDescription)")
            }
        }
    }
    
    // Update comment like count
    func toggleCommentLike(commentId: String, currentLikeCount: Int, isLiked: Bool) {
        let newLikeCount = isLiked ? currentLikeCount + 1 : currentLikeCount - 1
        dbRef.child(commentId).child("CommentLikeCount").setValue(max(0, newLikeCount)) { error, _ in
            if let error = error {
                print("Error updating like count: \(error.localizedDescription)")
            }
        }
    }
    
    // Clear comments when leaving the view
    func clearComments() {
        if let handle = commentsListener {
            dbRef.removeObserver(withHandle: handle)
            commentsListener = nil
        }
        comments.removeAll()
    }
}
