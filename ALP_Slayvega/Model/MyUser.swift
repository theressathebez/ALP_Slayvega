//
//  MyUser.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import Foundation
struct MyUser{
    var uid: String = ""
    var email: String = ""
    var name: String = ""
    var password: String = ""
    
    func getDisplayName() -> String {
        if !name.isEmpty {
            return name
        } else if !email.isEmpty {
            return String(email.split(separator: "@").first ?? "User")
        } else {
            return "User"
        }
    }
}
