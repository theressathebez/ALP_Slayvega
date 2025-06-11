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
        // Setup test data
        viewModel.journalTitle = "Test Journal Title"
        viewModel.journalDescription = "Test Journal Description"

        // Add journal
        viewModel.addJournal()

        // Verify journal was added
        XCTAssertEqual(viewModel.journals.count, 1)
        XCTAssertEqual(viewModel.journals[0].journalTitle, "Test Journal Title")
        XCTAssertEqual(
            viewModel.journals[0].journalDescription, "Test Journal Description"
        )
        XCTAssertNotNil(viewModel.journals[0].journalDate)

        // Verify input fields are cleared after adding
        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
    }

    func testAddMultipleJournals() {
        // Add first journal
        viewModel.journalTitle = "First Journal"
        viewModel.journalDescription = "First Description"
        viewModel.addJournal()

        // Add second journal
        viewModel.journalTitle = "Second Journal"
        viewModel.journalDescription = "Second Description"
        viewModel.addJournal()

        // Verify both journals exist
        XCTAssertEqual(viewModel.journals.count, 2)
        XCTAssertEqual(viewModel.journals[0].journalTitle, "First Journal")
        XCTAssertEqual(viewModel.journals[1].journalTitle, "Second Journal")
    }

    func testUpdateJournal() {
        // First add a journal
        viewModel.journalTitle = "Original Title"
        viewModel.journalDescription = "Original Description"
        viewModel.addJournal()

        let journalId = viewModel.journals[0].id
        let originalDate = viewModel.journals[0].journalDate

        // Update the journal
        viewModel.journalTitle = "Updated Title"
        viewModel.journalDescription = "Updated Description"
        viewModel.updateJournal(id: journalId)

        // Verify journal was updated
        XCTAssertEqual(viewModel.journals.count, 1)
        XCTAssertEqual(viewModel.journals[0].journalTitle, "Updated Title")
        XCTAssertEqual(
            viewModel.journals[0].journalDescription, "Updated Description")
        XCTAssertGreaterThan(viewModel.journals[0].journalDate, originalDate)

        // Verify input fields are cleared after updating
        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
    }

    func testUpdateNonExistentJournal() {
        // Add a journal
        viewModel.journalTitle = "Test Journal"
        viewModel.journalDescription = "Test Description"
        viewModel.addJournal()

        let originalCount = viewModel.journals.count
        let originalTitle = viewModel.journals[0].journalTitle

        // Try to update with non-existent ID
        viewModel.journalTitle = "New Title"
        viewModel.journalDescription = "New Description"
        viewModel.updateJournal(id: "non-existent-id")

        // Verify nothing changed
        XCTAssertEqual(viewModel.journals.count, originalCount)
        XCTAssertEqual(viewModel.journals[0].journalTitle, originalTitle)

        // Input should still be cleared even if update fails
        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
    }

    func testDeleteJournal() {
        // Add two journals
        viewModel.journalTitle = "First Journal"
        viewModel.journalDescription = "First Description"
        viewModel.addJournal()

        viewModel.journalTitle = "Second Journal"
        viewModel.journalDescription = "Second Description"
        viewModel.addJournal()

        let firstJournalId = viewModel.journals[0].id

        // Delete first journal
        viewModel.deleteJournal(id: firstJournalId)

        // Verify journal was deleted
        XCTAssertEqual(viewModel.journals.count, 1)
        XCTAssertEqual(viewModel.journals[0].journalTitle, "Second Journal")
    }

    func testDeleteNonExistentJournal() {
        // Add a journal
        viewModel.journalTitle = "Test Journal"
        viewModel.journalDescription = "Test Description"
        viewModel.addJournal()

        let originalCount = viewModel.journals.count

        // Try to delete with non-existent ID
        viewModel.deleteJournal(id: "non-existent-id")

        // Verify nothing was deleted
        XCTAssertEqual(viewModel.journals.count, originalCount)
    }

    func testDeleteAllJournals() {
        // Add multiple journals
        for i in 1...3 {
            viewModel.journalTitle = "Journal \(i)"
            viewModel.journalDescription = "Description \(i)"
            viewModel.addJournal()
        }

        XCTAssertEqual(viewModel.journals.count, 3)

        // Delete all journals
        let journalIds = viewModel.journals.map { $0.id }
        for id in journalIds {
            viewModel.deleteJournal(id: id)
        }

        // Verify all journals are deleted
        XCTAssertTrue(viewModel.journals.isEmpty)
    }

    func testLoadJournalToEdit() {
        // Create a sample journal
        let sampleJournal = JournalModel(
            journalTitle: "Sample Title",
            journalDescription: "Sample Description",
            journalDate: Date()
        )

        // Load journal to edit
        viewModel.loadJournalToEdit(sampleJournal)

        // Verify the data is loaded into input fields
        XCTAssertEqual(viewModel.journalTitle, "Sample Title")
        XCTAssertEqual(viewModel.journalDescription, "Sample Description")
    }

    func testClearInput() {
        // Set some data
        viewModel.journalTitle = "Test Title"
        viewModel.journalDescription = "Test Description"

        // Clear input
        viewModel.clearInput()

        // Verify fields are cleared
        XCTAssertEqual(viewModel.journalTitle, "")
        XCTAssertEqual(viewModel.journalDescription, "")
    }

    func testJournalIdUniqueness() {
        // Add multiple journals
        viewModel.journalTitle = "Journal 1"
        viewModel.journalDescription = "Description 1"
        viewModel.addJournal()

        viewModel.journalTitle = "Journal 2"
        viewModel.journalDescription = "Description 2"
        viewModel.addJournal()

        // Verify each journal has unique ID
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

        // Verify journal date is within reasonable range
        XCTAssertGreaterThanOrEqual(journalDate, beforeAdd)
        XCTAssertLessThanOrEqual(journalDate, afterAdd)
    }

    func testJournalDateIsUpdatedOnEdit() {
        // Add initial journal
        viewModel.journalTitle = "Original Title"
        viewModel.journalDescription = "Original Description"
        viewModel.addJournal()

        let originalDate = viewModel.journals[0].journalDate
        let journalId = viewModel.journals[0].id

        // Wait a bit to ensure different timestamp
        let expectation = XCTestExpectation(
            description: "Wait for time difference")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.journalTitle = "Updated Title"
            self.viewModel.journalDescription = "Updated Description"
            self.viewModel.updateJournal(id: journalId)

            // Verify date was updated
            XCTAssertGreaterThan(
                self.viewModel.journals[0].journalDate, originalDate)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
