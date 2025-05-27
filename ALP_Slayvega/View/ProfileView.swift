//
//  ProfileView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var userName: String = ""
    @State private var showingAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Your Display Name")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 40)
            
            Text("This name will be shown when you choose to reveal your identity in community posts.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Enter your name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Save Name") {
                if !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    authVM.myUser.name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                    showingAlert = true
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 40)
            .background(Color(hex: "#FFA075"))
            .cornerRadius(20)
            .disabled(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button("Skip for Now") {
                dismiss()
            }
            .font(.system(size: 14))
            .foregroundColor(.gray)
            .padding(.top, 10)
            
            Spacer()
        }
        .onAppear {
            userName = authVM.myUser.name
        }
        .alert("Name Saved", isPresented: $showingAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your display name has been saved successfully!")
        }
    }
}


#Preview {
    ProfileSetupView(authVM: AuthViewModel())
}
