//
//  CommunityViewModelTesting.swift
//  ALP_SlayvegaTests
//
//  Created by Monica Thebez on 11/06/25.
//

import XCTest

@testable import ALP_Slayvega

final class CommunityViewModelTesting: XCTestCase {

    var viewModel: CommunityViewModel!

    override func setUpWithError() throws {
        viewModel = CommunityViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testInitialState() throws {
        XCTAssertTrue(viewModel.communities.isEmpty)
        XCTAssertTrue(viewModel.userCommunities.isEmpty)
    }

    // MARK: - Communities Array Tests

    func testCommunitiesArrayIsInitiallyEmpty() {
        XCTAssertEqual(viewModel.communities.count, 0)
        XCTAssertTrue(viewModel.communities.isEmpty)
    }

    func testUserCommunitiesArrayIsInitiallyEmpty() {
        XCTAssertEqual(viewModel.userCommunities.count, 0)
        XCTAssertTrue(viewModel.userCommunities.isEmpty)
    }

    // MARK: - Clear Local Data Tests

    func testClearLocalDataRemovesAllCommunities() {
        // Setup: Add some mock communities
        let mockCommunity1 = CommunityModel(
            id: "test-id-1",
            username: "testuser1",
            communityContent: "Test content 1",
            hashtags: "#test1",
            communityLikeCount: 5,
            communityDates: Date(),
            userId: "user123"
        )

        let mockCommunity2 = CommunityModel(
            id: "test-id-2",
            username: "testuser2",
            communityContent: "Test content 2",
            hashtags: "#test2",
            communityLikeCount: 10,
            communityDates: Date(),
            userId: "user456"
        )

        viewModel.communities = [mockCommunity1, mockCommunity2]
        viewModel.userCommunities = [mockCommunity1]

        XCTAssertEqual(viewModel.communities.count, 2)
        XCTAssertEqual(viewModel.userCommunities.count, 1)

        viewModel.clearLocalData()

        XCTAssertTrue(viewModel.communities.isEmpty)
        XCTAssertTrue(viewModel.userCommunities.isEmpty)
    }

    // MARK: - Community Model Tests

    func testCommunityModelPropertiesAreCorrectlySet() {
        let testDate = Date()
        let community = CommunityModel(
            id: "community123",
            username: "testuser",
            communityContent: "This is a test community post",
            hashtags: "#test #community #swift",
            communityLikeCount: 25,
            communityDates: testDate,
            userId: "user789"
        )

        XCTAssertEqual(community.id, "community123")
        XCTAssertEqual(community.username, "testuser")
        XCTAssertEqual(
            community.communityContent, "This is a test community post")
        XCTAssertEqual(community.hashtags, "#test #community #swift")
        XCTAssertEqual(community.communityLikeCount, 25)
        XCTAssertEqual(community.communityDates, testDate)
        XCTAssertEqual(community.userId, "user789")
    }

    // MARK: - Array Manipulation Tests

    func testCommunitiesArrayCanBeManuallyPopulated() {
        let community1 = CommunityModel(
            id: "1",
            username: "user1",
            communityContent: "First post",
            hashtags: "#first",
            communityLikeCount: 1,
            communityDates: Date(),
            userId: "uid1"
        )

        let community2 = CommunityModel(
            id: "2",
            username: "user2",
            communityContent: "Second post",
            hashtags: "#second",
            communityLikeCount: 2,
            communityDates: Date(),
            userId: "uid2"
        )

        viewModel.communities = [community1, community2]

        XCTAssertEqual(viewModel.communities.count, 2)
        XCTAssertEqual(viewModel.communities[0].id, "1")
        XCTAssertEqual(viewModel.communities[1].id, "2")
        XCTAssertEqual(viewModel.communities[0].communityContent, "First post")
        XCTAssertEqual(viewModel.communities[1].communityContent, "Second post")
    }

    func testUserCommunitiesArrayCanBeManuallyPopulated() {
        let userCommunity1 = CommunityModel(
            id: "user1",
            username: "currentuser",
            communityContent: "My first post",
            hashtags: "#myfirst",
            communityLikeCount: 5,
            communityDates: Date(),
            userId: "currentUserId"
        )

        let userCommunity2 = CommunityModel(
            id: "user2",
            username: "currentuser",
            communityContent: "My second post",
            hashtags: "#mysecond",
            communityLikeCount: 8,
            communityDates: Date(),
            userId: "currentUserId"
        )

        viewModel.userCommunities = [userCommunity1, userCommunity2]

        XCTAssertEqual(viewModel.userCommunities.count, 2)
        XCTAssertEqual(viewModel.userCommunities[0].id, "user1")
        XCTAssertEqual(viewModel.userCommunities[1].id, "user2")
        XCTAssertEqual(viewModel.userCommunities[0].username, "currentuser")
        XCTAssertEqual(viewModel.userCommunities[1].username, "currentuser")
    }

    // MARK: - Community Sorting Tests

    func testCommunitiesSortingByDate() {
        let olderDate = Date(timeIntervalSinceNow: -7200)  // 2 hours ago
        let newerDate = Date(timeIntervalSinceNow: -3600)  // 1 hour ago

        let olderCommunity = CommunityModel(
            id: "old",
            username: "user1",
            communityContent: "Older post",
            hashtags: "#old",
            communityLikeCount: 1,
            communityDates: olderDate,
            userId: "uid1"
        )

        let newerCommunity = CommunityModel(
            id: "new",
            username: "user2",
            communityContent: "Newer post",
            hashtags: "#new",
            communityLikeCount: 2,
            communityDates: newerDate,
            userId: "uid2"
        )

        viewModel.communities = [olderCommunity, newerCommunity]

        // Sort by date (newest first)
        viewModel.communities = viewModel.communities.sorted {
            $0.communityDates > $1.communityDates
        }

        XCTAssertEqual(viewModel.communities[0].id, "new")  // Newer post should be first
        XCTAssertEqual(viewModel.communities[1].id, "old")  // Older post should be second
    }

    // MARK: - Like Count Tests

    func testCommunityLikeCountHandling() {
        let communityWithLikes = CommunityModel(
            id: "liked-post",
            username: "popularuser",
            communityContent: "Popular post",
            hashtags: "#popular",
            communityLikeCount: 100,
            communityDates: Date(),
            userId: "popularUserId"
        )

        let communityWithoutLikes = CommunityModel(
            id: "new-post",
            username: "newuser",
            communityContent: "New post",
            hashtags: "#new",
            communityLikeCount: 0,
            communityDates: Date(),
            userId: "newUserId"
        )

        viewModel.communities = [communityWithLikes, communityWithoutLikes]

        XCTAssertEqual(viewModel.communities[0].communityLikeCount, 100)
        XCTAssertEqual(viewModel.communities[1].communityLikeCount, 0)
    }

    // MARK: - Hashtag Tests

    func testHashtagHandling() {
        let communityWithHashtags = CommunityModel(
            id: "hashtag-post",
            username: "hashtaguser",
            communityContent: "Post with hashtags",
            hashtags: "#swift #ios #programming #mobile",
            communityLikeCount: 15,
            communityDates: Date(),
            userId: "hashtagUserId"
        )

        let communityWithoutHashtags = CommunityModel(
            id: "plain-post",
            username: "plainuser",
            communityContent: "Plain post",
            hashtags: "",
            communityLikeCount: 3,
            communityDates: Date(),
            userId: "plainUserId"
        )

        viewModel.communities = [
            communityWithHashtags, communityWithoutHashtags,
        ]

        XCTAssertEqual(
            viewModel.communities[0].hashtags,
            "#swift #ios #programming #mobile")
        XCTAssertEqual(viewModel.communities[1].hashtags, "")
        XCTAssertTrue(viewModel.communities[0].hashtags.contains("#swift"))
        XCTAssertTrue(viewModel.communities[0].hashtags.contains("#ios"))
    }

    // MARK: - Edge Cases Tests

    func testCommunitiesWithEmptyContent() {
        let emptyCommunity = CommunityModel(
            id: "",
            username: "",
            communityContent: "",
            hashtags: "",
            communityLikeCount: 0,
            communityDates: Date(),
            userId: ""
        )

        viewModel.communities = [emptyCommunity]

        XCTAssertEqual(viewModel.communities.count, 1)
        XCTAssertEqual(viewModel.communities[0].id, "")
        XCTAssertEqual(viewModel.communities[0].username, "")
        XCTAssertEqual(viewModel.communities[0].communityContent, "")
        XCTAssertEqual(viewModel.communities[0].hashtags, "")
    }

    func testCommunitiesWithSpecialCharacters() {
        let specialCommunity = CommunityModel(
            id: "special-123",
            username: "user_with-special.chars",
            communityContent:
                "Content with émojis 🎉 and spëcial characters! @#$%",
            hashtags: "#spëcial #émoji #test-hashtag",
            communityLikeCount: 42,
            communityDates: Date(),
            userId: "special_user_123"
        )

        viewModel.communities = [specialCommunity]

        XCTAssertEqual(
            viewModel.communities[0].username, "user_with-special.chars")
        XCTAssertTrue(viewModel.communities[0].communityContent.contains("🎉"))
        XCTAssertTrue(
            viewModel.communities[0].communityContent.contains("spëcial"))
        XCTAssertTrue(viewModel.communities[0].hashtags.contains("émoji"))
    }

    // MARK: - Array Operations Tests

    func testAddingCommunitiesToArray() {
        XCTAssertTrue(viewModel.communities.isEmpty)

        let community = CommunityModel(
            id: "new-community",
            username: "newuser",
            communityContent: "New community post",
            hashtags: "#new",
            communityLikeCount: 0,
            communityDates: Date(),
            userId: "newUserId"
        )

        viewModel.communities.append(community)

        XCTAssertEqual(viewModel.communities.count, 1)
        XCTAssertEqual(viewModel.communities[0].id, "new-community")
    }

    func testRemovingCommunitiesFromArray() {
        let community1 = CommunityModel(
            id: "community1",
            username: "user1",
            communityContent: "Content 1",
            hashtags: "#one",
            communityLikeCount: 1,
            communityDates: Date(),
            userId: "uid1"
        )

        let community2 = CommunityModel(
            id: "community2",
            username: "user2",
            communityContent: "Content 2",
            hashtags: "#two",
            communityLikeCount: 2,
            communityDates: Date(),
            userId: "uid2"
        )

        viewModel.communities = [community1, community2]
        XCTAssertEqual(viewModel.communities.count, 2)

        viewModel.communities.removeFirst()
        XCTAssertEqual(viewModel.communities.count, 1)
        XCTAssertEqual(viewModel.communities[0].id, "community2")
    }

    // MARK: - Date Handling Tests

    func testDateHandlingInCommunities() {
        let specificDate = Date(timeIntervalSince1970: 1_609_459_200)  // January 1, 2021

        let communityWithSpecificDate = CommunityModel(
            id: "date-test",
            username: "dateuser",
            communityContent: "Post with specific date",
            hashtags: "#date",
            communityLikeCount: 5,
            communityDates: specificDate,
            userId: "dateUserId"
        )

        viewModel.communities = [communityWithSpecificDate]

        XCTAssertEqual(viewModel.communities[0].communityDates, specificDate)
    }

    // MARK: - Performance Tests

    func testPerformanceOfClearLocalData() throws {
        var communities: [CommunityModel] = []
        var userCommunities: [CommunityModel] = []

        for i in 0..<1000 {
            let community = CommunityModel(
                id: "community\(i)",
                username: "user\(i)",
                communityContent: "Content \(i)",
                hashtags: "#tag\(i)",
                communityLikeCount: i,
                communityDates: Date(),
                userId: "uid\(i)"
            )
            communities.append(community)

            if i < 100 {
                userCommunities.append(community)
            }
        }

        viewModel.communities = communities
        viewModel.userCommunities = userCommunities

        // Measure performance
        self.measure {
            viewModel.clearLocalData()
            // Reset for next iteration
            viewModel.communities = communities
            viewModel.userCommunities = userCommunities
        }
    }

    // MARK: - State Consistency Tests

    func testStateConsistencyAfterMultipleOperations() {
        // Initial state
        XCTAssertTrue(viewModel.communities.isEmpty)
        XCTAssertTrue(viewModel.userCommunities.isEmpty)

        // Add some data
        let community1 = CommunityModel(
            id: "test1",
            username: "testuser1",
            communityContent: "Test content 1",
            hashtags: "#test1",
            communityLikeCount: 5,
            communityDates: Date(),
            userId: "user123"
        )

        let community2 = CommunityModel(
            id: "test2",
            username: "testuser2",
            communityContent: "Test content 2",
            hashtags: "#test2",
            communityLikeCount: 10,
            communityDates: Date(),
            userId: "user456"
        )

        viewModel.communities = [community1, community2]
        viewModel.userCommunities = [community1]

        // Verify data was added
        XCTAssertEqual(viewModel.communities.count, 2)
        XCTAssertEqual(viewModel.userCommunities.count, 1)

        // Clear and verify
        viewModel.clearLocalData()

        XCTAssertTrue(viewModel.communities.isEmpty)
        XCTAssertTrue(viewModel.userCommunities.isEmpty)
    }

    // MARK: - User ID Tests

    func testUserCommunitiesFilteringLogic() {
        let currentUserId = "current-user-123"
        let otherUserId = "other-user-456"

        let currentUserCommunity = CommunityModel(
            id: "current-post",
            username: "currentuser",
            communityContent: "My post",
            hashtags: "#mine",
            communityLikeCount: 3,
            communityDates: Date(),
            userId: currentUserId
        )

        let otherUserCommunity = CommunityModel(
            id: "other-post",
            username: "otheruser",
            communityContent: "Other post",
            hashtags: "#other",
            communityLikeCount: 7,
            communityDates: Date(),
            userId: otherUserId
        )

        let allCommunities = [currentUserCommunity, otherUserCommunity]
        let filteredUserCommunities = allCommunities.filter {
            $0.userId == currentUserId
        }

        viewModel.communities = allCommunities
        viewModel.userCommunities = filteredUserCommunities

        XCTAssertEqual(viewModel.communities.count, 2)
        XCTAssertEqual(viewModel.userCommunities.count, 1)
        XCTAssertEqual(viewModel.userCommunities[0].userId, currentUserId)
        XCTAssertEqual(viewModel.userCommunities[0].id, "current-post")
    }
}
