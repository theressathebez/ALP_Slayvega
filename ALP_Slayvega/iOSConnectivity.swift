import WatchConnectivity
import Foundation
import FirebaseDatabase

class iOSConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 60.0
    private let maxPostsToSend = 10
    
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
        if activationState == .activated {
            startAutoSync()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        syncTimer?.invalidate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    // MARK: - Data Transfer
    func sendCommunityDataToWatch(completion: @escaping (Bool) -> Void = { _ in }) {
        guard session.isReachable else {
            print("Watch is not reachable")
            completion(false)
            return
        }
        
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
            completion(false)
        }
        
        let dbRef = Database.database().reference().child("communities")
        dbRef.queryOrdered(byChild: "communityLikeCount").queryLimited(toLast: 20).observeSingleEvent(of: .value) { [weak self] snapshot in
            timeoutTimer.invalidate()
            guard let self = self else { return }
            
            var communities: [[String: Any]] = []
            
            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any] {
                    var communityData = data
                    
                    if let timestamp = data["communityDates"] as? TimeInterval {
                        let date = Date(timeIntervalSince1970: timestamp / 1000)
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .short
                        communityData["formattedDate"] = formatter.string(from: date)
                    }
                    
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
            
            // Sort by like count (descending)
            communities.sort { ($0["communityLikeCount"] as? Int ?? 0) > ($1["communityLikeCount"] as? Int ?? 0) }
            
            let limitedCommunities = Array(communities.prefix(self.maxPostsToSend))
            let message = ["communities": limitedCommunities]
            
            self.session.sendMessage(message, replyHandler: { reply in
                print("Sent \(limitedCommunities.count) communities to watch")
                completion(true)
            }, errorHandler: { error in
                print("Error sending communities: \(error.localizedDescription)")
                completion(false)
            })
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let action = message["action"] as? String, action == "requestCommunities" {
            // Immediately acknowledge the request
            replyHandler(["status": "processing"])
            
            // Then send the data
            sendCommunityDataToWatch { success in
                if !success {
                    self.session.sendMessage(["error": "Failed to fetch data"], replyHandler: nil, errorHandler: nil)
                }
            }
        } else {
            replyHandler(["status": "unknown_action"])
        }
    }
    
    // MARK: - Sync Management
    func startAutoSync() {
        syncTimer?.invalidate()
        sendCommunityDataToWatch()
        
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.session.isReachable else { return }
            self.sendCommunityDataToWatch()
        }
    }
    
    func stopAutoSync() {
        syncTimer?.invalidate()
    }
    
    func manualRefreshForWatch() {
        sendCommunityDataToWatch()
    }
    
    // MARK: - Utility Methods
    func isWatchConnected() -> Bool {
        return session.isReachable
    }
    
    func getWatchSessionState() -> String {
        switch session.activationState {
        case .activated: return "Active"
        case .inactive: return "Inactive"
        case .notActivated: return "Not Activated"
        @unknown default: return "Unknown"
        }
    }
}
