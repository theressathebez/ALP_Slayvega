import SwiftUI

struct QuotesCardView: View {
    let quote: Quote

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.cardGradientTop, .cardGradientBottom]),
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 14) {
                Text("Quotes of the Day")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.cardSubtitle)

                HStack(alignment: .center, spacing: 12) {
                    Text("“\(quote.text)”")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.cardText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    VStack(spacing: 4) {
                        Text(quote.emoji1)
                        Text(quote.emoji2)
                    }
                    .font(.system(size: 26))
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 160)
    }
}

#Preview {
    QuotesCardView(
        quote: Quote(text: "The universe will provide for me", emoji1: "🫧", emoji2: "🌍")
    )
}

