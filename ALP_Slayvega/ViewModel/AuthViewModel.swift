
//  AuthViewModel.swift
//  ALP_Slayvega
//
//  Created by student on 27/05/25.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool
    @Published var user: User?
    @Published var myUser: MyUser
    @Published var falseCredential: Bool

    init() {
        self.user = nil
        self.isSignedIn = false
        self.myUser = MyUser()
        self.falseCredential = false
        self.checkUserSession()
    }

    func checkUserSession() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = self.user != nil
        
        // Update myUser email if user is signed in
        if let currentUser = self.user {
            if self.myUser.email.isEmpty {
                self.myUser.email = currentUser.email ?? ""
            }
            self.myUser.uid = currentUser.uid
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            // Clear user data
            self.myUser = MyUser()
            self.checkUserSession()
        } catch {
            print("Error signing out: \(error)")
        }
    }

    func signIn() async {
        do {
            let result = try await Auth.auth().signIn(
                withEmail: myUser.email,
                password: myUser.password
            )
            
            DispatchQueue.main.async {
                self.user = result.user
                self.myUser.uid = result.user.uid
                self.myUser.email = result.user.email ?? self.myUser.email
                self.isSignedIn = true
                self.falseCredential = false
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
        }
    }

    func signUp() async {
        do {
            let result = try await Auth.auth().createUser(
                withEmail: myUser.email,
                password: myUser.password
            )

            DispatchQueue.main.async {
                self.user = result.user
                self.myUser.uid = result.user.uid
                self.myUser.email = result.user.email ?? self.myUser.email
                self.isSignedIn = true
                self.falseCredential = false
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
                print("Sign Up Error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }

        self.user = currentUser
        self.myUser.uid = currentUser.uid
        self.myUser.email = currentUser.email ?? ""
        self.myUser.name = currentUser.displayName ?? ""
    }

}
