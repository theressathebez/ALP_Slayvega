import SwiftUI

struct JournalEntryCard: View {
    let entry: JournalModel

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedDate(entry.journalDate))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "3F3F59"))

                Text(entry.journalTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "3F3F59"))

                Text(entry.journalDescription)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "3F3F59").opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "FF8F6D"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "FF8F6D").opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle()) // penting untuk bisa diklik seluruh area
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Tambahkan warna khusus sebagai static var
    static let cardGradientTop = Color(hex: "#FFEFF2")
    static let cardGradientBottom = Color(hex: "#FFFFFF")
    static let cardText = Color(hex: "#4A4A4A") // contoh warna teks utama
    static let cardSubtitle = Color(hex: "#8E8E93") // contoh warna subtitle
    static let cardBorder = Color(hex: "#D9D9D9")
}

