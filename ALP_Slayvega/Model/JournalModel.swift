import Foundation

struct JournalModel: Identifiable {
    var id: String = UUID().uuidString
    var journalTitle: String
    var journalDescription: String
    var journalDate: Date
    var userId: String
}
