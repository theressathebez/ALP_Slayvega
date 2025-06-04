
import Foundation
import SwiftUI


import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

class JournalViewModel: ObservableObject {
    
    @Published var journalTitle: String = ""
    @Published var journalDescription: String = ""
    @Published var journals: [JournalModel] = []
    
    private var dbRef = Database.database().reference().child("journals")
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Add
    func addJournal() {
        guard let uid = userId else { return }
        guard !journalTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let journalId = UUID().uuidString
        let newJournal = JournalModel(
            id: journalId,
            journalTitle: journalTitle,
            journalDescription: journalDescription,
            journalDate: Date()
        )

        let journalData: [String: Any] = [
            "id": journalId,
            "journalTitle": newJournal.journalTitle,
            "journalDescription": newJournal.journalDescription,
            "journalDate": newJournal.journalDate.timeIntervalSince1970,
            "userId": uid
        ]

        dbRef.child(uid).child(journalId).setValue(journalData)

        journals.append(newJournal)
        clearInput()
    }

    // MARK: - Fetch
    func fetchJournals() {
        guard let uid = userId else { return }

        dbRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            var temp: [JournalModel] = []

            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any] {
                    let id = data["id"] as? String ?? UUID().uuidString
                    let title = data["journalTitle"] as? String ?? ""
                    let desc = data["journalDescription"] as? String ?? ""
                    let time = data["journalDate"] as? TimeInterval ?? Date().timeIntervalSince1970
                    let date = Date(timeIntervalSince1970: time)

                    let journal = JournalModel(
                        id: id,
                        journalTitle: title,
                        journalDescription: desc,
                        journalDate: date
                    )

                    temp.append(journal)
                }
            }

            DispatchQueue.main.async {
                self.journals = temp.sorted { $0.journalDate > $1.journalDate }
            }
        }
    }

    func updateJournal(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        let dbRef = Database.database().reference()
            .child("journals")
            .child(uid)
            .child(id)

        let updatedJournal: [String: Any] = [
            "id": id,
            "journalTitle": journalTitle,
            "journalDescription": journalDescription,
            "journalDate": Date().timeIntervalSince1970 * 1000 // Firebase expects milliseconds
        ]

        dbRef.updateChildValues(updatedJournal) { error, _ in
            if let error = error {
                print("Error updating journal: \(error.localizedDescription)")
            } else {
                print("Journal successfully updated.")
            }
        }

        // Optional: Perbarui lokal juga
        if let index = journals.firstIndex(where: { $0.id == id }) {
            journals[index].journalTitle = journalTitle
            journals[index].journalDescription = journalDescription
            journals[index].journalDate = Date()
        }

        clearInput()
    }

    // MARK: - Delete
    func deleteJournal(id: String) {
        guard let uid = userId else { return }

        dbRef.child(uid).child(id).removeValue()
        journals.removeAll { $0.id == id }
    }

    // MARK: - Helpers
    func loadJournalToEdit(_ journal: JournalModel) {
        journalTitle = journal.journalTitle
        journalDescription = journal.journalDescription
    }

    func clearInput() {
        journalTitle = ""
        journalDescription = ""
    }
}


//class JournalViewModel: ObservableObject {
//    
//    @Published var journalTitle: String = ""
//    @Published var journalDescription: String = ""
//  
//    @Published var journals: [JournalModel] = []
//    
//
//    func addJournal() {
//        let newJournal = JournalModel(
//            journalTitle: journalTitle,
//            journalDescription: journalDescription,
//            journalDate: Date()
//        )
//        journals.append(newJournal)
//        clearInput()
//    }
//    
//
//    func updateJournal(id: String) {
//        if let index = journals.firstIndex(where: { $0.id == id }) {
//            journals[index].journalTitle = journalTitle
//            journals[index].journalDescription = journalDescription
//            journals[index].journalDate = Date()
//            clearInput()
//        }
//    }
//    
//   
//    func deleteJournal(id: String) {
//        journals.removeAll { $0.id == id }
//    }
//   
//    func loadJournalToEdit(_ journal: JournalModel) {
//        journalTitle = journal.journalTitle
//        journalDescription = journal.journalDescription
//    }
//    
//
//    func clearInput() {
//        journalTitle = ""
//        journalDescription = ""
//    }
//}
