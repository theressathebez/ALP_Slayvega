//
//  CommunityViewModel.swift
//  ALP_Slayvega
//
//  Created by student on 27/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class CommunityViewModel: ObservableObject {
    @Published var communities: [CommunityModel] = []
    
    private var dbRef = Database.database().reference().child("communities")
    private var currentListener: DatabaseHandle?
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
                    self?.loadUserCommunity()
                }
        loadUserCommunity()
    }
    
    deinit{
        if let handle = authHandle {
                    Auth.auth().removeStateDidChangeListener(handle)
                }
    }
    
    func loadUserCommunity() {
        if let handle = currentListener {
            dbRef.removeObserver(withHandle: handle)
        }
        
        guard let uid = userId else {
            communities.removeAll()
            return
        }

        currentListener = dbRef
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: uid)
            .observe(.value) { [weak self] snapshot in
                guard let self = self else { return }
                var fetched: [CommunityModel] = []
                
                for case let child as DataSnapshot in snapshot.children {
                    if let data = child.value as? [String: Any] {
                        let community = CommunityModel(
                            id: data["id"] as? String ?? child.key,
                            username: data["username"] as? String ?? "",
                            communityContent: data["communityContent"] as? String ?? "",
                            hashtags: data["hashtags"] as? String ?? "",
                            communityLikeCount: data["communityLikeCount"] as? Int ?? 0,
                            communityDates: data["communityDates"] as? Date ?? Date(),
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
    
    func createSpot(_ community: CommunityModel) {
        guard let uid = userId else { return }
        
        var newCommunity = community
        newCommunity.userId = uid
        
        guard let encoded = try? JSONEncoder().encode(newCommunity),
              let dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            print("Failed encode spot")
            return
        }
        
        dbRef.child(newCommunity.id).setValue(dict)
    }

    func removeCommunity(withId id: String) {
        dbRef.child(id).removeValue()
    }

    func clearLocalData() {
        communities.removeAll()
    }
}
