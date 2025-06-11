//
//  CommentViewModelTesting.swift
//  ALP_SlayvegaTests
//
//  Created by Monica Thebez on 11/06/25.
//

import XCTest

@testable import ALP_Slayvega

final class CommentViewModelTesting: XCTestCase {

    var viewModel: CommentViewModel!

    override func setUpWithError() throws {
        viewModel = CommentViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    func testInitialState() throws {
        XCTAssertTrue(viewModel.comments.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.userLikes.isEmpty)
    }

    // MARK: - Comment Management Tests

    func testCommentsArrayIsInitiallyEmpty() {
        XCTAssertEqual(viewModel.comments.count, 0)
        XCTAssertTrue(viewModel.comments.isEmpty)
    }

    func testUserLikesArrayIsInitiallyEmpty() {
        XCTAssertEqual(viewModel.userLikes.count, 0)
        XCTAssertTrue(viewModel.userLikes.isEmpty)
    }

    func testIsLoadingInitiallyFalse() {
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Comment Like Status Tests

    func testIsCommentLikedByUserReturnsFalseForUnlikedComment() {
        let commentId = "test-comment-id"
        let isLiked = viewModel.isCommentLikedByUser(commentId: commentId)
        XCTAssertFalse(isLiked)
    }

    func testIsCommentLikedByUserReturnsTrueForLikedComment() {
        let commentId = "test-comment-id"
        viewModel.userLikes[commentId] = true

        let isLiked = viewModel.isCommentLikedByUser(commentId: commentId)
        XCTAssertTrue(isLiked)
    }

    func testIsCommentLikedByUserReturnsFalseForExplicitlyUnlikedComment() {
        let commentId = "test-comment-id"
        viewModel.userLikes[commentId] = false

        let isLiked = viewModel.isCommentLikedByUser(commentId: commentId)
        XCTAssertFalse(isLiked)
    }

    // MARK: - Clear Comments Tests

    func testClearCommentsRemovesAllComments() {
        let mockComment = CommentModel(
            CommentId: "test-id",
            Username: "testuser",
            CommentContent: "Test content",
            CommentLikeCount: 5,
            CommentDates: Date(),
            userId: "user123",
            CommunityId: "community123"
        )

        viewModel.comments = [mockComment]
        viewModel.userLikes["test-id"] = true

        XCTAssertEqual(viewModel.comments.count, 1)
        XCTAssertEqual(viewModel.userLikes.count, 1)

        // Execute
        viewModel.clearComments()

        // Verify
        XCTAssertTrue(viewModel.comments.isEmpty)
        XCTAssertTrue(viewModel.userLikes.isEmpty)
    }

    // MARK: - Comment Data Validation Tests

    func testCommentModelPropertiesAreCorrectlySet() {
        let testDate = Date()
        let comment = CommentModel(
            CommentId: "comment123",
            Username: "testuser",
            CommentContent: "This is a test comment",
            CommentLikeCount: 10,
            CommentDates: testDate,
            userId: "user456",
            CommunityId: "community789"
        )

        XCTAssertEqual(comment.CommentId, "comment123")
        XCTAssertEqual(comment.Username, "testuser")
        XCTAssertEqual(comment.CommentContent, "This is a test comment")
        XCTAssertEqual(comment.CommentLikeCount, 10)
        XCTAssertEqual(comment.CommentDates, testDate)
        XCTAssertEqual(comment.userId, "user456")
        XCTAssertEqual(comment.CommunityId, "community789")
    }

    // MARK: - Array State Management Tests

    func testCommentsArrayCanBeManuallyPopulated() {
        let comment1 = CommentModel(
            CommentId: "1",
            Username: "user1",
            CommentContent: "First comment",
            CommentLikeCount: 1,
            CommentDates: Date(),
            userId: "uid1",
            CommunityId: "comm1"
        )

        let comment2 = CommentModel(
            CommentId: "2",
            Username: "user2",
            CommentContent: "Second comment",
            CommentLikeCount: 2,
            CommentDates: Date(),
            userId: "uid2",
            CommunityId: "comm1"
        )

        viewModel.comments = [comment1, comment2]

        XCTAssertEqual(viewModel.comments.count, 2)
        XCTAssertEqual(viewModel.comments[0].CommentId, "1")
        XCTAssertEqual(viewModel.comments[1].CommentId, "2")
    }

    func testUserLikesCanBeManuallySet() {
        viewModel.userLikes["comment1"] = true
        viewModel.userLikes["comment2"] = false
        viewModel.userLikes["comment3"] = true

        XCTAssertEqual(viewModel.userLikes.count, 3)
        XCTAssertTrue(viewModel.userLikes["comment1"] ?? false)
        XCTAssertFalse(viewModel.userLikes["comment2"] ?? true)
        XCTAssertTrue(viewModel.userLikes["comment3"] ?? false)
    }

    // MARK: - Loading State Tests

    func testIsLoadingCanBeSetToTrue() {
        viewModel.isLoading = true
        XCTAssertTrue(viewModel.isLoading)
    }

    func testIsLoadingCanBeSetToFalse() {
        viewModel.isLoading = true
        viewModel.isLoading = false
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Comment Sorting Tests (Simulated)

    func testCommentsSortingByDate() {
        let olderDate = Date(timeIntervalSinceNow: -3600)  // 1 hour ago
        let newerDate = Date(timeIntervalSinceNow: -1800)  // 30 minutes ago

        let olderComment = CommentModel(
            CommentId: "old",
            Username: "user1",
            CommentContent: "Older comment",
            CommentLikeCount: 1,
            CommentDates: olderDate,
            userId: "uid1",
            CommunityId: "comm1"
        )

        let newerComment = CommentModel(
            CommentId: "new",
            Username: "user2",
            CommentContent: "Newer comment",
            CommentLikeCount: 2,
            CommentDates: newerDate,
            userId: "uid2",
            CommunityId: "comm1"
        )

        viewModel.comments = [olderComment, newerComment]

        viewModel.comments = viewModel.comments.sorted {
            $0.CommentDates > $1.CommentDates
        }

        XCTAssertEqual(viewModel.comments[0].CommentId, "new")
        XCTAssertEqual(viewModel.comments[1].CommentId, "old")
    }

    // MARK: - Edge Cases Tests

    func testIsCommentLikedByUserHandlesNonExistentCommentId() {
        let nonExistentId = "non-existent-comment-id-12345"
        let isLiked = viewModel.isCommentLikedByUser(commentId: nonExistentId)
        XCTAssertFalse(isLiked)
    }

    func testCommentsArrayCanHandleEmptyStrings() {
        let commentWithEmptyContent = CommentModel(
            CommentId: "",
            Username: "",
            CommentContent: "",
            CommentLikeCount: 0,
            CommentDates: Date(),
            userId: "",
            CommunityId: ""
        )

        viewModel.comments = [commentWithEmptyContent]

        XCTAssertEqual(viewModel.comments.count, 1)
        XCTAssertEqual(viewModel.comments[0].CommentContent, "")
        XCTAssertEqual(viewModel.comments[0].Username, "")
    }

    // MARK: - Performance Tests

    func testPerformanceOfClearComments() throws {
        var comments: [CommentModel] = []
        var likes: [String: Bool] = [:]

        for i in 0..<1000 {
            let comment = CommentModel(
                CommentId: "comment\(i)",
                Username: "user\(i)",
                CommentContent: "Content \(i)",
                CommentLikeCount: i,
                CommentDates: Date(),
                userId: "uid\(i)",
                CommunityId: "comm1"
            )
            comments.append(comment)
            likes["comment\(i)"] = i % 2 == 0
        }

        viewModel.comments = comments
        viewModel.userLikes = likes

        self.measure {
            viewModel.clearComments()
            viewModel.comments = comments
            viewModel.userLikes = likes
        }
    }

    // MARK: - State Consistency Tests

    func testStateConsistencyAfterMultipleOperations() {
        XCTAssertTrue(viewModel.comments.isEmpty)
        XCTAssertTrue(viewModel.userLikes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)

        let comment = CommentModel(
            CommentId: "test123",
            Username: "testuser",
            CommentContent: "Test content",
            CommentLikeCount: 5,
            CommentDates: Date(),
            userId: "user123",
            CommunityId: "community123"
        )

        viewModel.comments = [comment]
        viewModel.userLikes["test123"] = true
        viewModel.isLoading = true

        XCTAssertEqual(viewModel.comments.count, 1)
        XCTAssertEqual(viewModel.userLikes.count, 1)
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertTrue(viewModel.isCommentLikedByUser(commentId: "test123"))

        viewModel.clearComments()
        viewModel.isLoading = false

        XCTAssertTrue(viewModel.comments.isEmpty)
        XCTAssertTrue(viewModel.userLikes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isCommentLikedByUser(commentId: "test123"))
    }
}
