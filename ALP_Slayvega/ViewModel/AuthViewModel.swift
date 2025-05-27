//
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
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
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


}
