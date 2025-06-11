//
//  WatchSlayvega_Watch_AppTests.swift
//  WatchSlayvega Watch AppTests
//
//  Created by student on 03/06/25.
//

import XCTest

@testable import WatchSlayvega_Watch_App

final class WatchSlayvega_Watch_AppTests: XCTestCase {

    var watchConnectivity: WatchConnectivity!

    override func setUpWithError() throws {
        watchConnectivity = WatchConnectivity()
    }

    override func tearDownWithError() throws {
        watchConnectivity = nil
    }

    func testInitialState() {
        XCTAssertNotNil(watchConnectivity)
        XCTAssertTrue(watchConnectivity.communities.isEmpty)
        XCTAssertTrue(watchConnectivity.currentPostComments.isEmpty)
        XCTAssertFalse(watchConnectivity.isLoading)
        XCTAssertNil(watchConnectivity.errorMessage)
        XCTAssertEqual(
            watchConnectivity.connectionStatusMessage, "Initializing...")
    }

    func testParseAndStoreCommunities() {
        let sampleData: [[String: Any]] = [
            [
                "id": "1",
                "username": "UserA",
                "communityContent": "Hello Watch!",
                "hashtags": "#watchos",
                "communityLikeCount": 5,
                "formattedDate": "2025-06-10",
                "userId": "user_a",
            ]
        ]

        let mirror = Mirror(reflecting: watchConnectivity!)
        let parseCommunitiesMethod =
            mirror.descendant("parseAndStoreCommunities")
            as? ([[String: Any]]) -> Void
        // We can't access private methods via reflection in Swift. Instead, refactor to internal or test via session(_:didReceiveMessage:)

        // So we simulate receiving a message:
        let message: [String: Any] = [
            "dataType": "communityUpdate",
            "communities": sampleData,
            "timestamp": Date().timeIntervalSince1970,
        ]

        watchConnectivity.session(
            watchConnectivity.session, didReceiveMessage: message)

        // Verify the state
        XCTAssertEqual(watchConnectivity.communities.count, 1)
        XCTAssertEqual(watchConnectivity.communities.first?.username, "UserA")
        XCTAssertNil(watchConnectivity.errorMessage)
    }

    func testParseAndStoreComments() {
        let commentJSON: [[String: Any]] = [
            [
                "id": "c1",
                "commentText": "Nice post!",
                "username": "UserB",
                "formattedDate": "2025-06-10",
                "userId": "user_b",
                "communityId": "1",
            ]
        ]

        let message: [String: Any] = [
            "dataType": "commentUpdate",
            "comments": commentJSON,
        ]

        watchConnectivity.session(
            watchConnectivity.session, didReceiveMessage: message)

        XCTAssertEqual(watchConnectivity.currentPostComments.count, 1)
        XCTAssertEqual(
            watchConnectivity.currentPostComments.first?.commentContent,
            "Nice post!")
        XCTAssertNil(watchConnectivity.commentsErrorMessage)
    }

    func testSessionActivationUpdatesState() {
        watchConnectivity.session(
            watchConnectivity.session, activationDidCompleteWith: .activated,
            error: nil)

        XCTAssertEqual(
            watchConnectivity.connectionStatusMessage,
            watchConnectivity.session.isReachable
                ? "Connected" : "iPhone Unreachable")
    }

    func testClearCurrentPostComments() {
        watchConnectivity.currentPostComments = [
            WatchCommentModel(
                id: "1",
                commentContent: "Test",
                username: "Tester",
                formattedDate: "2025-06-11",
                userId: "u1",
                communityId: "c1")
        ]
        watchConnectivity.commentsErrorMessage = "Some error"
        watchConnectivity.isLoadingComments = true

        watchConnectivity.clearCurrentPostComments()

        XCTAssertTrue(watchConnectivity.currentPostComments.isEmpty)
        XCTAssertNil(watchConnectivity.commentsErrorMessage)
        XCTAssertFalse(watchConnectivity.isLoadingComments)
    }
}
