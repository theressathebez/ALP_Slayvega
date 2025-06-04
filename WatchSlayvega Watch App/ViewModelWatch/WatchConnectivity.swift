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
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?
    @Published var connectionStatus: String = "Connecting..."
    @Published var totalCommunities: Int = 0
    
    override init() {
        session = WCSession.default
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            DispatchQueue.main.async {
                self.connectionStatus = "Watch Connectivity not supported"
                self.errorMessage = "Device doesn't support Watch Connectivity"
            }
            return
        }
        
        session.delegate = self
        session.activate()
        
        DispatchQueue.main.async {
            self.connectionStatus = "Activating session..."
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            switch activationState {
            case .activated:
                self.isConnected = session.isReachable
                self.connectionStatus = session.isReachable ? "Connected to iPhone" : "iPhone not reachable"
                if session.isReachable {
                    self.requestCommunities()
                }
            case .inactive:
                self.isConnected = false
                self.connectionStatus = "Session inactive"
            case .notActivated:
                self.isConnected = false
                self.connectionStatus = "Session not activated"
            @unknown default:
                self.isConnected = false
                self.connectionStatus = "Unknown session state"
            }
        }
        
        if let error = error {
            print("Watch WC Session activation error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Activation error: \(error.localizedDescription)"
                self.connectionStatus = "Connection failed"
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isConnected = session.isReachable
            self.connectionStatus = session.isReachable ? "Connected to iPhone" : "iPhone not reachable"
            
            if session.isReachable {
                self.errorMessage = nil
                self.requestCommunities()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleReceivedMessage(message)
        }
    }
    
    private func handleReceivedMessage(_ message: [String: Any]) {
        isLoading = false
        errorMessage = nil
        currentRetryCount = 0
        
        if let communitiesData = message["communities"] as? [[String: Any]] {
            parseCommunities(from: communitiesData)
            lastSyncDate = Date()
            totalCommunities = communitiesData.count
            
            if let count = message["count"] as? Int {
                connectionStatus = "Synced \(count) posts"
            } else {
                connectionStatus = "Data synced successfully"
            }
        } else if let error = message["error"] as? String {
            errorMessage = "Sync error: \(error)"
            connectionStatus = "Sync failed"
        } else {
            errorMessage = "Received invalid data format"
            connectionStatus = "Data format error"
        }
    }
    
    private func parseCommunities(from data: [[String: Any]]) {
        var parsedCommunities: [WatchCommunityModel] = []
        
        for communityData in data {
            let community = WatchCommunityModel(
                id: communityData["id"] as? String ?? UUID().uuidString,
                username: communityData["username"] as? String ?? "Anonymous",
                communityContent: communityData["communityContent"] as? String ?? "",
                hashtags: communityData["hashtags"] as? String ?? "",
                communityLikeCount: communityData["communityLikeCount"] as? Int ?? 0,
                formattedDate: communityData["formattedDate"] as? String ?? "Unknown date",
                userId: communityData["userId"] as? String ?? ""
            )
            parsedCommunities.append(community)
        }
        
        // Sort by like count (descending), then by username
        parsedCommunities.sort { community1, community2 in
            if community1.communityLikeCount == community2.communityLikeCount {
                return community1.username < community2.username
            }
            return community1.communityLikeCount > community2.communityLikeCount
        }
        
        self.communities = parsedCommunities
    }
    
    func requestCommunities(retryCount: Int = 0) {
        guard session.activationState == .activated else {
            DispatchQueue.main.async {
                self.connectionStatus = "Session not ready"
                self.errorMessage = "Watch session not activated"
            }
            return
        }
        
        guard session.isReachable else {
            if retryCount < maxRetryAttempts {
                DispatchQueue.main.async {
                    self.connectionStatus = "Retrying connection... (\(retryCount + 1)/\(self.maxRetryAttempts))"
                }
                
                retryTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                    self?.requestCommunities(retryCount: retryCount + 1)
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "iPhone not reachable after \(self.maxRetryAttempts) attempts"
                    self.connectionStatus = "Connection failed"
                }
            }
            return
        }
        
        currentRetryCount = retryCount
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
            self.connectionStatus = "Requesting data from iPhone..."
        }
        
        let message = [
            "action": "requestCommunities",
            "timestamp": Date().timeIntervalSince1970,
            "watchVersion": "1.0"
        ] as [String : Any]
        
        session.sendMessage(message, replyHandler: { [weak self] reply in
            // Initial acknowledgment - actual data comes via didReceiveMessage
            DispatchQueue.main.async {
                self?.connectionStatus = "iPhone processing request..."
            }
        }, errorHandler: { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Request failed: \(error.localizedDescription)"
                self.connectionStatus = "Request error"
            }
            
            if retryCount < self.maxRetryAttempts {
                self.retryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                    self?.requestCommunities(retryCount: retryCount + 1)
                }
            }
        })
    }
    
    func refreshCommunities() {
        retryTimer?.invalidate()
        currentRetryCount = 0
        requestCommunities()
    }
    
    func testConnection() {
        guard session.isReachable else {
            DispatchQueue.main.async {
                self.connectionStatus = "iPhone not reachable"
            }
            return
        }
        
        let testMessage = [
            "action": "pingTest",
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]
        
        session.sendMessage(testMessage, replyHandler: { reply in
            DispatchQueue.main.async {
                self.connectionStatus = "Connection test passed ✓"
            }
        }, errorHandler: { error in
            DispatchQueue.main.async {
                self.connectionStatus = "Connection test failed: \(error.localizedDescription)"
            }
        })
    }
    
    // MARK: - Utility Methods
    func getTopCommunities(limit: Int = 10) -> [WatchCommunityModel] {
        return Array(communities.prefix(limit))
    }
    
    func searchCommunities(by keyword: String) -> [WatchCommunityModel] {
        if keyword.isEmpty { return communities }
        
        return communities.filter { community in
            community.communityContent.localizedCaseInsensitiveContains(keyword) ||
            community.hashtags.localizedCaseInsensitiveContains(keyword) ||
            community.username.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    func getCommunityById(_ id: String) -> WatchCommunityModel? {
        return communities.first { $0.id == id }
    }
    
    func getConnectionInfo() -> [String: String] {
        return [
            "Status": connectionStatus,
            "Connected": isConnected ? "Yes" : "No",
            "Total Posts": "\(totalCommunities)",
            "Last Sync": lastSyncDate?.formatted() ?? "Never",
            "Session State": getSessionStateString()
        ]
    }
    
    private func getSessionStateString() -> String {
        switch session.activationState {
        case .activated: return "Active"
        case .inactive: return "Inactive"
        case .notActivated: return "Not Activated"
        @unknown default: return "Unknown"
        }
    }
    
    deinit {
        retryTimer?.invalidate()
    }
}
