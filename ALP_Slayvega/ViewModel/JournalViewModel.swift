import Foundation
import SwiftUI

class JournalViewModel: ObservableObject {

    @Published var journalTitle: String = ""
    @Published var journalDescription: String = ""

    @Published var journals: [JournalModel] = []

    func addJournal() {
        let newJournal = JournalModel(
            journalTitle: journalTitle,
            journalDescription: journalDescription,
            journalDate: Date()
        )
        journals.append(newJournal)
        clearInput()
    }

    func updateJournal(id: String) {
        if let index = journals.firstIndex(where: { $0.id == id }) {
            journals[index].journalTitle = journalTitle
            journals[index].journalDescription = journalDescription
            journals[index].journalDate = Date()
        }
        clearInput()
    }

    func deleteJournal(id: String) {
        journals.removeAll { $0.id == id }
    }

    func loadJournalToEdit(_ journal: JournalModel) {
        journalTitle = journal.journalTitle
        journalDescription = journal.journalDescription
    }

    func clearInput() {
        journalTitle = ""
        journalDescription = ""
    }
}
