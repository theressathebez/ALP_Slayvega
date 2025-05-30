import SwiftUI

struct QuotesCardView: View {
    let quote: String
    let emoji1: String
    let emoji2: String

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

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Quotes of the Day")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.cardSubtitle)
                        .padding(.top, 1)


                }

                HStack(alignment: .center) {
                    Text(quote)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.cardText)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    HStack(spacing: 8) {
                        Text(emoji1)
                        Text(emoji2)
                    }
                    .font(.system(size: 26))
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 160)
        .padding(.horizontal, 10)
    }
}

#Preview {
    QuotesCardView(
        quote: "The universe will provide for me",
        emoji1: "🫧",
        emoji2: "🌍"
    )
}
