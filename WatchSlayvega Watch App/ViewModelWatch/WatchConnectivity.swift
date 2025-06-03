import WatchConnectivity
import Foundation

struct WatchCommunityModel: Identifiable, Hashable {
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
    
    @Published var communities: [WatchCommunityModel] = []
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?
    
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
            if activationState == .activated {
                self.requestCommunities()
            }
        }
        
        if let error = error {
            print("Watch WC Session activation error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Connection error: \(error.localizedDescription)"
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = nil
            
            if let communitiesData = message["communities"] as? [[String: Any]] {
                self.parseCommunities(from: communitiesData)
                self.lastSyncDate = Date()
            } else if let error = message["error"] as? String {
                self.errorMessage = error
            }
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
                formattedDate: communityData["formattedDate"] as? String ?? "",
                userId: communityData["userId"] as? String ?? ""
            )
            parsedCommunities.append(community)
        }
        
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
            session.activate()
            return
        }
        
        guard session.isReachable else {
            if retryCount < maxRetryAttempts {
                retryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                    self?.requestCommunities(retryCount: retryCount + 1)
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "iPhone unavailable"
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let message = ["action": "requestCommunities"]
        
        session.sendMessage(message, replyHandler: { reply in
            // Reply handled in didReceiveMessage
        }, errorHandler: { error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Sync failed: \(error.localizedDescription)"
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
        requestCommunities()
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
}
