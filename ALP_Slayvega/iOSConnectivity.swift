//
//  iOSConnectivity.swift
//  ALP_Slayvega
//
//  Created by student on 03/06/25.
//

import WatchConnectivity
import Foundation
import FirebaseDatabase
import FirebaseAuth

class iOSConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    
    override init() {
        session = WCSession.default
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS WC Session activation completed with state: \(activationState)")
        if let error = error {
            print("iOS WC Session activation error: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS WC Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iOS WC Session deactivated")
        session.activate()
    }
    
    // MARK: - Send Community Data to Watch
    func sendCommunityDataToWatch() {
        guard session.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        // Fetch communities from Firebase
        let dbRef = Database.database().reference().child("communities")
        dbRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            var communities: [[String: Any]] = []
            
            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any] {
                    // Convert timestamp to readable format
                    var communityData = data
                    if let timestamp = data["communityDates"] as? TimeInterval {
                        let date = Date(timeIntervalSince1970: timestamp / 1000)
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .short
                        communityData["formattedDate"] = formatter.string(from: date)
                    }
                    
                    // Only send necessary data to watch
                    let watchData: [String: Any] = [
                        "id": communityData["id"] as? String ?? child.key,
                        "username": communityData["username"] as? String ?? "Anonymous",
                        "communityContent": communityData["communityContent"] as? String ?? "",
                        "hashtags": communityData["hashtags"] as? String ?? "",
                        "communityLikeCount": communityData["communityLikeCount"] as? Int ?? 0,
                        "formattedDate": communityData["formattedDate"] as? String ?? "",
                        "userId": communityData["userId"] as? String ?? ""
                    ]
                    
                    communities.append(watchData)
                }
            }
            
            // Sort by like count (most liked first) and limit to recent posts
            communities.sort { ($0["communityLikeCount"] as? Int ?? 0) > ($1["communityLikeCount"] as? Int ?? 0) }
            let recentCommunities = Array(communities.prefix(10)) // Limit to 10 posts
            
            let message = ["communities": recentCommunities]
            
            self.session.sendMessage(message, replyHandler: { reply in
                print("Successfully sent communities to watch: \(reply)")
            }, errorHandler: { error in
                print("Error sending communities to watch: \(error.localizedDescription)")
            })
        }
    }
    
    // MARK: - Send Comments for Specific Community
    func sendCommentsToWatch(for communityId: String) {
        guard session.isReachable else {
            print("Watch is not reachable")
            return
        }
        
        let dbRef = Database.database().reference().child("comments")
        dbRef.queryOrdered(byChild: "CommunityId")
           .queryEqual(toValue: communityId)
           .observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            var comments: [[String: Any]] = []
            
            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any] {
                    // Convert timestamp to readable format
                    var commentData = data
                    if let timestamp = data["CommentDates"] as? TimeInterval {
                        let date = Date(timeIntervalSince1970: timestamp / 1000)
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .short
                        commentData["formattedDate"] = formatter.string(from: date)
                    }
                    
                    // Only send necessary data to watch
                    let watchData: [String: Any] = [
                        "CommentId": commentData["CommentId"] as? String ?? child.key,
                        "Username": commentData["Username"] as? String ?? "Anonymous",
                        "CommentContent": commentData["CommentContent"] as? String ?? "",
                        "CommentLikeCount": commentData["CommentLikeCount"] as? Int ?? 0,
                        "formattedDate": commentData["formattedDate"] as? String ?? "",
                        "userId": commentData["userId"] as? String ?? "",
                        "CommunityId": commentData["CommunityId"] as? String ?? ""
                    ]
                    
                    comments.append(watchData)
                }
            }
            
            // Sort by date (newest first)
            comments.sort {
                let date1 = ($0["CommentDates"] as? TimeInterval) ?? 0
                let date2 = ($1["CommentDates"] as? TimeInterval) ?? 0
                return date1 > date2
            }
            
            let message = [
                "comments": comments,
                "communityId": communityId
            ]
            
            self.session.sendMessage(message, replyHandler: { reply in
                print("Successfully sent comments to watch: \(reply)")
            }, errorHandler: { error in
                print("Error sending comments to watch: \(error.localizedDescription)")
            })
        }
    }
    
    // MARK: - Handle Watch Requests
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let action = message["action"] as? String {
            switch action {
            case "requestCommunities":
                // Send communities immediately when watch requests
                sendCommunityDataToWatch()
                replyHandler(["status": "communities_sent"])
                
            case "requestComments":
                if let communityId = message["communityId"] as? String {
                    sendCommentsToWatch(for: communityId)
                    replyHandler(["status": "comments_sent"])
                } else {
                    replyHandler(["status": "error", "message": "communityId required"])
                }
                
            default:
                replyHandler(["status": "unknown_action"])
            }
        } else {
            replyHandler(["status": "no_action"])
        }
    }
    
    // MARK: - Auto-sync when app becomes active
    func startAutoSync() {
        // Send initial data
        sendCommunityDataToWatch()
        
        // Set up periodic sync (every 30 seconds when watch is reachable)
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self, self.session.isReachable else { return }
            self.sendCommunityDataToWatch()
        }
    }
}
