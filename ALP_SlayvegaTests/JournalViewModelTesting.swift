//
//  JournalViewModelTesting.swift
//  ALP_SlayvegaTests
//
//  Created by Monica Thebez on 11/06/25.
//

import XCTest

@testable import ALP_Slayvega

final class JournalViewModelTesting: XCTestCase {

    var viewModel: JournalViewModel!

    override func setUpWithError() throws {
        viewModel = JournalViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testInitialState() throws {
        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
        XCTAssertTrue(viewModel.journals.isEmpty)
    }

    func testAddJournal() {
        viewModel.journalTitle = "Test Journal Title"
        viewModel.journalDescription = "Test Journal Description"

        viewModel.addJournal()

        XCTAssertEqual(viewModel.journals.count, 1)
        XCTAssertEqual(viewModel.journals[0].journalTitle, "Test Journal Title")
        XCTAssertEqual(
            viewModel.journals[0].journalDescription, "Test Journal Description"
        )
        XCTAssertNotNil(viewModel.journals[0].journalDate)

        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
    }

    func testAddMultipleJournals() {
        viewModel.journalTitle = "First Journal"
        viewModel.journalDescription = "First Description"
        viewModel.addJournal()

        viewModel.journalTitle = "Second Journal"
        viewModel.journalDescription = "Second Description"
        viewModel.addJournal()

        XCTAssertEqual(viewModel.journals.count, 2)
        XCTAssertEqual(viewModel.journals[0].journalTitle, "First Journal")
        XCTAssertEqual(viewModel.journals[1].journalTitle, "Second Journal")
    }

    func testUpdateJournal() {
        viewModel.journalTitle = "Original Title"
        viewModel.journalDescription = "Original Description"
        viewModel.addJournal()

        let journalId = viewModel.journals[0].id
        let originalDate = viewModel.journals[0].journalDate

        viewModel.journalTitle = "Updated Title"
        viewModel.journalDescription = "Updated Description"
        viewModel.updateJournal(id: journalId)

        XCTAssertEqual(viewModel.journals.count, 1)
        XCTAssertEqual(viewModel.journals[0].journalTitle, "Updated Title")
        XCTAssertEqual(
            viewModel.journals[0].journalDescription, "Updated Description")
        XCTAssertGreaterThan(viewModel.journals[0].journalDate, originalDate)

        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
    }

    func testUpdateNonExistentJournal() {
        viewModel.journalTitle = "Test Journal"
        viewModel.journalDescription = "Test Description"
        viewModel.addJournal()

        let originalCount = viewModel.journals.count
        let originalTitle = viewModel.journals[0].journalTitle

        viewModel.journalTitle = "New Title"
        viewModel.journalDescription = "New Description"
        viewModel.updateJournal(id: "non-existent-id")

        XCTAssertEqual(viewModel.journals.count, originalCount)
        XCTAssertEqual(viewModel.journals[0].journalTitle, originalTitle)

        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
    }

    func testDeleteJournal() {
        viewModel.journalTitle = "First Journal"
        viewModel.journalDescription = "First Description"
        viewModel.addJournal()

        viewModel.journalTitle = "Second Journal"
        viewModel.journalDescription = "Second Description"
        viewModel.addJournal()

        let firstJournalId = viewModel.journals[0].id

        viewModel.deleteJournal(id: firstJournalId)

        XCTAssertEqual(viewModel.journals.count, 1)
        XCTAssertEqual(viewModel.journals[0].journalTitle, "Second Journal")
    }

    func testDeleteNonExistentJournal() {
        viewModel.journalTitle = "Test Journal"
        viewModel.journalDescription = "Test Description"
        viewModel.addJournal()

        let originalCount = viewModel.journals.count

        viewModel.deleteJournal(id: "non-existent-id")

        XCTAssertEqual(viewModel.journals.count, originalCount)
    }

    func testDeleteAllJournals() {
        for i in 1...3 {
            viewModel.journalTitle = "Journal \(i)"
            viewModel.journalDescription = "Description \(i)"
            viewModel.addJournal()
        }

        XCTAssertEqual(viewModel.journals.count, 3)

        let journalIds = viewModel.journals.map { $0.id }
        for id in journalIds {
            viewModel.deleteJournal(id: id)
        }

        XCTAssertTrue(viewModel.journals.isEmpty)
    }

    func testLoadJournalToEdit() {
        let sampleJournal = JournalModel(
            journalTitle: "Sample Title",
            journalDescription: "Sample Description",
            journalDate: Date()
        )

        viewModel.loadJournalToEdit(sampleJournal)

        XCTAssertEqual(viewModel.journalTitle, "Sample Title")
        XCTAssertEqual(viewModel.journalDescription, "Sample Description")
    }

    func testClearInput() {
        viewModel.journalTitle = "Test Title"
        viewModel.journalDescription = "Test Description"

        viewModel.clearInput()

        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
    }

    func testJournalIdUniqueness() {
        viewModel.journalTitle = "Journal 1"
        viewModel.journalDescription = "Description 1"
        viewModel.addJournal()

        viewModel.journalTitle = "Journal 2"
        viewModel.journalDescription = "Description 2"
        viewModel.addJournal()

        let id1 = viewModel.journals[0].id
        let id2 = viewModel.journals[1].id
        XCTAssertNotEqual(id1, id2)
    }

    func testJournalDateIsSetOnAdd() {
        let beforeAdd = Date()

        viewModel.journalTitle = "Test Journal"
        viewModel.journalDescription = "Test Description"
        viewModel.addJournal()

        let afterAdd = Date()
        let journalDate = viewModel.journals[0].journalDate

        XCTAssertGreaterThanOrEqual(journalDate, beforeAdd)
        XCTAssertLessThanOrEqual(journalDate, afterAdd)
    }

    func testJournalDateIsUpdatedOnEdit() {
        viewModel.journalTitle = "Original Title"
        viewModel.journalDescription = "Original Description"
        viewModel.addJournal()

        let originalDate = viewModel.journals[0].journalDate
        let journalId = viewModel.journals[0].id

        let expectation = XCTestExpectation(
            description: "Wait for time difference")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.journalTitle = "Updated Title"
            self.viewModel.journalDescription = "Updated Description"
            self.viewModel.updateJournal(id: journalId)

            XCTAssertGreaterThan(
                self.viewModel.journals[0].journalDate, originalDate)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
