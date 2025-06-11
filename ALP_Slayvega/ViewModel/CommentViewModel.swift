//
//  CommentViewModel.swift
//  ALP_Slayvega
//
//  Created by student on 30/05/25.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

class CommentViewModel: ObservableObject {
    @Published var comments: [CommentModel] = []
    @Published var isLoading: Bool = false
    @Published var userLikes: [String: Bool] = [:]

    private var dbRef = Database.database().reference().child("comments")
    private var likesRef = Database.database().reference().child(
        "comment_likes")
    private var commentsListener: DatabaseHandle?

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    deinit {
        if let handle = commentsListener {
            dbRef.removeObserver(withHandle: handle)
        }
    }

    func loadComments(for communityId: String) {
        if let handle = commentsListener {
            dbRef.removeObserver(withHandle: handle)
        }

        isLoading = true

        commentsListener =
            dbRef
            .queryOrdered(byChild: "CommunityId")
            .queryEqual(toValue: communityId)
            .observe(.value) { [weak self] snapshot in
                guard let self = self else { return }
                var fetchedComments: [CommentModel] = []

                for case let child as DataSnapshot in snapshot.children {
                    if let data = child.value as? [String: Any] {
                        var commentDate = Date()
                        if let timestamp = data["CommentDates"] as? TimeInterval
                        {
                            commentDate = Date(
                                timeIntervalSince1970: timestamp / 1000)
                        } else if let dateString = data["CommentDates"]
                            as? String
                        {
                            let formatter = ISO8601DateFormatter()
                            commentDate =
                                formatter.date(from: dateString) ?? Date()
                        }

                        let comment = CommentModel(
                            CommentId: data["CommentId"] as? String
                                ?? child.key,
                            Username: data["Username"] as? String ?? "",
                            CommentContent: data["CommentContent"] as? String
                                ?? "",
                            CommentLikeCount: data["CommentLikeCount"] as? Int
                                ?? 0,
                            CommentDates: commentDate,
                            userId: data["userId"] as? String ?? "",
                            CommunityId: data["CommunityId"] as? String ?? ""
                        )
                        fetchedComments.append(comment)
                    }
                }

                DispatchQueue.main.async {
                    self.comments = fetchedComments.sorted {
                        $0.CommentDates > $1.CommentDates
                    }
                    self.isLoading = false

                    self.loadUserLikes()
                }
            }
    }

    private func loadUserLikes() {
        guard let uid = userId else { return }

        for comment in comments {
            likesRef.child(comment.CommentId).child(uid).observeSingleEvent(
                of: .value
            ) { [weak self] snapshot in
                DispatchQueue.main.async {
                    self?.userLikes[comment.CommentId] = snapshot.exists()
                }
            }
        }
    }

    func addComment(content: String, username: String, communityId: String) {
        guard let uid = userId,
            !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

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
            "CommentDates": newComment.CommentDates.timeIntervalSince1970
                * 1000,  // Convert to milliseconds
            "userId": newComment.userId,
            "CommunityId": newComment.CommunityId,
        ]

        dbRef.child(commentId).setValue(commentDict) { error, _ in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }

    // Delete comment (only by comment owner)
    func deleteComment(commentId: String) {
        // Also delete all likes for this comment
        likesRef.child(commentId).removeValue()

        dbRef.child(commentId).removeValue { error, _ in
            if let error = error {
                print("Error deleting comment: \(error.localizedDescription)")
            }
        }
    }

    // Toggle like with realtime update
    func toggleCommentLike(commentId: String) {
        guard let uid = userId else { return }

        let isCurrentlyLiked = userLikes[commentId] ?? false
        let newLikedState = !isCurrentlyLiked

        // Update local state immediately for smooth UX
        userLikes[commentId] = newLikedState

        // Reference to the specific like
        let userLikeRef = likesRef.child(commentId).child(uid)
        let commentLikeCountRef = dbRef.child(commentId).child(
            "CommentLikeCount")

        if newLikedState {
            // User is liking the comment
            userLikeRef.setValue(true) { [weak self] error, _ in
                if error != nil {
                    // Revert local state if failed
                    DispatchQueue.main.async {
                        self?.userLikes[commentId] = false
                    }
                }
            }

            // Increment like count
            commentLikeCountRef.runTransactionBlock { currentData in
                if let currentCount = currentData.value as? Int {
                    currentData.value = currentCount + 1
                } else {
                    currentData.value = 1
                }
                return TransactionResult.success(withValue: currentData)
            }

        } else {
            // User is unliking the comment
            userLikeRef.removeValue { [weak self] error, _ in
                if error != nil {
                    // Revert local state if failed
                    DispatchQueue.main.async {
                        self?.userLikes[commentId] = true
                    }
                }
            }

            // Decrement like count
            commentLikeCountRef.runTransactionBlock { currentData in
                if let currentCount = currentData.value as? Int {
                    currentData.value = max(0, currentCount - 1)
                } else {
                    currentData.value = 0
                }
                return TransactionResult.success(withValue: currentData)
            }
        }
    }

    // Check if current user liked a specific comment
    func isCommentLikedByUser(commentId: String) -> Bool {
        return userLikes[commentId] ?? false
    }

    // Clear comments when leaving the view
    func clearComments() {
        if let handle = commentsListener {
            dbRef.removeObserver(withHandle: handle)
            commentsListener = nil
        }
        comments.removeAll()
        userLikes.removeAll()
    }
}
