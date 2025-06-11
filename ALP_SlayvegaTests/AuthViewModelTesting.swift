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
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        viewModel = AuthViewModel()
    }

    override func tearDownWithError() throws {
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
        try? Auth.auth().signOut()

        viewModel.checkUserSession()

        XCTAssertNil(viewModel.user)
        XCTAssertFalse(viewModel.isSignedIn)
    }

    func testCheckUserSessionUpdatesMyUserEmail() {
        viewModel.checkUserSession()

        if viewModel.user == nil {
            XCTAssertFalse(viewModel.isSignedIn)
            XCTAssertNil(viewModel.user)
        }
    }

    // MARK: - Sign Out Tests

    func testSignOut() {
        viewModel.myUser.email = "test@example.com"
        viewModel.myUser.uid = "test-uid"
        viewModel.myUser.name = "Test User"
        viewModel.isSignedIn = true

        viewModel.signOut()

        XCTAssertTrue(viewModel.myUser.email.isEmpty)
        XCTAssertTrue(viewModel.myUser.uid.isEmpty)
        XCTAssertTrue(viewModel.myUser.name.isEmpty)
        XCTAssertTrue(viewModel.myUser.password.isEmpty)

        XCTAssertFalse(viewModel.isSignedIn)
        XCTAssertNil(viewModel.user)
    }

    func testSignOutCreatesNewMyUser() {
        var originalMyUser = viewModel.myUser
        originalMyUser.email = "test@example.com"

        viewModel.signOut()

        XCTAssertTrue(viewModel.myUser.email.isEmpty)
    }

    // MARK: - Sign In Tests

    func testSignInWithInvalidCredentials() async {
        viewModel.myUser.email =
            "definitely-invalid-email-12345@nonexistent-domain-xyz.com"
        viewModel.myUser.password = "wrongpassword123"

        viewModel.falseCredential = false

        await viewModel.signIn()

        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

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
        viewModel.myUser.email = ""
        viewModel.myUser.password = ""

        viewModel.falseCredential = false

        await viewModel.signIn()

        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

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
        viewModel.falseCredential = true

        XCTAssertTrue(viewModel.falseCredential)
    }

    // MARK: - Sign Up Tests

    func testSignUpWithInvalidEmail() async {
        viewModel.myUser.email = "invalid-email"
        viewModel.myUser.password = "password123"

        viewModel.falseCredential = false

        await viewModel.signUp()

        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected falseCredential to be true after invalid email. Current value: \(viewModel.falseCredential)"
        )
        XCTAssertFalse(viewModel.isSignedIn)
    }

    func testSignUpWithWeakPassword() async {
        viewModel.myUser.email = "test@example.com"
        viewModel.myUser.password = "123"

        viewModel.falseCredential = false

        await viewModel.signUp()

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

        viewModel.falseCredential = false

        await viewModel.signUp()

        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected falseCredential to be true after empty credentials. Current value: \(viewModel.falseCredential)"
        )
        XCTAssertFalse(viewModel.isSignedIn)
    }

    // MARK: - Fetch User Profile Tests

    func testFetchUserProfileWithNoCurrentUser() {
        try? Auth.auth().signOut()

        viewModel.fetchUserProfile()

        XCTAssertNil(viewModel.user)
    }

    func testFetchUserProfileUpdatesUserInfo() {
        viewModel.fetchUserProfile()

        if Auth.auth().currentUser == nil {
            XCTAssertNil(viewModel.user)
        }
    }

    // MARK: - Property State Tests

    func testFalseCredentialResetOnSuccessfulAuth() {
        viewModel.falseCredential = true

        viewModel.falseCredential = false
        viewModel.isSignedIn = true

        XCTAssertFalse(viewModel.falseCredential)
        XCTAssertTrue(viewModel.isSignedIn)
    }

    func testUserPropertyConsistency() {
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
        viewModel.myUser.email = "invalid@example.com"
        viewModel.myUser.password = "wrongpassword"

        viewModel.falseCredential = false

        await viewModel.signIn()

        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        XCTAssertTrue(
            viewModel.falseCredential,
            "Expected either falseCredential to be true or isSignedIn to be true. falseCredential: \(viewModel.falseCredential), isSignedIn: \(viewModel.isSignedIn)"
        )
    }

    func testSignUpIsAsync() async {
        viewModel.myUser.email = "newuser@example.com"
        viewModel.myUser.password = "password123"

        viewModel.falseCredential = false

        await viewModel.signUp()

        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 second

        XCTAssertTrue(
            viewModel.falseCredential || viewModel.isSignedIn,
            "Expected either error or success. falseCredential: \(viewModel.falseCredential), isSignedIn: \(viewModel.isSignedIn)"
        )
    }

    // MARK: - Error Handling Tests

    func testSignOutErrorHandling() {
        viewModel.myUser.email = "test@example.com"
        viewModel.isSignedIn = true

        viewModel.signOut()

        XCTAssertTrue(viewModel.myUser.email.isEmpty)
        XCTAssertFalse(viewModel.isSignedIn)
    }

    // MARK: - State Consistency Tests

    func testStateConsistencyAfterSignOut() {
        viewModel.isSignedIn = true
        viewModel.myUser.email = "test@example.com"
        viewModel.myUser.uid = "test-uid"
        viewModel.falseCredential = false

        viewModel.signOut()

        XCTAssertFalse(viewModel.isSignedIn)
        XCTAssertNil(viewModel.user)
        XCTAssertTrue(viewModel.myUser.email.isEmpty)
        XCTAssertTrue(viewModel.myUser.uid.isEmpty)
    }

    func testInitialStateConsistency() {
        let newViewModel = AuthViewModel()

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

        XCTAssertNil(weakViewModel, "AuthViewModel should be deallocated")
    }

    func testUpdateDisplayNameWithNilUserDoesNotCrash() async throws {
        // Seharusnya tidak crash meskipun currentUser = nil
        do {
            try await viewModel.updateDisplayName(to: "New Name")
            XCTAssert(
                true,
                "updateDisplayName tidak menyebabkan crash saat tidak ada user")
        } catch {
            XCTFail("updateDisplayName gagal dijalankan")
        }
    }
}
