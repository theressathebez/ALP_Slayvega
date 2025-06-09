//
//  ProfileView.swift
//  ALP_Slayvega
//
//  Created by student on 22/05/25.
//
import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @Binding var showAuthSheet: Bool
    @ObservedObject var authVM: AuthViewModel
    @State private var isEditing = false
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingPasswordChange = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Picture Placeholder
                        Circle()
                            .fill(Color("#FFA075").opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(authVM.myUser.getDisplayName().prefix(1)).uppercased())
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color("#FFA075"))
                            )
                        
                        Text(authVM.myUser.getDisplayName())
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(authVM.myUser.email.isEmpty ? authVM.user?.email ?? "" : authVM.myUser.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Profile Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Profile Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            // Name Field
                            ProfileInfoRow(
                                title: "Display Name",
                                value: authVM.myUser.name.isEmpty ? "Not set" : authVM.myUser.name,
                                isEditing: isEditing,
                                editValue: $tempName
                            )
                            
                            Divider()
                            
                            // Email Field
                            ProfileInfoRow(
                                title: "Email",
                                value: authVM.myUser.email.isEmpty ? authVM.user?.email ?? "" : authVM.myUser.email,
                                isEditing: isEditing,
                                editValue: $tempEmail
                            )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 12) {
                        if isEditing {
                            HStack(spacing: 12) {
                                Button("Cancel") {
                                    cancelEditing()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.gray)
                                .cornerRadius(20)
                                
                                Button("Save Changes") {
                                    saveChanges()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color("#FFA075"))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .disabled(isLoading)
                            }
                            .padding(.horizontal)
                        } else {
                            Button("Edit Profile") {
                                startEditing()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color("#FFA075"))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                        Button("Change Password") {
                            showingPasswordChange = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        Button("Logout") {
                            authVM.signOut()
                            showAuthSheet = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                initializeValues()
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingPasswordChange) {
                ChangePasswordView(
                    authVM: authVM,
                    currentPassword: $currentPassword,
                    newPassword: $newPassword,
                    confirmPassword: $confirmPassword,
                    isPresented: $showingPasswordChange
                )
            }
        }
    }
    
    private func initializeValues() {
        tempName = authVM.myUser.name
        tempEmail = authVM.myUser.email.isEmpty ? authVM.user?.email ?? "" : authVM.myUser.email
    }
    
    private func startEditing() {
        isEditing = true
        tempName = authVM.myUser.name
        tempEmail = authVM.myUser.email.isEmpty ? authVM.user?.email ?? "" : authVM.myUser.email
    }
    
    private func cancelEditing() {
        isEditing = false
        tempName = authVM.myUser.name
        tempEmail = authVM.myUser.email.isEmpty ? authVM.user?.email ?? "" : authVM.myUser.email
    }
    
    private func saveChanges() {
        isLoading = true
        
        // Save name changes
        authVM.myUser.name = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If email changed, update it
        if tempEmail != (authVM.myUser.email.isEmpty ? authVM.user?.email ?? "" : authVM.myUser.email) {
            updateEmail()
        } else {
            // If only name changed
            isEditing = false
            isLoading = false
            showAlert(title: "Success", message: "Profile updated successfully!")
        }
    }
    
    private func updateEmail() {
        Task {
            do {
                try await authVM.user?.updateEmail(to: tempEmail)
                DispatchQueue.main.async {
                    authVM.myUser.email = tempEmail
                    isEditing = false
                    isLoading = false
                    showAlert(title: "Success", message: "Profile updated successfully!")
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    showAlert(title: "Error", message: "Failed to update email: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct ProfileInfoRow: View {
    let title: String
    let value: String
    let isEditing: Bool
    @Binding var editValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            if isEditing && title != "Email" { // Don't allow email editing in this row for simplicity
                TextField(title, text: $editValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(value)
                    .font(.body)
                    .foregroundColor(value == "Not set" ? .gray : .primary)
            }
        }
    }
}

struct ChangePasswordView: View {
    @ObservedObject var authVM: AuthViewModel
    @Binding var currentPassword: String
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    @Binding var isPresented: Bool
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Change Password")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    SecureField("Current Password", text: $currentPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button("Update Password") {
                    updatePassword()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color("#FFA075"))
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal)
                .disabled(isLoading || newPassword.isEmpty || confirmPassword.isEmpty || currentPassword.isEmpty)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                    clearFields()
                }
            )
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {
                if alertTitle == "Success" {
                    isPresented = false
                    clearFields()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func updatePassword() {
        guard newPassword == confirmPassword else {
            showAlert(title: "Error", message: "New passwords don't match")
            return
        }
        
        guard newPassword.count >= 6 else {
            showAlert(title: "Error", message: "Password must be at least 6 characters long")
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Re-authenticate user with current password
                let credential = EmailAuthProvider.credential(withEmail: authVM.user?.email ?? "", password: currentPassword)
                try await authVM.user?.reauthenticate(with: credential)
                
                // Update password
                try await authVM.user?.updatePassword(to: newPassword)
                
                DispatchQueue.main.async {
                    isLoading = false
                    showAlert(title: "Success", message: "Password updated successfully!")
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    showAlert(title: "Error", message: "Failed to update password: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func clearFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

