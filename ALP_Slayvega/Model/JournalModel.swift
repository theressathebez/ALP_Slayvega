import Foundation

struct JournalModel: Identifiable, Codable {
    var id: String = UUID().uuidString
    var journalTitle: String
    var journalDescription: String
    var journalDate: Date
}
