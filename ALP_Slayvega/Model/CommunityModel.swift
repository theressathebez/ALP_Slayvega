//
//  CommunityModel.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import Foundation

struct CommunityModel: Identifiable, Hashable, Codable{
    var id:String = UUID().uuidString
    var username:String = ""
    var communityContent:String = ""
    var hashtags:String = ""
    var communityLikeCount:Int = 0
    var communityDates:Date = Date()
    var userId:String = ""
}
