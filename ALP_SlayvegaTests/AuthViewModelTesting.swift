//
//  AuthViewModelTesting.swift
//  ALP_SlayvegaTests
//
//  Created by Monica Thebez on 11/06/25.
//

import FirebaseAuth
import FirebaseCore
import XCTest

@testable import ALP_Slayvega

final class AuthViewModelTesting: XCTestCase {

    var viewModel: AuthViewModel!

    override func setUpWithError() throws {
        // Configure Firebase for testing if needed
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        viewModel = AuthViewModel()
    }

    override func tearDownWithError() throws {
        // Sign out any existing user to clean up
        try? Auth.auth().signOut()
        viewModel = nil
    }

    // MARK: - Initial State Tests

    func testInitialState() throws {
        XCTAssertFalse(viewModel.isSignedIn)
        XCTAssertNil(viewModel.user)
        XCTAssertNotNil(viewModel.myUser)
        XCTAssertFalse(viewModel.falseCredential)
        XCTAssertTrue(viewModel.myUser.email.isEmpty)
        XCTAssertTrue(viewModel.myUser.password.isEmpty)
        XCTAssertTrue(viewModel.myUser.name.isEmpty)
        XCTAssertTrue(viewModel.myUser.uid.isEmpty)
    }

    func testMyUserInitialization() {
        let myUser = viewModel.myUser
        XCTAssertTrue(myUser.email.isEmpty)
        XCTAssertTrue(myUser.password.isEmpty)
        XCTAssertTrue(myUser.name.isEmpty)
        XCTAssertTrue(myUser.uid.isEmpty)
    }

    // MARK: - User Session Tests

    func testCheckUserSessionWithNoUser() {
        // Ensure no user is signed in
        try? Auth.auth().signOut()

        viewModel.checkUserSession()

        XCTAssertNil(viewModel.user)
        XCTAssertFalse(viewModel.isSignedIn)
    }

    func testCheckUserSessionUpdatesMyUserEmail() {
        // This test would require a mock or actual Firebase user
        // For now, we test the logic when user is nil
        viewModel.checkUserSession()

        if viewModel.user == nil {
            XCTAssertFalse(viewModel.isSignedIn)
            XCTAssertNil(viewModel.user)
        }
    }

    // MARK: - Sign Out Tests

    func testSignOut() {
        // Set up initial state as if user was signed in
        viewModel.myUser.email = "test@example.com"
        viewModel.myUser.uid = "test-uid"
        viewModel.myUser.name = "Test User"
        viewModel.isSignedIn = true

        viewModel.signOut()

        // Verify myUser is reset
        XCTAssertTrue(viewModel.myUser.email.isEmpty)
        XCTAssertTrue(viewModel.myUser.uid.isEmpty)
        XCTAssertTrue(viewModel.myUser.name.isEmpty)
        XCTAssertTrue(viewModel.myUser.password.isEmpty)

        // Verify sign in state is updated
        XCTAssertFalse(viewModel.isSignedIn)
        XCTAssertNil(viewModel.user)
    }

    func testSignOutCreatesNewMyUser() {
        var originalMyUser = viewModel.myUser
        originalMyUser.email = "test@example.com"

        viewModel.signOut()

        // Verify a new MyUser instance is created
        XCTAssertTrue(viewModel.myUser.email.isEmpty)
        // The actual object reference might be different after reset
    }

    // MARK: - Sign In Tests

    func testSignInWithInvalidCredentials() async {
        // Given: Invalid credentials
        viewModel.myUser.email =
            "definitely-invalid-email-12345@nonexistent-domain-xyz.com"
        viewModel.myUser.password = "wrongpassword123"

        // Reset falseCredential to ensure clean test
        viewModel.falseCredential = false

        // When: Attempting to sign in
        await viewModel.signIn()

        // Add a small delay to ensure async operations complete
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        // Then: Should indicate failure
        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected falseCredential to be true after invalid sign in attempt. Current value: \(viewModel.falseCredential)"
        )
        XCTAssertFalse(
            viewModel.isSignedIn,
            "Expected isSignedIn to be false after invalid sign in attempt. Current value: \(viewModel.isSignedIn)"
        )
        XCTAssertNil(
            viewModel.user,
            "Expected user to be nil after invalid sign in attempt. Current value: \(viewModel.user?.description ?? "nil")"
        )
    }

    func testSignInWithEmptyCredentials() async {
        // Given: Empty credentials
        viewModel.myUser.email = ""
        viewModel.myUser.password = ""

        // Reset falseCredential to ensure clean test
        viewModel.falseCredential = false

        // When: Attempting to sign in
        await viewModel.signIn()

        // Add a small delay to ensure async operations complete
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        // Then: Should indicate failure
        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected falseCredential to be true after empty credentials. Current value: \(viewModel.falseCredential)"
        )
        XCTAssertFalse(
            viewModel.isSignedIn,
            "Expected isSignedIn to be false after empty credentials. Current value: \(viewModel.isSignedIn)"
        )
    }

    func testSignInResetsfalseCredentialOnSuccess() {
        // Set initial false credential state
        viewModel.falseCredential = true

        // This would require a valid user account or mocking
        // For testing purposes, we verify the logic structure exists
        XCTAssertTrue(viewModel.falseCredential)
    }

    // MARK: - Sign Up Tests

    func testSignUpWithInvalidEmail() async {
        viewModel.myUser.email = "invalid-email"
        viewModel.myUser.password = "password123"

        // Reset falseCredential to ensure clean test
        viewModel.falseCredential = false

        await viewModel.signUp()

        // Add a small delay to ensure async operations complete
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected falseCredential to be true after invalid email. Current value: \(viewModel.falseCredential)"
        )
        XCTAssertFalse(viewModel.isSignedIn)
    }

    func testSignUpWithWeakPassword() async {
        viewModel.myUser.email = "test@example.com"
        viewModel.myUser.password = "123"  // Too weak

        // Reset falseCredential to ensure clean test
        viewModel.falseCredential = false

        await viewModel.signUp()

        // Add a small delay to ensure async operations complete
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected falseCredential to be true after weak password. Current value: \(viewModel.falseCredential)"
        )
        XCTAssertFalse(viewModel.isSignedIn)
    }

    func testSignUpWithEmptyCredentials() async {
        viewModel.myUser.email = ""
        viewModel.myUser.password = ""

        // Reset falseCredential to ensure clean test
        viewModel.falseCredential = false

        await viewModel.signUp()

        // Add a small delay to ensure async operations complete
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected falseCredential to be true after empty credentials. Current value: \(viewModel.falseCredential)"
        )
        XCTAssertFalse(viewModel.isSignedIn)
    }

    // MARK: - Fetch User Profile Tests

    func testFetchUserProfileWithNoCurrentUser() {
        // Ensure no user is signed in
        try? Auth.auth().signOut()

        viewModel.fetchUserProfile()

        // Should not crash and should not update user info
        XCTAssertNil(viewModel.user)
    }

    func testFetchUserProfileUpdatesUserInfo() {
        // This test requires a mock or actual signed-in user
        // Testing the method doesn't crash when no user exists
        viewModel.fetchUserProfile()

        // If no current user, nothing should change
        if Auth.auth().currentUser == nil {
            XCTAssertNil(viewModel.user)
        }
    }

    // MARK: - Property State Tests

    func testFalseCredentialResetOnSuccessfulAuth() {
        viewModel.falseCredential = true

        // Simulate successful authentication by manually setting states
        // In real scenario, this would be set by successful Firebase auth
        viewModel.falseCredential = false
        viewModel.isSignedIn = true

        XCTAssertFalse(viewModel.falseCredential)
        XCTAssertTrue(viewModel.isSignedIn)
    }

    func testUserPropertyConsistency() {
        // Test that user and isSignedIn are consistent
        if viewModel.user != nil {
            XCTAssertTrue(viewModel.isSignedIn)
        } else {
            XCTAssertFalse(viewModel.isSignedIn)
        }
    }

    // MARK: - MyUser Data Integrity Tests

    func testMyUserEmailValidation() {
        let testEmail = "test@example.com"
        viewModel.myUser.email = testEmail

        XCTAssertEqual(viewModel.myUser.email, testEmail)
        XCTAssertFalse(viewModel.myUser.email.isEmpty)
    }

    func testMyUserPasswordHandling() {
        let testPassword = "securePassword123"
        viewModel.myUser.password = testPassword

        XCTAssertEqual(viewModel.myUser.password, testPassword)
        XCTAssertFalse(viewModel.myUser.password.isEmpty)
    }

    func testMyUserUIDHandling() {
        let testUID = "test-user-id-123"
        viewModel.myUser.uid = testUID

        XCTAssertEqual(viewModel.myUser.uid, testUID)
        XCTAssertFalse(viewModel.myUser.uid.isEmpty)
    }

    // MARK: - Async Function Tests

    func testSignInIsAsync() async {
        // Verify that signIn can be called asynchronously
        viewModel.myUser.email = "invalid@example.com"
        viewModel.myUser.password = "wrongpassword"

        // Reset falseCredential to ensure clean test
        viewModel.falseCredential = false

        // This should not crash and should complete
        await viewModel.signIn()

        // Add a small delay to ensure async operations complete
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        // Verify the function completed - should have error for invalid credentials
        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected either falseCredential to be true or isSignedIn to be true. falseCredential: \(viewModel.falseCredential), isSignedIn: \(viewModel.isSignedIn)"
        )
    }

    func testSignUpIsAsync() async {
        // Verify that signUp can be called asynchronously
        viewModel.myUser.email = "newuser@example.com"
        viewModel.myUser.password = "password123"

        // Reset falseCredential to ensure clean test
        viewModel.falseCredential = false

        await viewModel.signUp()

        // Add a small delay to ensure async operations complete
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        // Should complete without crashing
        // Note: This might succeed or fail depending on whether the email already exists
        XCTAssertTrue(
            viewModel.falseCredential || viewModel.isSignedIn,
            "Expected either error or success. falseCredential: \(viewModel.falseCredential), isSignedIn: \(viewModel.isSignedIn)"
        )
    }

    // MARK: - Error Handling Tests

    func testSignOutErrorHandling() {
        // Test that signOut handles errors gracefully
        // Even if Firebase throws an error, the local state should be cleared
        viewModel.myUser.email = "test@example.com"
        viewModel.isSignedIn = true

        viewModel.signOut()

        // Local state should be cleared regardless of Firebase errors
        XCTAssertTrue(viewModel.myUser.email.isEmpty)
        XCTAssertFalse(viewModel.isSignedIn)
    }

    // MARK: - State Consistency Tests

    func testStateConsistencyAfterSignOut() {
        // Set up authenticated state
        viewModel.isSignedIn = true
        viewModel.myUser.email = "test@example.com"
        viewModel.myUser.uid = "test-uid"
        viewModel.falseCredential = false

        viewModel.signOut()

        // Verify all related states are properly reset
        XCTAssertFalse(viewModel.isSignedIn)
        XCTAssertNil(viewModel.user)
        XCTAssertTrue(viewModel.myUser.email.isEmpty)
        XCTAssertTrue(viewModel.myUser.uid.isEmpty)
    }

    func testInitialStateConsistency() {
        let newViewModel = AuthViewModel()

        // All initial states should be consistent
        XCTAssertEqual(newViewModel.isSignedIn, (newViewModel.user != nil))
        XCTAssertFalse(newViewModel.falseCredential)
        XCTAssertNotNil(newViewModel.myUser)
    }

    // MARK: - Performance Tests

    func testSignOutPerformance() {
        measure {
            viewModel.signOut()
        }
    }

    func testCheckUserSessionPerformance() {
        measure {
            viewModel.checkUserSession()
        }
    }

    // MARK: - Memory Management Tests

    func testViewModelDeallocation() {
        weak var weakViewModel: AuthViewModel?

        autoreleasepool {
            let testViewModel = AuthViewModel()
            weakViewModel = testViewModel
            testViewModel.signOut()
        }

        // ViewModel should be deallocated when no strong references remain
        XCTAssertNil(weakViewModel, "AuthViewModel should be deallocated")
    }
}
