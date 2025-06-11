//
//  DashboardViewModelTesting.swift
//  ALP_SlayvegaTests
//
//  Created by Monica Thebez on 11/06/25.
//

import XCTest

@testable import ALP_Slayvega

final class DashboardViewModelTesting: XCTestCase {

    var viewModel: DashboardViewModel!

    override func setUpWithError() throws {
        viewModel = DashboardViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testInitialState() throws {
        XCTAssertEqual(viewModel.currentStressLevel, 0)
        XCTAssertEqual(viewModel.weeklyAverage, 0.0)
        XCTAssertEqual(viewModel.weeklyRange.min, 0)
        XCTAssertEqual(viewModel.weeklyRange.max, 0)
        XCTAssertEqual(viewModel.stressCategory, "Low")
        XCTAssertTrue(viewModel.weeklyData.isEmpty)
        XCTAssertTrue(viewModel.isLoading)
    }

    // MARK: - Stress Distribution Tests

    func testStressDistributionWithEmptyData() {
        let distribution = viewModel.stressDistribution
        XCTAssertEqual(distribution.high, 0)
        XCTAssertEqual(distribution.medium, 0)
        XCTAssertEqual(distribution.normal, 0)
        XCTAssertEqual(distribution.low, 100)
    }

    func testStressDistributionWithMixedData() {
        // Create mock stress data with different levels
        let mockData = [
            createMockStressModel(level: 40),  // High (4.0)
            createMockStressModel(level: 35),  // High (3.5)
            createMockStressModel(level: 30),  // Medium (3.0)
            createMockStressModel(level: 25),  // Normal (2.5)
            createMockStressModel(level: 15),  // Low (1.5)
        ]

        viewModel.weeklyData = mockData
        let distribution = viewModel.stressDistribution

        XCTAssertEqual(distribution.high, 40)  // 2 out of 5 = 40%
        XCTAssertEqual(distribution.medium, 20)  // 1 out of 5 = 20%
        XCTAssertEqual(distribution.normal, 20)  // 1 out of 5 = 20%
        XCTAssertEqual(distribution.low, 20)  // 1 out of 5 = 20%
    }

    // MARK: - Stress Level Color Tests

    func testStressLevelColorForLowStress() {
        viewModel.currentStressLevel = 15  // 1.5 normalized
        XCTAssertEqual(viewModel.stressLevelColor, .stressLow)
    }

    func testStressLevelColorForNormalStress() {
        viewModel.currentStressLevel = 25  // 2.5 normalized
        XCTAssertEqual(viewModel.stressLevelColor, .stressNormal)
    }

    func testStressLevelColorForMediumStress() {
        viewModel.currentStressLevel = 30  // 3.0 normalized
        XCTAssertEqual(viewModel.stressLevelColor, .stressMedium)
    }

    func testStressLevelColorForHighStress() {
        viewModel.currentStressLevel = 40  // 4.0 normalized
        XCTAssertEqual(viewModel.stressLevelColor, .stressHigh)
    }

    // MARK: - Ring Progress Tests

    func testRingProgressCalculation() {
        viewModel.currentStressLevel = 20  // 2.0 normalized
        let expectedProgress = 2.0 / 4.0  // 0.5
        XCTAssertEqual(viewModel.ringProgress, expectedProgress, accuracy: 0.01)
    }

    func testRingProgressMaximumCap() {
        viewModel.currentStressLevel = 50  // 5.0 normalized (exceeds max)
        XCTAssertEqual(viewModel.ringProgress, 1.0)  // Should be capped at 1.0
    }

    func testRingProgressMinimum() {
        viewModel.currentStressLevel = 0
        XCTAssertEqual(viewModel.ringProgress, 0.0)
    }

    // MARK: - Weekly Stats Calculation Tests

    func testCalculateWeeklyStatsWithEmptyData() {
        viewModel.weeklyData = []
        viewModel.calculateWeeklyStats()

        XCTAssertEqual(viewModel.weeklyAverage, 0.0)
        XCTAssertEqual(viewModel.weeklyRange.min, 0)
        XCTAssertEqual(viewModel.weeklyRange.max, 0)
    }

    func testCalculateWeeklyStatsWithValidData() {
        let mockData = [
            createMockStressModel(level: 10),  // 1.0 normalized
            createMockStressModel(level: 20),  // 2.0 normalized
            createMockStressModel(level: 30),  // 3.0 normalized
            createMockStressModel(level: 40),  // 4.0 normalized
        ]

        viewModel.weeklyData = mockData
        viewModel.calculateWeeklyStats()

        let expectedAverage = (1.0 + 2.0 + 3.0 + 4.0) / 4.0  // 2.5
        XCTAssertEqual(viewModel.weeklyAverage, expectedAverage, accuracy: 0.01)
        XCTAssertEqual(viewModel.weeklyRange.min, 10)
        XCTAssertEqual(viewModel.weeklyRange.max, 40)
    }

    // MARK: - Stress Category Tests

    func testGetStressCategoryLow() {
        let category = viewModel.getStressCategory(from: 1.5)
        XCTAssertEqual(category, "Low")
    }

    func testGetStressCategoryNormal() {
        let category = viewModel.getStressCategory(from: 2.5)
        XCTAssertEqual(category, "Normal")
    }

    func testGetStressCategoryMedium() {
        let category = viewModel.getStressCategory(from: 3.0)
        XCTAssertEqual(category, "Medium")
    }

    func testGetStressCategoryHigh() {
        let category = viewModel.getStressCategory(from: 3.8)
        XCTAssertEqual(category, "High")
    }

    func testGetStressCategoryBoundaryValues() {
        XCTAssertEqual(viewModel.getStressCategory(from: 2.0), "Normal")
        XCTAssertEqual(viewModel.getStressCategory(from: 2.8), "Medium")
        XCTAssertEqual(viewModel.getStressCategory(from: 3.5), "High")
    }

    // MARK: - Formatted Weekly Average Tests

    func testFormattedWeeklyAverageWithZeroAverage() {
        viewModel.weeklyAverage = 0.0
        XCTAssertEqual(viewModel.formattedWeeklyAverage, "0 Low")
    }

    func testFormattedWeeklyAverageWithValidAverage() {
        viewModel.weeklyAverage = 2.5
        XCTAssertEqual(viewModel.formattedWeeklyAverage, "25 Normal")
    }

    func testFormattedWeeklyAverageWithHighAverage() {
        viewModel.weeklyAverage = 3.8
        XCTAssertEqual(viewModel.formattedWeeklyAverage, "38 High")
    }

    // MARK: - Weekly Data Filtering Tests

    func testGetWeeklyStressDataFiltering() {
        let currentTime = Date().timeIntervalSince1970
        let oneWeekAgo = currentTime - (7 * 24 * 60 * 60)
        let twoWeeksAgo = currentTime - (14 * 24 * 60 * 60)

        let mockHistory = [
            createMockStressModelWithTimestamp(
                level: 10, timestamp: Int(currentTime - 1000)),  // Within week
            createMockStressModelWithTimestamp(
                level: 20, timestamp: Int(oneWeekAgo + 1000)),  // Within week
            createMockStressModelWithTimestamp(
                level: 30, timestamp: Int(twoWeeksAgo)),  // Outside week
        ]

        let weeklyData = viewModel.getWeeklyStressData(from: mockHistory)
        XCTAssertEqual(weeklyData.count, 2)  // Only 2 should be within the week
    }

    func testGetWeeklyStressDataWithMissingTimestamps() {
        let mockHistory = [
            createMockStressModel(level: 10),  // No timestamp
            createMockStressModelWithTimestamp(
                level: 20, timestamp: Int(Date().timeIntervalSince1970)),
        ]

        let weeklyData = viewModel.getWeeklyStressData(from: mockHistory)
        XCTAssertEqual(weeklyData.count, 1)  // Only the one with timestamp should be included
    }

    // MARK: - Load Stress Data Tests

    func testLoadStressDataWithEmptyUserId() {
        let initialLoadingState = viewModel.isLoading
        viewModel.loadStressData(for: "")
        // Should not change loading state for empty userId
        XCTAssertEqual(viewModel.isLoading, initialLoadingState)
    }

    func testLoadStressDataWithValidUserId() {
        viewModel.isLoading = false
        viewModel.loadStressData(for: "validUserId")
        XCTAssertTrue(viewModel.isLoading)  // Should set loading to true
    }

    // MARK: - Helper Methods

    private func createMockStressModel(level: Int) -> StressModel {
        var mockModel = StressModel()
        mockModel.StressLevel = level
        mockModel.timestamp = Int(Date().timeIntervalSince1970)
        return mockModel
    }

    private func createMockStressModelWithTimestamp(level: Int, timestamp: Int)
        -> StressModel
    {
        var mockModel = StressModel()
        mockModel.StressLevel = level
        mockModel.timestamp = nil
        return mockModel
    }

    // MARK: - Performance Tests

    func testStressDistributionPerformance() throws {
        // Create large dataset
        var largeDataset: [StressModel] = []
        for i in 0..<1000 {
            largeDataset.append(createMockStressModel(level: i % 40 + 1))
        }

        viewModel.weeklyData = largeDataset

        self.measure {
            _ = viewModel.stressDistribution
        }
    }

    func testWeeklyStatsCalculationPerformance() throws {
        // Create large dataset
        var largeDataset: [StressModel] = []
        for i in 0..<1000 {
            largeDataset.append(createMockStressModel(level: i % 40 + 1))
        }

        viewModel.weeklyData = largeDataset

        self.measure {
            viewModel.calculateWeeklyStats()
        }
    }
}
