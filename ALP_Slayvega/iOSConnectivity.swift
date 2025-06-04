// ALP_Slayvega/iOSConnectivity.swift
import WatchConnectivity
import Foundation
import FirebaseDatabase

class iOSConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    private var syncTimer: Timer?
    private let syncInterval: TimeInterval = 180.0 // Sync every 3 minutes if reachable
    private let maxPostsToSend = 15

    @Published var isWatchReachable: Bool = false // Renamed for clarity
    @Published var connectionStatusMessage: String = "Initializing..." // More descriptive status
    @Published var lastSyncTime: Date?
    @Published var syncInProgress: Bool = false
    @Published var lastErrorMessage: String?

    static let shared = iOSConnectivity() // Make it a singleton for easy access

    private override init() { // Private init for singleton
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
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.lastErrorMessage = nil
            switch activationState {
            case .activated:
                self.isWatchReachable = session.isReachable
                self.connectionStatusMessage = session.isReachable ? "Watch App Connected" : "Watch App Unreachable"
                print("iOSConnectivity: WCSession activated. Reachable: \(session.isReachable)")
                if session.isReachable {
                    self.sendCommunityDataToWatch(reason: "Activation & Reachable")
                    self.startAutoSync()
                }
            case .inactive:
                self.isWatchReachable = false
                self.connectionStatusMessage = "Watch Session Inactive"
                print("iOSConnectivity: WCSession inactive.")
                self.stopAutoSync()
            case .notActivated:
                self.isWatchReachable = false
                self.connectionStatusMessage = "Watch Session Not Activated"
                print("iOSConnectivity: WCSession not activated.")
                self.stopAutoSync()
            @unknown default:
                self.isWatchReachable = false
                self.connectionStatusMessage = "Unknown Watch Session State"
                print("iOSConnectivity: WCSession unknown state.")
                self.stopAutoSync()
            }
        }

        if let error = error {
            print("iOSConnectivity: WCSession activation error - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Activation Error"
                self.lastErrorMessage = error.localizedDescription
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = false
            self.connectionStatusMessage = "Watch Session Became Inactive"
        }
        print("iOSConnectivity: sessionDidBecomeInactive")
        stopAutoSync()
    }

    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = false
            self.connectionStatusMessage = "Watch Session Deactivated. Re-activating..."
        }
        print("iOSConnectivity: sessionDidDeactivate. Attempting to reactivate.")
        session.activate() //Re-activate the session
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
            self.connectionStatusMessage = session.isReachable ? "Watch App Connected" : "Watch App Unreachable"
            print("iOSConnectivity: Reachability changed. Reachable: \(session.isReachable)")
            if session.isReachable {
                self.lastErrorMessage = nil
                self.sendCommunityDataToWatch(reason: "Reachability Changed & Reachable")
                self.startAutoSync()
            } else {
                self.stopAutoSync()
            }
        }
    }
    
    // MARK: - Message Handling from Watch (iOS receives from Watch)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("iOSConnectivity: Received message from Watch: \(message)")
        DispatchQueue.main.async { self.lastErrorMessage = nil }

        if let action = message["action"] as? String {
            switch action {
            case "requestCommunities":
                print("iOSConnectivity: Watch requested community data.")
                // Acknowledge the request immediately
                let ackReply = ["status": "processingRequest", "receivedAt": Date().timeIntervalSince1970] as [String : Any]
                print("iOSConnectivity: Sending ACK to Watch for requestCommunities: \(ackReply)")
                replyHandler(ackReply)
                
                // Then send the actual data
                sendCommunityDataToWatch(reason: "Watch Requested")
                
            case "pingTest":
                let pingReply = ["status": "pong", "phoneTimestamp": Date().timeIntervalSince1970] as [String : Any]
                print("iOSConnectivity: Watch sent pingTest. Replying: \(pingReply)")
                replyHandler(pingReply)
                
            default:
                let unknownReply = ["status": "unknownAction", "actionReceived": action] as [String : Any]
                print("iOSConnectivity: Watch sent unknown action '\(action)'. Replying: \(unknownReply)")
                replyHandler(unknownReply)
            }
        } else {
            let invalidReply = ["status": "invalidMessageFormat"] as [String : Any]
            print("iOSConnectivity: Watch sent invalid message format. Replying: \(invalidReply)")
            replyHandler(invalidReply)
        }
    }

    // MARK: - Data Transfer Logic (iOS to Watch)
    func sendCommunityDataToWatch(reason: String, completion: ((Bool, String?) -> Void)? = nil) {
            print("iOSConnectivity: Attempting to send data to Watch. Reason: \(reason)")
            guard session.activationState == .activated else {
                print("iOSConnectivity: Session not activated. Cannot send.")
                DispatchQueue.main.async { self.lastErrorMessage = "iOS Session not active." }
                completion?(false, "iOS Session not activated")
                return
            }

            guard self.isWatchReachable else { // Use the @Published property
                print("iOSConnectivity: Watch not reachable. Cannot send.")
                DispatchQueue.main.async { self.lastErrorMessage = "Watch not reachable for send." }
                completion?(false, "Watch not reachable")
                return
            }
            
            DispatchQueue.main.async {
                guard !self.syncInProgress else {
                    print("iOSConnectivity: Sync already in progress.")
                    completion?(false, "Sync already in progress")
                    return
                }
                self.syncInProgress = true
                self.connectionStatusMessage = "Syncing with Watch..."
                self.lastErrorMessage = nil
            }
            
            print("iOSConnectivity: Fetching community data from Firebase...")
            let dbRef = Database.database().reference().child("communities")
            dbRef.queryOrdered(byChild: "communityDates").queryLimited(toLast: UInt(maxPostsToSend * 2))
                .observeSingleEvent(of: .value, with: { [weak self] snapshot in // CORRECTED CLOSURE
                guard let self = self else {
                    completion?(false, "Self deallocated")
                    return
                }
                
                // Check if snapshot has data
                guard snapshot.exists() else {
                    print("iOSConnectivity: Firebase snapshot does not exist or has no data.")
                    DispatchQueue.main.async {
                        self.syncInProgress = false
                        self.connectionStatusMessage = "No data from DB"
                        self.lastErrorMessage = "Firebase data is empty or not found."
                        // Send an empty array to the watch to clear its list if appropriate
                        let emptyMessage = [
                            "dataType": "communityUpdate",
                            "communities": [],
                            "timestamp": Date().timeIntervalSince1970,
                            "count": 0
                        ] as [String : Any]
                        self.session.sendMessage(emptyMessage, replyHandler: nil, errorHandler: nil)
                    }
                    completion?(false, "Firebase data is empty.")
                    return
                }

                var communitiesPayload: [[String: Any]] = []
                var rawCommunities: [CommunityModel] = []

                for case let child as DataSnapshot in snapshot.children {
                    if let data = child.value as? [String: Any] {
                        var communityDate = Date()
                        if let timestamp = data["communityDates"] as? TimeInterval {
                            communityDate = Date(timeIntervalSince1970: timestamp / 1000)
                        } else if let dateString = data["communityDates"] as? String {
                            let formatter = ISO8601DateFormatter()
                            communityDate = formatter.date(from: dateString) ?? Date()
                        }
                        rawCommunities.append(
                            CommunityModel(
                                id: data["id"] as? String ?? child.key,
                                username: data["username"] as? String ?? "Anonymous",
                                communityContent: data["communityContent"] as? String ?? "",
                                hashtags: data["hashtags"] as? String ?? "",
                                communityLikeCount: data["communityLikeCount"] as? Int ?? 0,
                                communityDates: communityDate,
                                userId: data["userId"] as? String ?? ""
                            )
                        )
                    }
                }
                
                let sortedCommunities = rawCommunities.sorted { $0.communityDates > $1.communityDates }.prefix(self.maxPostsToSend)
                print("iOSConnectivity: Fetched \(rawCommunities.count) raw posts, sending \(sortedCommunities.count) after sorting/limiting.")

                for community in sortedCommunities {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    let formattedDateString = formatter.string(from: community.communityDates)

                    let watchData: [String: Any] = [
                        "id": community.id,
                        "username": community.username,
                        "communityContent": community.communityContent,
                        "hashtags": community.hashtags,
                        "communityLikeCount": community.communityLikeCount,
                        "formattedDate": formattedDateString,
                        "userId": community.userId
                    ]
                    communitiesPayload.append(watchData)
                }
                
                let message = [
                    "dataType": "communityUpdate",
                    "communities": communitiesPayload,
                    "timestamp": Date().timeIntervalSince1970,
                    "count": communitiesPayload.count
                ] as [String : Any]

                print("iOSConnectivity: Sending actual data message to Watch with \(communitiesPayload.count) posts.")
                self.session.sendMessage(message, replyHandler: { reply in
                    DispatchQueue.main.async {
                        self.syncInProgress = false
                        self.lastSyncTime = Date()
                        self.connectionStatusMessage = "Watch Ack: \(communitiesPayload.count) posts."
                        self.lastErrorMessage = nil
                        print("iOSConnectivity: Watch acknowledged data message. Reply: \(reply)")
                    }
                    completion?(true, nil)
                }, errorHandler: { error in
                    DispatchQueue.main.async {
                        self.syncInProgress = false
                        self.connectionStatusMessage = "Data Send Error"
                        self.lastErrorMessage = error.localizedDescription
                        print("iOSConnectivity: Error sending data message to Watch: \(error.localizedDescription)")
                    }
                    completion?(false, error.localizedDescription)
                })
            }) { [weak self] error in // CORRECTED: Added withCancel block for error handling
                guard let self = self else { return }
                print("iOSConnectivity: Firebase data fetch CANCELLED or ERRORED: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.syncInProgress = false
                    self.connectionStatusMessage = "DB Fetch Error"
                    self.lastErrorMessage = "Firebase error: \(error.localizedDescription)"
                }
                completion?(false, "Database error: \(error.localizedDescription)")
            }
        }


    // MARK: - Sync Management
    func startAutoSync() {
        stopAutoSync()
        guard self.isWatchReachable else { return }
        print("iOSConnectivity: Starting auto-sync timer.")
        syncTimer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.isWatchReachable && !self.syncInProgress else { return }
            print("iOSConnectivity: Auto-sync triggered.")
            self.sendCommunityDataToWatch(reason: "Auto Sync Timer")
        }
    }

    func stopAutoSync() {
        print("iOSConnectivity: Stopping auto-sync timer.")
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    func manualSyncWithWatch() {
        print("iOSConnectivity: Manual sync triggered.")
        sendCommunityDataToWatch(reason: "Manual Sync Button") { success, errorStr in
            if !success {
                DispatchQueue.main.async {
                  self.connectionStatusMessage = "Manual Sync Failed"
                  if let err = errorStr { self.lastErrorMessage = err }
                }
            }
        }
    }
    
    deinit {
        stopAutoSync()
        print("iOSConnectivity deinitialized.")
    }
}
