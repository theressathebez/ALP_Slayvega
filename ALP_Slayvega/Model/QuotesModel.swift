import SwiftUI

struct Quote: Codable {
    let text: String
    let emoji1: String
    let emoji2: String
    let createdAt: Date
    
    init(text: String, emoji1: String = "", emoji2: String = "") {
        self.text = text
        self.emoji1 = emoji1
        self.emoji2 = emoji2
        self.createdAt = Date()
    }
}
