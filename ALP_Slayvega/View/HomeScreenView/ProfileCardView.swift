
import SwiftUI

struct ProfileCardView: View {
    let user: MyUser
    let notificationCount: Int

    var body: some View {
        HStack {
            // Avatar Circle
            ZStack {
                Circle()
                    .fill(Color(hex: "#FDECEA")) // Soft background
                    .frame(width: 60, height: 60)

                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(hex: "#3F3F59"))
            }
            .overlay(
                Circle()
                    .stroke(Color(hex: "#FF8F6D"), lineWidth: 3)
            )

            // Welcome Text
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome,")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#3F3F59"))

                Text(user.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#3F3F59"))
            }

            Spacer()

            // Notification Bell with Badge
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: "#3F3F59"))

                if notificationCount > 0 {
                    Text("\(notificationCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color(hex: "#FF8F6D")))
                        .offset(x: 10, y: -10)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    ProfileCardView(user: MyUser(name: "Leon Smith"), notificationCount: 9)
}
