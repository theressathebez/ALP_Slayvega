import Foundation
import FirebaseDatabase
import FirebaseAuth

class CommunityViewModel: ObservableObject {
    @Published var communities: [CommunityModel] = []
    @Published var userCommunities: [CommunityModel] = []
    
    private var dbRef = Database.database().reference().child("communities")
    private var likesRef = Database.database().reference().child("post_likes")
    private var allPostsListener: DatabaseHandle?
    private var userPostsListener: DatabaseHandle?
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var likeCountListeners: [String: DatabaseHandle] = [:]
    
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
        
        // Remove all like count listeners
        for (postId, handle) in likeCountListeners {
            likesRef.child(postId).removeObserver(withHandle: handle)
        }
        likeCountListeners.removeAll()
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
        // Remove the post
        dbRef.child(id).removeValue { error, _ in
            if let error = error {
                print("Error removing post: \(error.localizedDescription)")
            }
        }
        
        // Remove all likes for this post
        likesRef.child(id).removeValue()
    }

    func clearLocalData() {
        communities.removeAll()
        userCommunities.removeAll()
    }
    
    // MARK: - Like Functionality
    
    // Toggle like for a post
    func togglePostLike(postId: String, userId: String, isLiked: Bool, currentLikeCount: Int) {
        let postLikeRef = likesRef.child(postId).child(userId)
        let postRef = dbRef.child(postId)
        
        if isLiked {
            // Add like
            postLikeRef.setValue(true) { [weak self] error, _ in
                if let error = error {
                    print("Error adding like: \(error.localizedDescription)")
                    return
                }
                
                // Update like count in the post
                postRef.child("communityLikeCount").setValue(currentLikeCount)
            }
        } else {
            // Remove like
            postLikeRef.removeValue { [weak self] error, _ in
                if let error = error {
                    print("Error removing like: \(error.localizedDescription)")
                    return
                }
                
                // Update like count in the post
                postRef.child("communityLikeCount").setValue(max(0, currentLikeCount))
            }
        }
    }
    
    // Check if user liked a specific post
    func checkIfUserLikedPost(postId: String, userId: String, completion: @escaping (Bool) -> Void) {
        likesRef.child(postId).child(userId).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    // Get real-time like count for a post
    func observePostLikeCount(postId: String, completion: @escaping (Int) -> Void) {
        // Remove existing listener if any
        if let existingHandle = likeCountListeners[postId] {
            likesRef.child(postId).removeObserver(withHandle: existingHandle)
        }
        
        // Add new listener
        let handle = likesRef.child(postId).observe(.value) { snapshot in
            let likeCount = Int(snapshot.childrenCount)
            completion(likeCount)
        }
        
        likeCountListeners[postId] = handle
    }
    
    // Stop observing like count for a specific post
    func stopObservingLikeCount(for postId: String) {
        if let handle = likeCountListeners[postId] {
            likesRef.child(postId).removeObserver(withHandle: handle)
            likeCountListeners.removeValue(forKey: postId)
        }
    }
    
    // Get all users who liked a post
    func getUsersWhoLikedPost(postId: String, completion: @escaping ([String]) -> Void) {
        likesRef.child(postId).observeSingleEvent(of: .value) { snapshot in
            var userIds: [String] = []
            for case let child as DataSnapshot in snapshot.children {
                userIds.append(child.key)
            }
            completion(userIds)
        }
    }
}
