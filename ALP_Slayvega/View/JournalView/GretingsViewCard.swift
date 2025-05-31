

import SwiftUI

struct GreetingsViewCard: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 8) {
                Text(getGreeting())
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(Color.fromHex("3F3F59"))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                ZStack {
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.fromHex("FF8F6D").opacity(0.25),
                            Color.fromHex("FF8F6D").opacity(0.0)
                        ]),
                        center: .center,
                        startRadius: 35,
                        endRadius: 130
                    )
                    .frame(width: 250, height: 250)
                    .offset(y: -10)

                    Text("How have things\nbeen today ?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.fromHex("3F3F59"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
            }
        }
    }

    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 4..<12:
            return "🌄 Good Morning"
        case 12...15:
            return "🌤️ Good Afternoon"
        case 16...18:
            return "🌅 Good Evening"
        default:
            return "🌜 Good Night"
        }
    }
}

#Preview {
    GreetingsViewCard()
}
