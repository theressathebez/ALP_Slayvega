//
//  WatchCommunityPostDetailView.swift
//  ALP_Slayvega
//
//  Created by student on 04/06/25.
//

// WatchSlayvega Watch App/View/WatchCommunityPostDetailView.swift
import SwiftUI

struct WatchCommunityPostDetailView: View {
    let communityPost: WatchCommunityModel
    @ObservedObject var connectivity: WatchConnectivity // Terima instance yang sudah ada

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Detail Post Utama
                VStack(alignment: .leading, spacing: 4) {
                    Text(communityPost.username)
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text(communityPost.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(communityPost.communityContent)
                        .font(.body)
                        .padding(.top, 2)
                    if !communityPost.hashtags.isEmpty {
                        Text(communityPost.hashtags)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Image(systemName: "heart.fill").font(.caption).foregroundColor(.red)
                        Text("\(communityPost.communityLikeCount) likes")
                        Spacer()
                    }
                    .font(.caption)
                }
                .padding(.bottom, 8)

                Divider()
                Text("Comments (\(connectivity.currentPostComments.count))")
                    .font(.headline)
                    .padding(.vertical, 5)

                // Daftar Komentar
                if connectivity.isLoadingComments {
                    ProgressView("Loading comments...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMsg = connectivity.commentsErrorMessage, connectivity.currentPostComments.isEmpty {
                    Text("Error loading comments: \(errorMsg)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if connectivity.currentPostComments.isEmpty {
                    Text("No comments yet for this post.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(connectivity.currentPostComments) { comment in
                        WatchCommentRow(comment: comment)
                        if comment.id != connectivity.currentPostComments.last?.id { // Hindari divider setelah item terakhir
                           Divider().padding(.leading)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("WatchCommunityPostDetailView: Appeared for post ID \(communityPost.id). Requesting comments.")
            // Meminta komentar ketika view muncul
            connectivity.requestCommentsForPost(communityId: communityPost.id)
        }
        .onDisappear {
            print("WatchCommunityPostDetailView: Disappeared for post ID \(communityPost.id). Clearing comments.")
            // Membersihkan komentar ketika view hilang untuk menghindari data lama ditampilkan sekilas
            connectivity.clearCurrentPostComments()
        }
    }
}

struct WatchCommentRow: View {
    let comment: WatchCommentModel

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(comment.username)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.purple) // Warna berbeda untuk user komentar
                Spacer()
                Text(comment.formattedDate)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            Text(comment.commentContent)
                .font(.system(size: 12))
        }
        .padding(.vertical, 4)
    }
}

// Preview (membutuhkan contoh data dan connectivity)
// #Preview {
//     let post = WatchCommunityModel(id: "previewPost123", username: "Angie", communityContent: "Ini adalah contoh post komunitas yang sangat menarik dan informatif untuk dilihat di Apple Watch.", hashtags: "#watchOS #swiftui", communityLikeCount: 25, formattedDate: "4 Jun 2025, 10:30", userId: "userAngie")
//     let connectivity = WatchConnectivity()
//     // Untuk preview, Anda bisa mengisi sample comments:
//     // connectivity.currentPostComments = [
//     //     WatchCommentModel(id: "comment1", username: "Budi", commentContent: "Setuju sekali!", formattedDate: "4 Jun 2025, 10:32", communityId: "previewPost123"),
//     //     WatchCommentModel(id: "comment2", username: "Clara", commentContent: "Mantap infonya.", formattedDate: "4 Jun 2025, 10:35", communityId: "previewPost123")
//     // ]
//     // connectivity.isLoadingComments = false // Set false jika ada data preview
//
//     return NavigationView { // Bungkus dengan NavigationView untuk preview title
//        WatchCommunityPostDetailView(communityPost: post, connectivity: connectivity)
//     }
// }
