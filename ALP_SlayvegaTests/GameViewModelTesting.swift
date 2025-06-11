//
//  GameViewModelTesting.swift
//  ALP_SlayvegaTests
//
//  Created by Monica Thebez on 11/06/25.
//

import Combine
import XCTest

@testable import ALP_Slayvega

final class GameViewModelTesting: XCTestCase {

    var viewModel: GameViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        viewModel = GameViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
    }

    func testInitialState() throws {
        XCTAssertEqual(viewModel.currentPhase, .inhale)
        XCTAssertEqual(viewModel.timeRemaining, 4)
        XCTAssertEqual(viewModel.currentSet, 1)
        XCTAssertEqual(viewModel.totalSets, 3)
        XCTAssertFalse(viewModel.isActive)
        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertEqual(viewModel.breathingProgress, 0.0)
        XCTAssertFalse(viewModel.showAffirmation)
        XCTAssertEqual(viewModel.cloudOpacity, 0.8)
        XCTAssertFalse(viewModel.pressureMessages.isEmpty)
        XCTAssertTrue(viewModel.affirmationText.isEmpty)
    }

    func testGameStateInitialization() {
        XCTAssertNotNil(viewModel.gameState)
        XCTAssertNil(viewModel.gameState.gameStartTime)
        XCTAssertEqual(viewModel.gameState.progress, 0.0)
        XCTAssertTrue(viewModel.gameState.activePressures.isEmpty)
        XCTAssertTrue(viewModel.gameState.positiveElements.isEmpty)
        XCTAssertFalse(viewModel.gameState.showReflection)
        XCTAssertEqual(viewModel.gameState.reflectionScale, 1.0)
    }

    // MARK: - Game Control Tests

    func testStartGame() {
        viewModel.startGame()

        XCTAssertNotNil(viewModel.gameState.gameStartTime)
        XCTAssertFalse(viewModel.gameState.backgroundColors.isEmpty)
        XCTAssertEqual(viewModel.gameState.backgroundColors.count, 2)
    }

    func testResetGame() {
        // First start a game
        viewModel.startGame()
        let originalStartTime = viewModel.gameState.gameStartTime

        // Then reset
        viewModel.resetGame()

        XCTAssertNotEqual(viewModel.gameState.gameStartTime, originalStartTime)
        XCTAssertNotNil(viewModel.gameState.gameStartTime)
        XCTAssertEqual(viewModel.gameState.progress, 0.0)
    }

    func testEndGame() {
        viewModel.endGame()

        XCTAssertTrue(viewModel.gameState.showReflection)
        XCTAssertFalse(viewModel.gameState.currentReflection.isEmpty)
        XCTAssertFalse(viewModel.gameState.backgroundColors.isEmpty)
    }

    // MARK: - Breathing Control Tests

    func testStartBreathing() {
        viewModel.startBreathing()

        XCTAssertTrue(viewModel.isActive)
        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertEqual(viewModel.currentSet, 1)
        XCTAssertEqual(viewModel.currentPhase, .inhale)
        XCTAssertEqual(viewModel.timeRemaining, Int(Breathing.inhale.duration))
        XCTAssertEqual(viewModel.breathingProgress, 0.0)
        XCTAssertFalse(viewModel.showAffirmation)
        XCTAssertEqual(viewModel.cloudOpacity, 0.8)
    }

    func testStartBreathingWhenAlreadyActive() {
        viewModel.startBreathing()
        let originalSet = viewModel.currentSet

        // Try to start again while already active
        viewModel.startBreathing()

        // Should remain the same
        XCTAssertEqual(viewModel.currentSet, originalSet)
        XCTAssertTrue(viewModel.isActive)
    }

    func testPauseBreathing() {
        viewModel.startBreathing()
        XCTAssertTrue(viewModel.isActive)

        viewModel.pauseBreathing()
        XCTAssertFalse(viewModel.isActive)
    }

    func testResetBreathing() {
        viewModel.startBreathing()
        viewModel.currentSet = 2
        viewModel.currentPhase = .exhale

        viewModel.resetBreathing()

        XCTAssertFalse(viewModel.isActive)
        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertEqual(viewModel.currentSet, 1)
        XCTAssertEqual(viewModel.currentPhase, .inhale)
        XCTAssertEqual(viewModel.timeRemaining, Int(Breathing.inhale.duration))
        XCTAssertEqual(viewModel.breathingProgress, 0.0)
        XCTAssertFalse(viewModel.showAffirmation)
        XCTAssertEqual(viewModel.cloudOpacity, 0.8)
    }

    // MARK: - Reflection Tests

    func testStartReflectionAnimation() {
        viewModel.startReflectionAnimation()
        XCTAssertEqual(viewModel.gameState.reflectionScale, 1.2)
    }

    // MARK: - Pressure Management Tests

    func testPressureMessagesInitialization() {
        XCTAssertFalse(viewModel.pressureMessages.isEmpty)
        XCTAssertEqual(viewModel.pressureMessages.count, 8)  // Based on pressureTexts array length

        for message in viewModel.pressureMessages {
            XCTAssertFalse(message.text.isEmpty)
            XCTAssertGreaterThanOrEqual(message.opacity, 0.3)
            XCTAssertLessThanOrEqual(message.opacity, 0.7)
        }
    }

    // MARK: - Property Observer Tests

    func testPublishedPropertiesAreObservable() {
        let expectation = XCTestExpectation(
            description: "Published property changed")

        viewModel.$isActive
            .dropFirst()
            .sink { isActive in
                XCTAssertTrue(isActive)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.startBreathing()

        wait(for: [expectation], timeout: 1.0)
    }

    func testCurrentPhasePropertyChange() {
        let expectation = XCTestExpectation(
            description: "Current phase changed")

        viewModel.$currentPhase
            .dropFirst()
            .sink { phase in
                // This will be called when phase changes
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.startBreathing()

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Game State Integration Tests

    func testGameStateProgressUpdates() {
        let initialProgress = viewModel.gameState.progress
        XCTAssertEqual(initialProgress, 0.0)

        // Manually set start time to test progress calculation
        viewModel.gameState.gameStartTime = Date().addingTimeInterval(-30)  // 30 seconds ago

        // The actual progress update happens in private methods,
        // so we test the initial state and structure
        XCTAssertEqual(viewModel.gameState.progress, 0.0)
    }

    func testGameStatePressureManagement() {
        let initialCount = viewModel.gameState.activePressures.count
        XCTAssertEqual(initialCount, 0)

        // Test that the structure is ready for pressure management
        XCTAssertNotNil(viewModel.gameState.activePressures)
        XCTAssertTrue(viewModel.gameState.activePressures.isEmpty)
    }

    func testGameStatePositiveElements() {
        XCTAssertTrue(viewModel.gameState.positiveElements.isEmpty)
        XCTAssertNotNil(viewModel.gameState.positiveElements)
    }

    // MARK: - Background Color Tests

    func testInitialBackgroundColors() {
        viewModel.startGame()

        XCTAssertEqual(viewModel.gameState.backgroundColors.count, 2)
        XCTAssertNotNil(viewModel.gameState.backgroundColors.first)
        XCTAssertNotNil(viewModel.gameState.backgroundColors.last)
    }

    // MARK: - Timer Management Tests

    func testTimerStateAfterReset() {
        viewModel.startBreathing()
        XCTAssertTrue(viewModel.isActive)

        viewModel.resetBreathing()
        XCTAssertFalse(viewModel.isActive)
    }

    // MARK: - Edge Cases Tests

    func testMultipleStartBreathingCalls() {
        viewModel.startBreathing()
        let firstCallSet = viewModel.currentSet
        let firstCallPhase = viewModel.currentPhase

        // Call start again
        viewModel.startBreathing()

        // Should remain unchanged
        XCTAssertEqual(viewModel.currentSet, firstCallSet)
        XCTAssertEqual(viewModel.currentPhase, firstCallPhase)
    }

    func testResetAfterCompletion() {
        viewModel.startBreathing()
        viewModel.isCompleted = true

        viewModel.resetBreathing()

        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertFalse(viewModel.isActive)
        XCTAssertEqual(viewModel.currentSet, 1)
    }

    // MARK: - Memory Management Tests

    func testViewModelDeallocation() {
        weak var weakViewModel: GameViewModel?

        autoreleasepool {
            let testViewModel = GameViewModel()
            weakViewModel = testViewModel
            testViewModel.startBreathing()
            testViewModel.resetBreathing()
        }

        // Note: This test might not always pass due to timer references
        // It's more of a guidance for memory leak detection
        XCTAssertNil(
            weakViewModel,
            "GameViewModel should be deallocated when no strong references remain"
        )
    }

    // MARK: - State Consistency Tests

    func testStateConsistencyAfterOperations() {
        // Start breathing
        viewModel.startBreathing()
        XCTAssertTrue(viewModel.isActive)
        XCTAssertFalse(viewModel.isCompleted)

        // Pause
        viewModel.pauseBreathing()
        XCTAssertFalse(viewModel.isActive)
        XCTAssertFalse(viewModel.isCompleted)

        // Reset
        viewModel.resetBreathing()
        XCTAssertFalse(viewModel.isActive)
        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertEqual(viewModel.currentSet, 1)
        XCTAssertEqual(viewModel.currentPhase, .inhale)
    }

    func testGameAndBreathingStateIndependence() {
        // Start game
        viewModel.startGame()
        XCTAssertNotNil(viewModel.gameState.gameStartTime)

        // Start breathing
        viewModel.startBreathing()
        XCTAssertTrue(viewModel.isActive)

        // Reset breathing shouldn't affect game state
        viewModel.resetBreathing()
        XCTAssertNotNil(viewModel.gameState.gameStartTime)
        XCTAssertFalse(viewModel.isActive)
    }
}
