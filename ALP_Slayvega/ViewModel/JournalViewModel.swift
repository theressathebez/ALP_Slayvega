import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

class JournalViewModel: ObservableObject {
    
    @Published var journalTitle: String = ""
    @Published var journalDescription: String = ""
    @Published var journals: [JournalModel] = []
    
    private var dbRef = Database.database().reference().child("journals")
    
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }


    func addJournal() {
        guard let uid = currentUserId else {
            print("Error: User not logged in for addJournal.")
            return
        }
        guard !journalTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Error: Journal title is empty.")
            return
        }

        let journalId = UUID().uuidString
      
        let newJournal = JournalModel(
            id: journalId,
            journalTitle: journalTitle,
            journalDescription: journalDescription,
            journalDate: Date(),
            userId: uid
        )

        let journalData: [String: Any] = [
            "id": journalId,
            "journalTitle": newJournal.journalTitle,
            "journalDescription": newJournal.journalDescription,
            "journalDate": newJournal.journalDate.timeIntervalSince1970,
            "userId": uid
        ]

        dbRef.child(uid).child(journalId).setValue(journalData) { error, _ in
            if let error = error {
                print("Error saving journal to Firebase: \(error.localizedDescription)")
            } else {
                print("Journal saved to Firebase successfully.")
                
                self.fetchJournals()
            }
        }
        clearInput()
    }

    
    func fetchJournals(completion: (([JournalModel]) -> Void)? = nil) {
        guard let uid = currentUserId else {
            print("Error: User not logged in for fetchJournals.")
            DispatchQueue.main.async {
                 self.journals = []
            }
            completion?([])
            return
        }

        dbRef.child(uid).observe(.value) { snapshot in
            var tempJournals: [JournalModel] = []

            for case let child as DataSnapshot in snapshot.children {
                if let data = child.value as? [String: Any] {
                    let id = data["id"] as? String ?? UUID().uuidString
                    let title = data["journalTitle"] as? String ?? ""
                    let desc = data["journalDescription"] as? String ?? ""
                    let time = data["journalDate"] as? TimeInterval ?? Date().timeIntervalSince1970
                    let date = Date(timeIntervalSince1970: time)
                    let fetchedUserId = data["userId"] as? String ?? uid

                    let journal = JournalModel(
                        id: id,
                        journalTitle: title,
                        journalDescription: desc,
                        journalDate: date,
                        userId: fetchedUserId
                    )
                    tempJournals.append(journal)
                }
            }

            DispatchQueue.main.async {
                let sortedJournals = tempJournals.sorted { $0.journalDate > $1.journalDate }
                self.journals = sortedJournals
                completion?(sortedJournals)
                print("Journals fetched and updated: \(self.journals.count) items.")
            }
        } withCancel: { error in
            print("Error fetching journals with observer: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.journals = []
            }
            completion?([])
        }
    }
    
    func stopObservingJournals() {
        guard let uid = currentUserId else { return }
        dbRef.child(uid).removeAllObservers()
        print("Stopped observing journals for user: \(uid)")
    }

    func updateJournal(id: String) {
        guard let uid = currentUserId else {
            print("User not logged in for updateJournal.")
            return
        }
        
        guard !journalTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Error: Updated journal title is empty.")
            return
        }

        let journalRef = dbRef.child(uid).child(id)

        let updatedJournalData: [String: Any] = [
            "id": id,
            "journalTitle": journalTitle,
            "journalDescription": journalDescription,
            "journalDate": Date().timeIntervalSince1970,
            "userId": uid
        ]

        journalRef.updateChildValues(updatedJournalData) { error, _ in
            if let error = error {
                print("Error updating journal in Firebase: \(error.localizedDescription)")
            } else {
                print("Journal successfully updated in Firebase.")
                if let index = self.journals.firstIndex(where: { $0.id == id }) {
                    DispatchQueue.main.async {
                        self.journals[index].journalTitle = self.journalTitle
                        self.journals[index].journalDescription = self.journalDescription
                        self.journals[index].journalDate = Date()
                    }
                }
                self.clearInput()
            }
        }
    }

    func deleteJournal(id: String) {
        guard let uid = currentUserId else {
            print("User not logged in for deleteJournal.")
            return
        }

        dbRef.child(uid).child(id).removeValue { error, _ in
            if let error = error {
                print("Error deleting journal from Firebase: \(error.localizedDescription)")
            } else {
                print("Journal successfully deleted from Firebase.")
                DispatchQueue.main.async {
                    self.journals.removeAll { $0.id == id }
                }
            }
        }
    }

    func loadJournalToEdit(_ journal: JournalModel) {
        journalTitle = journal.journalTitle
        journalDescription = journal.journalDescription
    }

    func clearInput() {
        journalTitle = ""
        journalDescription = ""
    }
    
    deinit {
        stopObservingJournals()
    }
}
