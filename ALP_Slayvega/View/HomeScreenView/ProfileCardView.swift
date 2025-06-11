import SwiftUI

struct ProfileCardView: View {
    var user: MyUser
    var notificationCount: Int

    @EnvironmentObject var authVM: AuthViewModel
    @State private var goToProfile = false
    @State var showAuthSheet = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 16) {
                Button(action: {
                    goToProfile = true
                }) {
                    Circle()
                        .fill(Color.fromHex("#FFA075").opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image("Image")  
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .padding(8)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome,")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)

                    Text(user.name.isEmpty ? "User" : user.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.fromHex("#2C2C45"))
                }

                Spacer()
            }
            .padding(.trailing, 48)
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color.fromHex("#2C2C45"))
                    .padding(.top, 4)
                    .padding(.trailing, 8)

                if notificationCount > 0 {
                    Text("\(notificationCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Circle().fill(Color.fromHex("#FF8F6D")))
                        .offset(x: 4, y: -4)
                }
            }

            NavigationLink(
                destination: ProfileView(
                    showAuthSheet: $showAuthSheet, authVM: authVM),
                isActive: $goToProfile,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        }
        .accentColor(Color.fromHex("#FF8F6D"))
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}
