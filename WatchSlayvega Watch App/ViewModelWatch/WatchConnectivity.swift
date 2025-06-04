// WatchSlayvega Watch App/ViewModelWatch/WatchConnectivity.swift
import WatchConnectivity
import Foundation

struct WatchCommunityModel: Identifiable, Hashable, Codable {
    let id: String
    let username: String
    let communityContent: String
    let hashtags: String
    let communityLikeCount: Int
    let formattedDate: String
    let userId: String
}

class WatchConnectivity: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    private var retryTimer: Timer?
    private let maxRetryAttempts = 3
    private var currentRetryCount = 0

    @Published var communities: [WatchCommunityModel] = []
    @Published var isConnectedToPhone: Bool = false
    @Published var isLoading: Bool = false
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?
    @Published var connectionStatusMessage: String = "Initializing..."

    override init() {
        session = WCSession.default
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
            print("WatchConnectivity: Session activation initiated.")
        } else {
            print("WatchConnectivity: WCSession not supported.")
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Connectivity N/A"
                self.errorMessage = "Watch Connectivity not supported."
            }
        }
    }

    // MARK: - WCSessionDelegate (WatchOS)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.errorMessage = nil
            switch activationState {
            case .activated:
                self.isConnectedToPhone = session.isReachable
                self.connectionStatusMessage = session.isReachable ? "Connected" : "iPhone Unreachable"
                print("WatchConnectivity: WCSession activated. Reachable: \(session.isReachable)")
                if session.isReachable {
                    self.requestCommunitiesData(reason: "Activation & Reachable")
                }
            case .inactive:
                self.isConnectedToPhone = false
                self.connectionStatusMessage = "Inactive"
                print("WatchConnectivity: WCSession inactive.")
            case .notActivated:
                self.isConnectedToPhone = false
                self.connectionStatusMessage = "Not Activated"
                print("WatchConnectivity: WCSession not activated.")
            @unknown default:
                self.isConnectedToPhone = false
                self.connectionStatusMessage = "Unknown State"
                print("WatchConnectivity: WCSession unknown state.")
            }
        }
        if let error = error {
            print("WatchConnectivity: WCSession activation error - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Activation Error: \(error.localizedDescription)"
                self.connectionStatusMessage = "Activation Failed"
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isConnectedToPhone = session.isReachable
            self.connectionStatusMessage = session.isReachable ? "Connected" : "iPhone Unreachable"
            print("WatchConnectivity: Reachability changed. Reachable: \(session.isReachable)")
            if session.isReachable {
                self.errorMessage = nil
                self.requestCommunitiesData(reason: "Reachability Changed & Reachable")
            } else {
                 self.errorMessage = self.communities.isEmpty ? "iPhone unreachable." : nil
            }
        }
    }

    // MARK: - Message Handling from iOS (WatchOS receives from iOS)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WatchConnectivity: Received message from iOS: \(message)")
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = nil
            self.currentRetryCount = 0
            
            guard let dataType = message["dataType"] as? String else {
                print("WatchConnectivity: Message missing 'dataType'.")
                self.errorMessage = "Unknown message from iPhone."
                if let errorFromIOS = message["error"] as? String { // Check if iOS explicitly sent an error
                     self.errorMessage = "iOS Error: \(errorFromIOS)"
                     self.connectionStatusMessage = "Sync Error (from iPhone)"
                }
                return
            }
            
            print("WatchConnectivity: Received dataType: \(dataType)")
            if dataType == "communityUpdate" {
                if let communitiesData = message["communities"] as? [[String: Any]] {
                    print("WatchConnectivity: Parsing \(communitiesData.count) community entries.")
                    self.parseAndStoreCommunities(from: communitiesData)
                    self.lastSyncDate = Date(timeIntervalSince1970: message["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970)
                    let count = message["count"] as? Int ?? communitiesData.count
                    self.connectionStatusMessage = "Synced \(count) posts"
                    if communitiesData.isEmpty && self.communities.isEmpty {
                        self.connectionStatusMessage = "No posts available."
                    }
                } else {
                    self.errorMessage = "Invalid community data format from iPhone."
                    self.connectionStatusMessage = "Data Format Error"
                    print("WatchConnectivity: 'communities' field missing or not an array of dictionaries.")
                }
            } else if dataType == "errorUpdate" { // Example: if iOS sends a specific error message
                 self.errorMessage = message["errorMessage"] as? String ?? "Unknown error from iPhone"
                 self.connectionStatusMessage = "Sync Error"
                 print("WatchConnectivity: Received errorUpdate: \(self.errorMessage ?? "")")
            } else {
                print("WatchConnectivity: Received unhandled dataType: \(dataType)")
            }
        }
    }
    
    // Reply to data message sent from iOS
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("WatchConnectivity: Received message from iOS with replyHandler: \(message)")
        // Process the message as in the non-replyHandler version
        self.session(session, didReceiveMessage: message)
        // Send a simple acknowledgement back to iOS
        replyHandler(["watchStatus": "messageReceived", "receivedAt": Date().timeIntervalSince1970])
    }


    private func parseAndStoreCommunities(from data: [[String: Any]]) {
        var parsedCommunities: [WatchCommunityModel] = []
        let decoder = JSONDecoder()

        for communityDict in data {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: communityDict, options: [])
                let community = try decoder.decode(WatchCommunityModel.self, from: jsonData)
                parsedCommunities.append(community)
            } catch {
                print("WatchConnectivity: Error decoding community: \(error.localizedDescription) for item: \(communityDict)")
            }
        }
        
        // Sorting logic (example: by like count, then username)
        // parsedCommunities.sort { ($0.communityLikeCount, $1.username) > ($1.communityLikeCount, $0.username) }
        // Or, if iOS already sorts by date, you might not need to sort here or sort differently
        
        self.communities = parsedCommunities
        if communities.isEmpty && !data.isEmpty {
            self.errorMessage = "Failed to process any posts."
            self.connectionStatusMessage = "Processing Error"
        } else if communities.isEmpty && data.isEmpty {
             self.connectionStatusMessage = "No posts to show"
        }
        print("WatchConnectivity: Stored \(self.communities.count) parsed communities.")
    }

    // MARK: - Data Request Logic (Watch to iOS)
    func requestCommunitiesData(reason: String, isRetry: Bool = false) {
        print("WatchConnectivity: Attempting to request data. Reason: \(reason), isRetry: \(isRetry)")
        if !isRetry {
            currentRetryCount = 0
        }

        guard session.activationState == .activated else {
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Session Not Active"
                self.errorMessage = "Watch session not ready."
            }
            return
        }

        guard session.isReachable else {
            DispatchQueue.main.async {
                self.isConnectedToPhone = false
                self.connectionStatusMessage = "iPhone Unreachable"
                if self.currentRetryCount < self.maxRetryAttempts {
                    self.currentRetryCount += 1
                    self.connectionStatusMessage = "Retrying (\(self.currentRetryCount)/\(self.maxRetryAttempts))..."
                    self.retryTimer?.invalidate()
                    self.retryTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in // Increased retry interval
                        print("WatchConnectivity: Retrying requestCommunitiesData...")
                        self?.requestCommunitiesData(reason: "Retry", isRetry: true)
                    }
                } else {
                    self.isLoading = false
                    self.errorMessage = "iPhone unreachable after \(self.maxRetryAttempts) attempts."
                    self.connectionStatusMessage = "Connection Failed"
                }
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
            self.connectionStatusMessage = "Requesting Posts..."
        }

        let messagePayload = ["action": "requestCommunities", "watchTimestamp": Date().timeIntervalSince1970] as [String : Any]

        print("WatchConnectivity: Sending 'requestCommunities' to iOS: \(messagePayload)")
        session.sendMessage(messagePayload, replyHandler: { reply in
            print("WatchConnectivity: iOS ACKNOWLEDGED requestCommunities. Reply: \(reply)")
            DispatchQueue.main.async {
                if let status = reply["status"] as? String, status == "processingRequest" {
                    self.connectionStatusMessage = "iPhone Processing..."
                } else {
                    self.connectionStatusMessage = "iPhone Replied"
                    // This reply is just an ACK, actual data comes via didReceiveMessage
                }
            }
        }, errorHandler: { error in
            print("WatchConnectivity: ERROR sending 'requestCommunities' to iOS: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Request Send Error: \(error.localizedDescription)"
                self.connectionStatusMessage = "Request Failed"
            }
        })
    }
    
    func manualRefresh() {
        print("WatchConnectivity: Manual refresh initiated.")
        retryTimer?.invalidate()
        requestCommunitiesData(reason: "Manual Refresh")
    }

    func testPingToPhone() {
        guard session.isReachable else {
            DispatchQueue.main.async { self.connectionStatusMessage = "iPhone Unreachable for Ping" }
            return
        }
        let message = ["action": "pingTest", "watchTimestamp": Date().timeIntervalSince1970] as [String: Any]
        DispatchQueue.main.async { self.connectionStatusMessage = "Pinging iPhone..." }
        print("WatchConnectivity: Sending pingTest to iOS: \(message)")
        session.sendMessage(message, replyHandler: { reply in
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Ping Ack by iPhone"
                print("WatchConnectivity: Ping reply from iOS: \(reply)")
            }
        }, errorHandler: { error in
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Ping Failed"
                self.errorMessage = "Ping Error: \(error.localizedDescription)"
                print("WatchConnectivity: Ping error: \(error.localizedDescription)")
            }
        })
    }
    
    func getConnectionInfo() -> [String: String] { /* ... same as before ... */
        return [
            "Watch Status": connectionStatusMessage,
            "iPhone Reachable": isConnectedToPhone ? "Yes" : "No",
            "Loaded Posts": "\(communities.count)",
            "Last Sync": lastSyncDate?.formatted(date: .abbreviated, time: .shortened) ?? "Never",
            "Session State": getSessionStateString(),
            "Last Error": errorMessage ?? "None"
        ]
    }
    private func getSessionStateString() -> String { /* ... same as before ... */
        switch session.activationState {
        case .activated: return "Active"
        case .inactive: return "Inactive"
        case .notActivated: return "Not Activated"
        @unknown default: return "Unknown"
        }
    }

    deinit {
        retryTimer?.invalidate()
        print("WatchConnectivity deinitialized.")
    }
}
