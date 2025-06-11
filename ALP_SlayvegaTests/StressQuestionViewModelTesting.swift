//
//  StressQuestionViewModelTesting.swift
//  ALP_SlayvegaTests
//
//  Created by Joy Luist on 04/06/25.
//

import XCTest

@testable import ALP_Slayvega

final class StressQuestionViewModelTesting: XCTestCase {

    var viewModel: StressQuestionViewModel!

    override func setUpWithError() throws {
        viewModel = StressQuestionViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testInitialState() throws {
        XCTAssertEqual(viewModel.currentQuestionIndex, 0)
        XCTAssertFalse(viewModel.shouldNavigateToResult)
        XCTAssertTrue(viewModel.answers.isEmpty)
        XCTAssertNotNil(viewModel.currentQuestion)
        XCTAssertEqual(viewModel.questions.count, 10)
    }

    func testSelectAnswerAdvancesQuestionIndex() {
        let firstQuestionID = viewModel.currentQuestion?.id
        viewModel.selectAnswer(3)

        let expectation = XCTestExpectation(
            description: "Wait for index update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(self.viewModel.answers[firstQuestionID!], 3)
            XCTAssertEqual(self.viewModel.currentQuestionIndex, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testCompletionPercentageCalculation() {
        let viewModel = StressQuestionViewModel()

        for _ in 0..<5 {
            if let question = viewModel.currentQuestion {
                viewModel.answers[question.id] = 2
                viewModel.currentQuestionIndex += 1
            }
        }

        XCTAssertEqual(viewModel.answers.count, 5)
        XCTAssertEqual(viewModel.completionPercentage, 0.5)
    }

    func testTotalAndAverageScoreCalculation() {
        for i in 0..<viewModel.questions.count {
            viewModel.answers[viewModel.questions[i].id] = 3
        }

        XCTAssertEqual(viewModel.totalScore, 30)
        XCTAssertEqual(viewModel.averageScore, 3.0)
        XCTAssertEqual(viewModel.stressLevel, "High Stress")
        XCTAssertEqual(viewModel.stressLevelBars, 3)
    }

    func testResetAssessmentClearsState() {
        viewModel.answers[viewModel.questions[0].id] = 4
        viewModel.currentQuestionIndex = 5
        viewModel.shouldNavigateToResult = true

        viewModel.resetAssessment()

        XCTAssertTrue(viewModel.answers.isEmpty)
        XCTAssertEqual(viewModel.currentQuestionIndex, 0)
        XCTAssertFalse(viewModel.shouldNavigateToResult)
    }

    func testCanGoBackAndGoBackFunction() {
        viewModel.currentQuestionIndex = 3
        XCTAssertTrue(viewModel.canGoBack())

        viewModel.goBack()
        XCTAssertEqual(viewModel.currentQuestionIndex, 2)

        viewModel.currentQuestionIndex = 0
        XCTAssertFalse(viewModel.canGoBack())
    }

    func testIsAnswerSelected() {
        let questionID = viewModel.currentQuestion!.id
        viewModel.answers[questionID] = 2
        XCTAssertTrue(viewModel.isAnswerSelected(2))
        XCTAssertFalse(viewModel.isAnswerSelected(3))
    }

}
