import WatchConnectivity
import Foundation
import FirebaseDatabase

class iOSConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 30.0
    private let maxPostsToSend = 15
    
    @Published var isWatchConnected: Bool = false
    @Published var connectionStatus: String = "Connecting..."
    @Published var lastSyncTime: Date?
    @Published var syncInProgress: Bool = false
    
    override init() {
        session = WCSession.default
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            DispatchQueue.main.async {
                self.connectionStatus = "Watch not supported"
            }
            return
        }
        
        session.delegate = self
        session.activate()
        
        DispatchQueue.main.async {
            self.connectionStatus = "Activating..."
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            switch activationState {
            case .activated:
                self.isWatchConnected = session.isReachable
                self.connectionStatus = session.isReachable ? "Connected" : "Watch Unreachable"
                if session.isReachable {
                    self.startAutoSync()
                }
            case .inactive:
                self.isWatchConnected = false
                self.connectionStatus = "Inactive"
            case .notActivated:
                self.isWatchConnected = false
                self.connectionStatus = "Not Activated"
            @unknown default:
                self.isWatchConnected = false
                self.connectionStatus = "Unknown State"
            }
        }
        
        if let error = error {
            print("iOS WC Session activation error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.connectionStatus = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
            self.connectionStatus = "Inactive"
        }
        syncTimer?.invalidate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
            self.connectionStatus = "Deactivated"
        }
        session.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = session.isReachable
            self.connectionStatus = session.isReachable ? "Connected" : "Watch Unreachable"
            
            if session.isReachable {
                self.sendCommunityDataToWatch()
            }
        }
    }
    
    // MARK: - Data Transfer
    func sendCommunityDataToWatch(completion: @escaping (Bool, String?) -> Void = { _, _ in }) {
        guard session.activationState == .activated else {
            completion(false, "Session not activated")
            return
        }
        
        guard session.isReachable else {
            completion(false, "Watch not reachable")
            return
        }
        
        DispatchQueue.main.async {
            self.syncInProgress = true
        }
        
        let dbRef = Database.database().reference().child("communities")
        dbRef.queryOrdered(byChild: "communityDates").queryLimited(toLast: UInt(maxPostsToSend)).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else {
                completion(false, "Self deallocated")
                return
            }
            
            var communities: [[String: Any]] = []
            
            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any] {
                    var communityData = data
                    
                    // Handle date formatting
                    var formattedDate = ""
                    if let timestamp = data["communityDates"] as? TimeInterval {
                        let date = Date(timeIntervalSince1970: timestamp / 1000)
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .short
                        formattedDate = formatter.string(from: date)
                    } else if let dateString = data["communityDates"] as? String {
                        let formatter = ISO8601DateFormatter()
                        if let date = formatter.date(from: dateString) {
                            let displayFormatter = DateFormatter()
                            displayFormatter.dateStyle = .medium
                            displayFormatter.timeStyle = .short
                            formattedDate = displayFormatter.string(from: date)
                        }
                    }
                    
                    let watchData: [String: Any] = [
                        "id": communityData["id"] as? String ?? child.key,
                        "username": communityData["username"] as? String ?? "Anonymous",
                        "communityContent": communityData["communityContent"] as? String ?? "",
                        "hashtags": communityData["hashtags"] as? String ?? "",
                        "communityLikeCount": communityData["communityLikeCount"] as? Int ?? 0,
                        "formattedDate": formattedDate,
                        "userId": communityData["userId"] as? String ?? ""
                    ]
                    
                    communities.append(watchData)
                }
            }
            
            // Sort by date (most recent first)
            communities.sort {
                let date1 = ($0["communityDates"] as? TimeInterval) ?? 0
                let date2 = ($1["communityDates"] as? TimeInterval) ?? 0
                return date1 > date2
            }
            
            let limitedCommunities = Array(communities.prefix(self.maxPostsToSend))
            let message = [
                "communities": limitedCommunities,
                "timestamp": Date().timeIntervalSince1970,
                "count": limitedCommunities.count
            ] as [String : Any]
            
            self.session.sendMessage(message, replyHandler: { reply in
                DispatchQueue.main.async {
                    self.syncInProgress = false
                    self.lastSyncTime = Date()
                }
                print("✅ Sent \(limitedCommunities.count) communities to watch")
                completion(true, nil)
            }, errorHandler: { error in
                DispatchQueue.main.async {
                    self.syncInProgress = false
                }
                print("❌ Error sending communities: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            })
        } withCancel: { error in
            DispatchQueue.main.async {
                self.syncInProgress = false
            }
            completion(false, "Database error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let action = message["action"] as? String {
            switch action {
            case "requestCommunities":
                // Immediately acknowledge the request
                replyHandler(["status": "processing", "timestamp": Date().timeIntervalSince1970])
                
                // Send the data
                sendCommunityDataToWatch { success, error in
                    if !success {
                        let errorMessage = ["error": error ?? "Unknown error", "timestamp": Date().timeIntervalSince1970]
                        self.session.sendMessage(errorMessage, replyHandler: nil, errorHandler: nil)
                    }
                }
                
            case "pingTest":
                replyHandler(["status": "pong", "timestamp": Date().timeIntervalSince1970])
                
            default:
                replyHandler(["status": "unknown_action", "timestamp": Date().timeIntervalSince1970])
            }
        } else {
            replyHandler(["status": "invalid_message", "timestamp": Date().timeIntervalSince1970])
        }
    }
    
    // MARK: - Sync Management
    func startAutoSync() {
        syncTimer?.invalidate()
        sendCommunityDataToWatch()
        
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.session.isReachable && !self.syncInProgress else { return }
            self.sendCommunityDataToWatch()
        }
    }
    
    func stopAutoSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    func manualSync() {
        guard !syncInProgress else { return }
        sendCommunityDataToWatch()
    }
    
    func testConnection() {
        guard session.isReachable else {
            DispatchQueue.main.async {
                self.connectionStatus = "Watch not reachable"
            }
            return
        }
        
        let testMessage = ["action": "pingTest", "timestamp": Date().timeIntervalSince1970] as [String : Any]
        session.sendMessage(testMessage, replyHandler: { reply in
            DispatchQueue.main.async {
                self.connectionStatus = "Connection test passed"
            }
        }, errorHandler: { error in
            DispatchQueue.main.async {
                self.connectionStatus = "Connection test failed: \(error.localizedDescription)"
            }
        })
    }
    
    // MARK: - Utility Methods
    func getConnectionInfo() -> [String: String] {
        return [
            "Activation State": getActivationStateString(),
            "Is Reachable": session.isReachable ? "Yes" : "No",
            "Is Paired": session.isPaired ? "Yes" : "No",
            "Is Watch App Installed": session.isWatchAppInstalled ? "Yes" : "No",
            "Last Sync": lastSyncTime?.formatted() ?? "Never",
            "Sync In Progress": syncInProgress ? "Yes" : "No"
        ]
    }
    
    private func getActivationStateString() -> String {
        switch session.activationState {
        case .activated: return "Activated"
        case .inactive: return "Inactive"
        case .notActivated: return "Not Activated"
        @unknown default: return "Unknown"
        }
    }
    
    deinit {
        stopAutoSync()
    }
}
