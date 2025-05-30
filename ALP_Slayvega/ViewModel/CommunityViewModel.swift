import Foundation
import FirebaseDatabase
import FirebaseAuth

class CommunityViewModel: ObservableObject {
    @Published var communities: [CommunityModel] = []
    @Published var userCommunities: [CommunityModel] = []
    
    private var dbRef = Database.database().reference().child("communities")
    private var allPostsListener: DatabaseHandle?
    private var userPostsListener: DatabaseHandle?
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            self?.loadAllCommunities()
            self?.loadUserCommunity()
        }
        loadAllCommunities()
        loadUserCommunity()
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        if let handle = allPostsListener {
            dbRef.removeObserver(withHandle: handle)
        }
        if let handle = userPostsListener {
            dbRef.removeObserver(withHandle: handle)
        }
    }
    
    // Load all posts from all users
    func loadAllCommunities() {
        if let handle = allPostsListener {
            dbRef.removeObserver(withHandle: handle)
        }
        
        allPostsListener = dbRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            var fetched: [CommunityModel] = []
            
            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any] {
                    // Handle date parsing from Firebase
                    var communityDate = Date()
                    if let timestamp = data["communityDates"] as? TimeInterval {
                        communityDate = Date(timeIntervalSince1970: timestamp / 1000)
                    } else if let dateString = data["communityDates"] as? String {
                        let formatter = ISO8601DateFormatter()
                        communityDate = formatter.date(from: dateString) ?? Date()
                    }
                    
                    let community = CommunityModel(
                        id: data["id"] as? String ?? child.key,
                        username: data["username"] as? String ?? "",
                        communityContent: data["communityContent"] as? String ?? "",
                        hashtags: data["hashtags"] as? String ?? "",
                        communityLikeCount: data["communityLikeCount"] as? Int ?? 0,
                        communityDates: communityDate,
                        userId: data["userId"] as? String ?? ""
                    )
                    fetched.append(community)
                }
            }
            
            DispatchQueue.main.async {
                self.communities = fetched
            }
        }
    }
    
    // Load only current user's posts (for profile/my posts view)
    func loadUserCommunity() {
        if let handle = userPostsListener {
            dbRef.removeObserver(withHandle: handle)
        }
        
        guard let uid = userId else {
            userCommunities.removeAll()
            return
        }

        userPostsListener = dbRef
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: uid)
            .observe(.value) { [weak self] snapshot in
                guard let self = self else { return }
                var fetched: [CommunityModel] = []
                
                for case let child as DataSnapshot in snapshot.children {
                    if let data = child.value as? [String: Any] {
                        // Handle date parsing from Firebase
                        var communityDate = Date()
                        if let timestamp = data["communityDates"] as? TimeInterval {
                            communityDate = Date(timeIntervalSince1970: timestamp / 1000)
                        } else if let dateString = data["communityDates"] as? String {
                            let formatter = ISO8601DateFormatter()
                            communityDate = formatter.date(from: dateString) ?? Date()
                        }
                        
                        let community = CommunityModel(
                            id: data["id"] as? String ?? child.key,
                            username: data["username"] as? String ?? "",
                            communityContent: data["communityContent"] as? String ?? "",
                            hashtags: data["hashtags"] as? String ?? "",
                            communityLikeCount: data["communityLikeCount"] as? Int ?? 0,
                            communityDates: communityDate,
                            userId: data["userId"] as? String ?? ""
                        )
                        fetched.append(community)
                    }
                }
                
                DispatchQueue.main.async {
                    self.userCommunities = fetched
                }
            }
    }
    
    func createCommunity(_ community: CommunityModel) {
        guard let uid = userId else { return }
        
        var newCommunity = community
        newCommunity.userId = uid
        
        // Convert to dictionary manually to handle Date properly
        let communityDict: [String: Any] = [
            "id": newCommunity.id,
            "username": newCommunity.username,
            "communityContent": newCommunity.communityContent,
            "hashtags": newCommunity.hashtags,
            "communityLikeCount": newCommunity.communityLikeCount,
            "communityDates": newCommunity.communityDates.timeIntervalSince1970 * 1000, // Convert to milliseconds
            "userId": newCommunity.userId
        ]
        
        dbRef.child(newCommunity.id).setValue(communityDict) { error, _ in
            if let error = error {
                print("Error creating post: \(error.localizedDescription)")
            }
        }
    }

    func removeCommunity(withId id: String) {
        dbRef.child(id).removeValue { error, _ in
            if let error = error {
                print("Error removing post: \(error.localizedDescription)")
            }
        }
    }

    func clearLocalData() {
        communities.removeAll()
        userCommunities.removeAll()
    }
}
