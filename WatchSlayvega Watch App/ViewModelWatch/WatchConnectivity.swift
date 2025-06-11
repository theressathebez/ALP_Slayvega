// WatchSlayvega Watch App/ViewModelWatch/WatchConnectivity.swift
import WatchConnectivity
import Foundation

// Pastikan WatchCommunityModel juga Codable dan Identifiable
struct WatchCommunityModel: Identifiable, Hashable, Codable { //
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

    // Properti untuk Community Posts
    @Published var communities: [WatchCommunityModel] = [] //
    @Published var isLoading: Bool = false //
    @Published var errorMessage: String? //
    @Published var lastSyncDate: Date? //

    // Properti BARU untuk Comments
    @Published var currentPostComments: [WatchCommentModel] = []
    @Published var isLoadingComments: Bool = false
    @Published var commentsErrorMessage: String?

    // Properti untuk Status Koneksi Umum
    @Published var isConnectedToPhone: Bool = false //
    @Published var connectionStatusMessage: String = "Initializing..." //


    override init() { //
        session = WCSession.default //
        super.init()
        if WCSession.isSupported() {
            session.delegate = self //
            session.activate() //
            print("WatchConnectivity: Session activation initiated.")
        } else {
            print("WatchConnectivity: WCSession not supported.")
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Connectivity N/A" //
                self.errorMessage = "Watch Connectivity not supported." //
            }
        }
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { //
        DispatchQueue.main.async {
            self.errorMessage = nil //
            switch activationState {
            case .activated:
                self.isConnectedToPhone = session.isReachable //
                self.connectionStatusMessage = session.isReachable ? "Connected" : "iPhone Unreachable" //
                print("WatchConnectivity: WCSession activated. Reachable: \(session.isReachable)")
                // Initial data request can be triggered from View's onAppear
            case .inactive:
                self.isConnectedToPhone = false //
                self.connectionStatusMessage = "Inactive" //
                print("WatchConnectivity: WCSession inactive.")
            case .notActivated:
                self.isConnectedToPhone = false //
                self.connectionStatusMessage = "Not Activated" //
                print("WatchConnectivity: WCSession not activated.")
            @unknown default:
                self.isConnectedToPhone = false //
                self.connectionStatusMessage = "Unknown State" //
                print("WatchConnectivity: WCSession unknown state.")
            }
        }
        if let error = error {
            print("WatchConnectivity: WCSession activation error - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Activation Error: \(error.localizedDescription)" //
                self.connectionStatusMessage = "Activation Failed" //
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) { //
        DispatchQueue.main.async {
            self.isConnectedToPhone = session.isReachable //
            self.connectionStatusMessage = session.isReachable ? "Connected" : "iPhone Unreachable" //
            print("WatchConnectivity: Reachability changed. Reachable: \(session.isReachable)")
            if session.isReachable {
                self.errorMessage = nil //
                // Consider if an automatic refresh is needed here
            } else {
                 self.errorMessage = (self.communities.isEmpty && self.currentPostComments.isEmpty) ? "iPhone unreachable." : nil
            }
        }
    }

    // MARK: - Message Handling from iOS
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) { //
        print("WatchConnectivity: Received message from iOS: \(message)")
        DispatchQueue.main.async {
            self.errorMessage = nil; self.commentsErrorMessage = nil //
            self.currentRetryCount = 0 //
            
            guard let dataType = message["dataType"] as? String else {
                print("WatchConnectivity: Message missing 'dataType'.")
                self.errorMessage = "Unknown message from iPhone."
                if let errorFromIOS = message["error"] as? String {
                     self.errorMessage = "iOS Error: \(errorFromIOS)" //
                     self.connectionStatusMessage = "Sync Error (from iPhone)" //
                }
                self.isLoading = false; self.isLoadingComments = false //
                return
            }
            
            print("WatchConnectivity: Received dataType: \(dataType)")
            switch dataType {
            case "communityUpdate":
                self.isLoading = false //
                if let communitiesData = message["communities"] as? [[String: Any]] { //
                    print("WatchConnectivity: Parsing \(communitiesData.count) community entries.")
                    self.parseAndStoreCommunities(from: communitiesData) //
                    self.lastSyncDate = Date(timeIntervalSince1970: message["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970) //
                    let count = message["count"] as? Int ?? communitiesData.count //
                    self.connectionStatusMessage = "Synced \(count) posts" //
                } else {
                    self.errorMessage = "Invalid community data from iPhone." //
                    self.connectionStatusMessage = "Data Error (Communities)" //
                }
            case "commentUpdate":
                self.isLoadingComments = false
                if let commentsData = message["comments"] as? [[String: Any]] {
                    print("WatchConnectivity: Parsing \(commentsData.count) comment entries.")
                    self.parseAndStoreComments(from: commentsData)
                } else {
                    self.commentsErrorMessage = "Invalid comment data from iPhone."
                }
            case "errorUpdate":
                 self.isLoading = false; self.isLoadingComments = false //
                 self.errorMessage = message["errorMessage"] as? String ?? "Unknown error from iPhone" //
                 self.connectionStatusMessage = "Sync Error" //
            default:
                self.isLoading = false; self.isLoadingComments = false //
                print("WatchConnectivity: Received unhandled dataType: \(dataType)")
            }
        }
    }
    
    // This handles messages that iOS sends WITH a reply handler (e.g. data payloads)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) { //
        print("WatchConnectivity: Received message (with reply) from iOS: \(message)")
        self.session(session, didReceiveMessage: message) // Process it like a normal message
        replyHandler(["watchStatus": "messageReceivedByWatch", "receivedAt": Date().timeIntervalSince1970])
    }

    private func parseAndStoreCommunities(from data: [[String: Any]]) { //
        var parsedCommunities: [WatchCommunityModel] = [] //
        let decoder = JSONDecoder()
        for communityDict in data {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: communityDict, options: [])
                let community = try decoder.decode(WatchCommunityModel.self, from: jsonData)
                parsedCommunities.append(community) //
            } catch {
                print("WatchConnectivity: Error decoding community: \(error.localizedDescription) for item: \(communityDict)")
            }
        }
        // Assuming iOS sends sorted data or sort based on a reliable field if necessary
        self.communities = parsedCommunities //
        if communities.isEmpty && !data.isEmpty {
            self.errorMessage = "Failed to process posts." //
        } else if communities.isEmpty && data.isEmpty {
             self.connectionStatusMessage = "No posts to show" //
        }
        print("WatchConnectivity: Stored \(self.communities.count) parsed communities.")
    }

    private func parseAndStoreComments(from data: [[String: Any]]) {
        var parsedComments: [WatchCommentModel] = []
        let decoder = JSONDecoder()
        for commentDict in data {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: commentDict, options: [])
                let comment = try decoder.decode(WatchCommentModel.self, from: jsonData)
                parsedComments.append(comment)
            } catch {
                print("WatchConnectivity: Error decoding comment: \(error.localizedDescription) for item: \(commentDict)")
            }
        }
        // Example sort: Assuming formattedDate can be compared lexicographically for recentness, or use a timestamp
        self.currentPostComments = parsedComments.sorted(by: { $0.formattedDate > $1.formattedDate })
        if self.currentPostComments.isEmpty && data.isEmpty {
            self.commentsErrorMessage = "No comments for this post."
        } else if self.currentPostComments.isEmpty && !data.isEmpty {
            self.commentsErrorMessage = "Failed to process comments."
        }
        print("WatchConnectivity: Stored \(self.currentPostComments.count) parsed comments.")
    }

    // MARK: - Data Request Logic (Watch to iOS)
    func requestCommunitiesData(reason: String, isRetry: Bool = false) { //
        print("WatchConnectivity: Requesting communities. Reason: \(reason), Retry: \(isRetry)")
        if !isRetry { currentRetryCount = 0 } //

        guard session.activationState == .activated else { //
            DispatchQueue.main.async { self.connectionStatusMessage = "Session Not Active"; self.errorMessage = "Watch session not ready." }; return //
        }
        guard session.isReachable else { //
            DispatchQueue.main.async {
                self.isConnectedToPhone = false; self.connectionStatusMessage = "iPhone Unreachable" //
                if self.currentRetryCount < self.maxRetryAttempts { //
                    self.currentRetryCount += 1; self.connectionStatusMessage = "Retrying Comm (\(self.currentRetryCount)/\(self.maxRetryAttempts))..." //
                    self.retryTimer?.invalidate(); self.retryTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in //
                        print("WatchConnectivity: Retrying requestCommunitiesData..."); self?.requestCommunitiesData(reason: "Retry Comm", isRetry: true) //
                    }
                } else { //
                    self.isLoading = false; self.errorMessage = "iPhone unreachable for communities."; self.connectionStatusMessage = "Comm Connection Failed" //
                }
            }; return
        }
        DispatchQueue.main.async { self.isLoading = true; self.errorMessage = nil; self.connectionStatusMessage = "Requesting Posts..." } //
        let messagePayload = ["action": "requestCommunities", "watchTimestamp": Date().timeIntervalSince1970] as [String : Any] //
        print("WatchConnectivity: Sending 'requestCommunities' to iOS: \(messagePayload)")
        session.sendMessage(messagePayload, replyHandler: { reply in //
            print("WatchConnectivity: iOS ACK for requestCommunities. Reply: \(reply)")
            DispatchQueue.main.async {
                if let status = reply["status"] as? String, status == "processingRequest" { self.connectionStatusMessage = "iPhone Processing..." }  //
                else { self.connectionStatusMessage = "iPhone Replied to Comm" } //
            }
        }, errorHandler: { error in //
            print("WatchConnectivity: ERROR sending 'requestCommunities': \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false; self.errorMessage = "Req Comm Error: \(error.localizedDescription)"; self.connectionStatusMessage = "Req Comm Failed" //
            }
        })
    }

    func requestCommentsForPost(communityId: String) {
        print("WatchConnectivity: Requesting comments for post ID: \(communityId)")
        guard session.activationState == .activated else {
            DispatchQueue.main.async { self.commentsErrorMessage = "Session Not Active for comments." }
            return
        }
        guard session.isReachable else {
            DispatchQueue.main.async { self.commentsErrorMessage = "iPhone Unreachable for comments." }
            // Implement retry for comments if desired, similar to requestCommunitiesData
            return
        }

        DispatchQueue.main.async {
            self.isLoadingComments = true
            self.commentsErrorMessage = nil
            self.currentPostComments = [] // Clear previous comments
        }

        let messagePayload = [
            "action": "requestComments",
            "communityId": communityId,
            "watchTimestamp": Date().timeIntervalSince1970
        ] as [String : Any]

        print("WatchConnectivity: Sending 'requestComments' to iOS: \(messagePayload)")
        session.sendMessage(messagePayload, replyHandler: { reply in
            print("WatchConnectivity: iOS ACK for requestComments. Reply: \(reply)")
            DispatchQueue.main.async {
                if let status = reply["status"] as? String, status == "processingCommentRequest" {
                    // self.connectionStatusMessage = "iPhone Processing Comments..." // Or a specific comment status
                } else {
                    // self.connectionStatusMessage = "iPhone Replied to Comments Req"
                }
            }
        }, errorHandler: { error in
            print("WatchConnectivity: ERROR sending 'requestComments': \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoadingComments = false
                self.commentsErrorMessage = "Comment Req Error: \(error.localizedDescription)"
            }
        })
    }
    
    func clearCurrentPostComments() {
        DispatchQueue.main.async {
            self.currentPostComments = []
            self.commentsErrorMessage = nil
            self.isLoadingComments = false
            print("WatchConnectivity: Cleared current post comments.")
        }
    }

    func manualRefresh() { //
        print("WatchConnectivity: Manual refresh initiated.")
        retryTimer?.invalidate() //
        requestCommunitiesData(reason: "Manual Refresh")
    }

    func testPingToPhone() { //
        guard session.isReachable else { //
            DispatchQueue.main.async { self.connectionStatusMessage = "iPhone Unreachable for Ping" } //
            return
        }
        let message = ["action": "pingTest", "watchTimestamp": Date().timeIntervalSince1970] as [String: Any] //
        DispatchQueue.main.async { self.connectionStatusMessage = "Pinging iPhone..." } //
        print("WatchConnectivity: Sending pingTest to iOS: \(message)")
        session.sendMessage(message, replyHandler: { reply in //
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Ping Ack by iPhone" //
                print("WatchConnectivity: Ping reply from iOS: \(reply)")
            }
        }, errorHandler: { error in //
            DispatchQueue.main.async {
                self.connectionStatusMessage = "Ping Failed" //
                self.errorMessage = "Ping Error: \(error.localizedDescription)" //
                print("WatchConnectivity: Ping error: \(error.localizedDescription)")
            }
        })
    }
    
    func getConnectionInfo() -> [String: String] { //
        return [
            "Watch Status": connectionStatusMessage, //
            "iPhone Reachable": isConnectedToPhone ? "Yes" : "No", //
            "Loaded Posts": "\(communities.count)", //
            "Loaded Comments": "\(currentPostComments.count)",
            "Last Sync": lastSyncDate?.formatted(date: .abbreviated, time: .shortened) ?? "Never", //
            "Session State": getSessionStateString(), //
            "Main Error": errorMessage ?? "None", //
            "Comments Error": commentsErrorMessage ?? "None"
        ]
    }
    private func getSessionStateString() -> String { //
        switch session.activationState { //
        case .activated: return "Active" //
        case .inactive: return "Inactive" //
        case .notActivated: return "Not Activated" //
        @unknown default: return "Unknown" //
        }
    }

    deinit { //
        retryTimer?.invalidate() //
        print("WatchConnectivity deinitialized.")
    }
}
