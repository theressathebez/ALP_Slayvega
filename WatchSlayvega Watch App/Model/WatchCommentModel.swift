//
//  Untitled.swift
//  ALP_Slayvega
//
//  Created by student on 04/06/25.
//

import Foundation

struct WatchCommentModel: Identifiable, Codable, Hashable {
    var id: String
    var commentContent: String
    var username: String
    var formattedDate: String
    var userId: String
    var communityId: String
}
