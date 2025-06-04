// ALP_Slayvega/iOSConnectivity.swift
import WatchConnectivity
import Foundation
import FirebaseDatabase

class iOSConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 180.0
    private let maxPostsToSend = 15

    @Published var isWatchReachable: Bool = false
    @Published var connectionStatusMessage: String = "Initializing..."
    @Published var lastSyncTime: Date?
    @Published var syncInProgress: Bool = false
    @Published var lastErrorMessage: String?

    static let shared = iOSConnectivity()

    private override init() {
        session = WCSession.default
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
            print("iOSConnectivity: Session activation initiated.")
        } else {
            print("iOSConnectivity: WCSession not supported on this device.")
            DispatchQueue.main.async {
                self.connectionStatusMessage = "WCSession Not Supported"
                self.lastErrorMessage = "This device does not support Watch Connectivity."
            }
        }
    }

    // MARK: - WCSessionDelegate (iOS)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { //
        DispatchQueue.main.async {
            self.lastErrorMessage = nil //
            switch activationState {
            case .activated:
                self.isWatchReachable = session.isReachable //
                self.connectionStatusMessage = session.isReachable ? "Watch App Connected" : "Watch App Unreachable" //
                print("iOSConnectivity: WCSession activated. Reachable: \(session.isReachable)")
                if session.isReachable { //
                    self.sendCommunityDataToWatch(reason: "Activation & Reachable")
                    self.startAutoSync() //
                }
            case .inactive: //
                self.isWatchReachable = false //
                self.connectionStatusMessage = "Watch Session Inactive" //
                print("iOSConnectivity: WCSession inactive.")
                self.stopAutoSync() //
            case .notActivated: //
                self.isWatchReachable = false //
                self.connectionStatusMessage = "Watch Session Not Activated" //
                print("iOSConnectivity: WCSession not activated.")
                self.stopAutoSync() //
            @unknown default: //
                self.isWatchReachable = false //
                self.connectionStatusMessage = "Unknown Watch Session State" //
                print("iOSConnectivity: WCSession unknown state.")
                self.stopAutoSync() //
            }
        }

        if let error = error { //
            print("iOSConnectivity: WCSession activation error - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Activation Error" //
                self.lastErrorMessage = error.localizedDescription //
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) { //
        DispatchQueue.main.async {
            self.isWatchReachable = false //
            self.connectionStatusMessage = "Watch Session Became Inactive" //
        }
        print("iOSConnectivity: sessionDidBecomeInactive")
        stopAutoSync() //
    }

    func sessionDidDeactivate(_ session: WCSession) { //
        DispatchQueue.main.async {
            self.isWatchReachable = false //
            self.connectionStatusMessage = "Watch Session Deactivated. Re-activating..." //
        }
        print("iOSConnectivity: sessionDidDeactivate. Attempting to reactivate.")
        session.activate() //
    }

    func sessionReachabilityDidChange(_ session: WCSession) { //
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable //
            self.connectionStatusMessage = session.isReachable ? "Watch App Connected" : "Watch App Unreachable" //
            print("iOSConnectivity: Reachability changed. Reachable: \(session.isReachable)")
            if session.isReachable { //
                self.lastErrorMessage = nil //
                self.sendCommunityDataToWatch(reason: "Reachability Changed & Reachable") //
                self.startAutoSync() //
            } else {
                self.stopAutoSync() //
            }
        }
    }
    
    // MARK: - Message Handling from Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) { //
        print("iOSConnectivity: Received message from Watch: \(message)")
        DispatchQueue.main.async { self.lastErrorMessage = nil } //

        if let action = message["action"] as? String { //
            switch action {
            case "requestCommunities": //
                print("iOSConnectivity: Watch requested community data.")
                let ackReply = ["status": "processingRequest", "receivedAt": Date().timeIntervalSince1970] as [String : Any]
                print("iOSConnectivity: Sending ACK to Watch for requestCommunities: \(ackReply)")
                replyHandler(ackReply) //
                sendCommunityDataToWatch(reason: "Watch Requested Communities")
                
            case "requestComments":
                print("iOSConnectivity: Watch requested comments.")
                if let communityId = message["communityId"] as? String {
                    print("iOSConnectivity: communityId for comments: \(communityId)")
                    let ackReply = ["status": "processingCommentRequest", "communityId": communityId, "receivedAt": Date().timeIntervalSince1970] as [String : Any]
                    print("iOSConnectivity: Sending ACK to Watch for requestComments: \(ackReply)")
                    replyHandler(ackReply)
                    sendCommentsToWatch(for: communityId, reason: "Watch Requested Comments")
                } else {
                    print("iOSConnectivity: Missing communityId in requestComments from Watch.")
                    replyHandler(["status": "error", "errorMessage": "Missing communityId"])
                }
                
            case "pingTest": //
                let pingReply = ["status": "pong", "phoneTimestamp": Date().timeIntervalSince1970] as [String : Any] //
                print("iOSConnectivity: Watch sent pingTest. Replying: \(pingReply)")
                replyHandler(pingReply) //
                
            default: //
                let unknownReply = ["status": "unknownAction", "actionReceived": action] as [String : Any] //
                print("iOSConnectivity: Watch sent unknown action '\(action)'. Replying: \(unknownReply)")
                replyHandler(unknownReply) //
            }
        } else { //
            let invalidReply = ["status": "invalidMessageFormat"] as [String : Any] //
            print("iOSConnectivity: Watch sent invalid message format. Replying: \(invalidReply)")
            replyHandler(invalidReply) //
        }
    }

    // MARK: - Data Transfer Logic (iOS to Watch)
    func sendCommunityDataToWatch(reason: String, completion: ((Bool, String?) -> Void)? = nil) { //
        print("iOSConnectivity: Sending community data. Reason: \(reason)")
        guard session.activationState == .activated else { //
            print("iOSConnectivity: Session not active. Cannot send community data."); completion?(false, "iOS Session not active."); return
        }
        guard self.isWatchReachable else {
            print("iOSConnectivity: Watch not reachable. Cannot send community data."); completion?(false, "Watch not reachable."); return
        }
        DispatchQueue.main.async {
            guard !self.syncInProgress else { print("iOSConnectivity: Sync in progress."); completion?(false, "Sync in progress."); return } //
            self.syncInProgress = true; self.connectionStatusMessage = "Syncing Posts..."; self.lastErrorMessage = nil //
        }
        
        let dbRef = Database.database().reference().child("communities") //
        dbRef.queryOrdered(byChild: "communityDates").queryLimited(toLast: UInt(maxPostsToSend * 2)) //
            .observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { completion?(false, "self deallocated"); return }
            guard snapshot.exists() else {
                print("iOSConnectivity: No community data from Firebase.")
                self.sendEmptyUpdateToWatch(dataType: "communityUpdate", forId: nil, completion: completion)
                return
            }
            var communitiesPayload: [[String: Any]] = [] //
            var rawCommunities: [CommunityModel] = [] //
            for case let child as DataSnapshot in snapshot.children { //
                if let data = child.value as? [String: Any] { //
                    var communityDate = Date() //
                    if let timestamp = data["communityDates"] as? TimeInterval { communityDate = Date(timeIntervalSince1970: timestamp / 1000) } //
                    else if let dateString = data["communityDates"] as? String { communityDate = ISO8601DateFormatter().date(from: dateString) ?? Date() } //
                    rawCommunities.append(CommunityModel( //
                        id: data["id"] as? String ?? child.key, username: data["username"] as? String ?? "Anonymous", //
                        communityContent: data["communityContent"] as? String ?? "", hashtags: data["hashtags"] as? String ?? "", //
                        communityLikeCount: data["communityLikeCount"] as? Int ?? 0, communityDates: communityDate, userId: data["userId"] as? String ?? "" //
                    ))
                }
            }
            let sortedCommunities = rawCommunities.sorted { $0.communityDates > $1.communityDates }.prefix(self.maxPostsToSend) //
            for community in sortedCommunities { //
                let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .short //
                communitiesPayload.append([ //
                    "id": community.id, "username": community.username, "communityContent": community.communityContent, //
                    "hashtags": community.hashtags, "communityLikeCount": community.communityLikeCount, //
                    "formattedDate": formatter.string(from: community.communityDates), "userId": community.userId //
                ])
            }
            let message = ["dataType": "communityUpdate", "communities": communitiesPayload, "timestamp": Date().timeIntervalSince1970, "count": communitiesPayload.count] as [String : Any] //
            self.sendMessageToWatch(message: message, description: "Community Data", completion: completion)
        }) { error in //
            self.handleFirebaseError(error, description: "Community Data Fetch", completion: completion)
        }
    }

    func sendCommentsToWatch(for communityId: String, reason: String, completion: ((Bool, String?) -> Void)? = nil) {
        print("iOSConnectivity: Sending comments for \(communityId). Reason: \(reason)")
        guard session.activationState == .activated else {
            print("iOSConnectivity: Session not active. Cannot send comments."); completion?(false, "iOS Session not active."); return
        }
        guard self.isWatchReachable else {
            print("iOSConnectivity: Watch not reachable. Cannot send comments."); completion?(false, "Watch not reachable."); return
        }
        // No syncInProgress check for comments, as it's a separate request type
        
        let commentsRef = Database.database().reference().child("comments")
        commentsRef.queryOrdered(byChild: "CommunityId").queryEqual(toValue: communityId)
            .observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { completion?(false, "self deallocated"); return }
            guard snapshot.exists() else {
                print("iOSConnectivity: No comments for \(communityId).")
                self.sendEmptyUpdateToWatch(dataType: "commentUpdate", forId: communityId, completion: completion)
                return
            }
            var commentsPayload: [[String: Any]] = []
            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any] {
                    var commentDate = Date()
                    if let timestamp = data["CommentDates"] as? TimeInterval { commentDate = Date(timeIntervalSince1970: timestamp / 1000) }
                    else if let dateString = data["CommentDates"] as? String { commentDate = ISO8601DateFormatter().date(from: dateString) ?? Date() }
                    let formatter = DateFormatter(); formatter.dateStyle = .short; formatter.timeStyle = .short
                    commentsPayload.append([
                        "id": data["CommentId"] as? String ?? child.key, "username": data["Username"] as? String ?? "Anonymous",
                        "commentContent": data["CommentContent"] as? String ?? "",
                        "formattedDate": formatter.string(from: commentDate),
                        "communityId": data["CommunityId"] as? String ?? ""
                        // "commentLikeCount": data["CommentLikeCount"] as? Int ?? 0 // If needed
                    ])
                }
            }
            let message = ["dataType": "commentUpdate", "comments": commentsPayload, "communityId": communityId, "timestamp": Date().timeIntervalSince1970, "count": commentsPayload.count] as [String : Any]
            self.sendMessageToWatch(message: message, description: "Comments Data for \(communityId)", completion: completion)
        }) { error in
            self.handleFirebaseError(error, description: "Comments Fetch for \(communityId)", completion: completion)
        }
    }

    private func sendEmptyUpdateToWatch(dataType: String, forId: String?, completion: ((Bool, String?) -> Void)?) {
        DispatchQueue.main.async { self.syncInProgress = false } // Reset if it was for main community data
        var message: [String: Any] = [
            "dataType": dataType,
            "timestamp": Date().timeIntervalSince1970,
            "count": 0
        ]
        if dataType == "communityUpdate" { message["communities"] = [] }
        if dataType == "commentUpdate" {
            message["comments"] = []
            message["communityId"] = forId ?? ""
        }
        
        self.sendMessageToWatch(message: message, description: "Empty \(dataType)", completion: completion)
        completion?(true, "No data found, empty list sent for \(dataType).")
    }
    
    private func sendMessageToWatch(message: [String: Any], description: String, completion: ((Bool, String?) -> Void)?) {
        print("iOSConnectivity: Sending \(description) to Watch: \(message.keys)")
        self.session.sendMessage(message, replyHandler: { reply in //
            DispatchQueue.main.async {
                if message["dataType"] as? String == "communityUpdate" { // Only reset for main community sync
                    self.syncInProgress = false //
                    self.lastSyncTime = Date() //
                }
                self.connectionStatusMessage = "Watch Ack: \(description)." //
                self.lastErrorMessage = nil //
                print("iOSConnectivity: Watch ack \(description). Reply: \(reply)")
            }
            completion?(true, nil)
        }, errorHandler: { error in //
            DispatchQueue.main.async {
                if message["dataType"] as? String == "communityUpdate" { self.syncInProgress = false } //
                self.connectionStatusMessage = "\(description) Send Error" //
                self.lastErrorMessage = error.localizedDescription //
                print("iOSConnectivity: Error sending \(description) to Watch: \(error.localizedDescription)")
            }
            completion?(false, error.localizedDescription)
        })
    }

    private func handleFirebaseError(_ error: Error, description: String, completion: ((Bool, String?) -> Void)?) {
        print("iOSConnectivity: Firebase \(description) error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            if description.contains("Community") { self.syncInProgress = false }
            self.connectionStatusMessage = "DB Error (\(description.prefix(4)))"
            self.lastErrorMessage = "Firebase error: \(error.localizedDescription)"
        }
        completion?(false, "Database error (\(description)): \(error.localizedDescription)")
    }

    // MARK: - Sync Management
    func startAutoSync() { //
        stopAutoSync() //
        guard self.isWatchReachable else { return }
        print("iOSConnectivity: Starting auto-sync timer.")
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in //
            guard let self = self, self.isWatchReachable && !self.syncInProgress else { return } //
            print("iOSConnectivity: Auto-sync triggered for community posts.")
            self.sendCommunityDataToWatch(reason: "Auto Sync Timer") //
        }
    }

    func stopAutoSync() { //
        print("iOSConnectivity: Stopping auto-sync timer.")
        syncTimer?.invalidate() //
        syncTimer = nil //
    }
    
    func manualSyncWithWatch() { //
        print("iOSConnectivity: Manual sync (community) triggered.")
        sendCommunityDataToWatch(reason: "Manual Sync Button") { success, errorStr in //
            if !success { DispatchQueue.main.async { self.connectionStatusMessage = "Manual Sync Failed"; if let err = errorStr { self.lastErrorMessage = err } } }
        }
    }
    
    deinit { //
        stopAutoSync() //
        print("iOSConnectivity deinitialized.")
    }
}
