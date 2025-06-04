//
//  Untitled.swift
//  ALP_Slayvega
//
//  Created by student on 04/06/25.
//

import Foundation

struct WatchCommentModel: Identifiable, Codable, Hashable {
    let id: String // Ini adalah CommentId dari Firebase
    let username: String
    let commentContent: String
    let formattedDate: String // Tanggal yang sudah diformat dari iOS
    let communityId: String // ID dari post komunitas induknya
    // let commentLikeCount: Int // Opsional, jika Anda ingin menampilkannya
}
