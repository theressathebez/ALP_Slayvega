//
//  QuotesViewModelTesting.swift
//  ALP_SlayvegaTests
//
//  Created by Monica Thebez on 11/06/25.
//

import XCTest

@testable import ALP_Slayvega

final class QuotesViewModelTesting: XCTestCase {

    var viewModel: QuotesViewModel!

    override func setUpWithError() throws {
        viewModel = QuotesViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testInitialState() throws {
        XCTAssertFalse(viewModel.quotes.isEmpty, "Quotes should not be empty")
        XCTAssertEqual(viewModel.currentQuoteIndex, 0)
        XCTAssertNotNil(viewModel.currentQuote)
        XCTAssertNotNil(viewModel.getCurrentQuote())
    }

    func testGetNextQuoteIncrementsIndex() throws {
        let initialIndex = viewModel.currentQuoteIndex
        viewModel.getNextQuote()

        let expectation = XCTestExpectation(description: "Wait for animation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(
                self.viewModel.currentQuoteIndex,
                (initialIndex + 1) % self.viewModel.quotes.count)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetPreviousQuoteDecrementsIndex() throws {
        viewModel.currentQuoteIndex = 1
        viewModel.getPreviousQuote()

        let expectation = XCTestExpectation(description: "Wait for animation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(self.viewModel.currentQuoteIndex, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetRandomQuoteChangesCurrentQuote() throws {
        let originalQuote = viewModel.currentQuote
        viewModel.getRandomQuote()

        let expectation = XCTestExpectation(description: "Wait for animation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertNotNil(self.viewModel.currentQuote)
            XCTAssertNotEqual(self.viewModel.isAnimating, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testDailyProgressCalculation() throws {
        let (shown, total) = viewModel.getDailyProgress()
        XCTAssertGreaterThanOrEqual(total, 0)
        XCTAssertGreaterThanOrEqual(shown, 0)
        XCTAssertLessThanOrEqual(shown, total)
    }

    func testGetNextQuoteCountdown() throws {
        let countdown = viewModel.getNextQuoteCountdown()
        XCTAssertFalse(countdown.isEmpty)
    }

    func testFetchQuotesUpdatesState() async throws {
        await viewModel.fetchQuotes()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.currentQuote)
        XCTAssertFalse(viewModel.quotes.isEmpty)
    }
}
