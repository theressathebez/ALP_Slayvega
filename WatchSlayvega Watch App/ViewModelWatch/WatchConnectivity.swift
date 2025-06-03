//
//  WatchConnectivity.swift
//  WatchSlayvega Watch App
//
//  Created by student on 03/06/25.
//

import WatchConnectivity
import Foundation

// MARK: - Watch Data Models
struct WatchCommunityModel: Identifiable, Hashable {
    let id: String
    let username: String
    let communityContent: String
    let hashtags: String
    let communityLikeCount: Int
    let formattedDate: String
    let userId: String
}

struct WatchCommentModel: Identifiable, Hashable {
    let id: String
    let username: String
    let commentContent: String
    let commentLikeCount: Int
    let formattedDate: String
    let userId: String
    let communityId: String
}

class WatchConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    
    @Published var communities: [WatchCommunityModel] = []
    @Published var comments: [WatchCommentModel] = []
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedCommunityId: String = ""
    
    override init() {
        session = WCSession.default
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
        }
        
        print("Watch WC Session activation completed with state: \(activationState)")
        if let error = error {
            print("Watch WC Session activation error: \(error.localizedDescription)")
        }
        
        // Request initial data when activated
        if activationState == .activated {
            requestCommunities()
        }
    }
    
    // MARK: - Receive Messages from iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let communitiesData = message["communities"] as? [[String: Any]] {
                self.parseCommunities(from: communitiesData)
            }
            
            if let commentsData = message["comments"] as? [[String: Any]],
               let communityId = message["communityId"] as? String {
                self.parseComments(from: commentsData, for: communityId)
            }
        }
    }
    
    // MARK: - Parse Community Data
    private func parseCommunities(from data: [[String: Any]]) {
        var parsedCommunities: [WatchCommunityModel] = []
        
        for communityData in data {
            let community = WatchCommunityModel(
                id: communityData["id"] as? String ?? UUID().uuidString,
                username: communityData["username"] as? String ?? "Anonymous",
                communityContent: communityData["communityContent"] as? String ?? "",
                hashtags: communityData["hashtags"] as? String ?? "",
                communityLikeCount: communityData["communityLikeCount"] as? Int ?? 0,
                formattedDate: communityData["formattedDate"] as? String ?? "",
                userId: communityData["userId"] as? String ?? ""
            )
            parsedCommunities.append(community)
        }
        
        self.communities = parsedCommunities
        self.isLoading = false
        print("Received \(parsedCommunities.count) communities on watch")
    }
    
    // MARK: - Parse Comments Data
    private func parseComments(from data: [[String: Any]], for communityId: String) {
        guard communityId == selectedCommunityId else { return }
        
        var parsedComments: [WatchCommentModel] = []
        
        for commentData in data {
            let comment = WatchCommentModel(
                id: commentData["CommentId"] as? String ?? UUID().uuidString,
                username: commentData["Username"] as? String ?? "Anonymous",
                commentContent: commentData["CommentContent"] as? String ?? "",
                commentLikeCount: commentData["CommentLikeCount"] as? Int ?? 0,
                formattedDate: commentData["formattedDate"] as? String ?? "",
                userId: commentData["userId"] as? String ?? "",
                communityId: commentData["CommunityId"] as? String ?? ""
            )
            parsedComments.append(comment)
        }
        
        self.comments = parsedComments
        self.isLoading = false
        print("Received \(parsedComments.count) comments for community \(communityId)")
    }
    
    // MARK: - Request Data from iPhone
    func requestCommunities() {
        guard session.isReachable else {
            print("iPhone is not reachable")
            return
        }
        
        isLoading = true
        let message = ["action": "requestCommunities"]
        
        session.sendMessage(message, replyHandler: { reply in
            print("Communities request sent successfully: \(reply)")
        }, errorHandler: { error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            print("Error requesting communities: \(error.localizedDescription)")
        })
    }
    
    func requestComments(for communityId: String) {
        guard session.isReachable else {
            print("iPhone is not reachable")
            return
        }
        
        selectedCommunityId = communityId
        isLoading = true
        comments.removeAll() // Clear previous comments
        
        let message = [
            "action": "requestComments",
            "communityId": communityId
        ]
        
        session.sendMessage(message, replyHandler: { reply in
            print("Comments request sent successfully: \(reply)")
        }, errorHandler: { error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            print("Error requesting comments: \(error.localizedDescription)")
        })
    }
    
    // MARK: - Refresh Data
    func refreshCommunities() {
        requestCommunities()
    }
    
    func refreshComments() {
        guard !selectedCommunityId.isEmpty else { return }
        requestComments(for: selectedCommunityId)
    }
}
