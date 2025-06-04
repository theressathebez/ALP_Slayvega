import SwiftUI

struct JournalEntryCard: View {
    let entry: JournalModel

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedDate(entry.journalDate))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.fromHex("3F3F59"))

                Text(entry.journalTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.fromHex("3F3F59"))

                Text(entry.journalDescription)
                    .font(.system(size: 14))
                    .foregroundColor(Color.fromHex("3F3F59").opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.fromHex("FF8F6D"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.fromHex("FF8F6D").opacity(0.4), lineWidth: 1)
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

