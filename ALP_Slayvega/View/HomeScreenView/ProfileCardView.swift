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
                            Image("sampleProfile")
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

            NavigationLink(
                destination: ProfileView(showAuthSheet: $showAuthSheet, authVM: authVM),
                isActive: $goToProfile,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        }
        .onAppear{
            showAuthSheet = !authVM.isSignedIn
        }
        
        .sheet(isPresented: $showAuthSheet) {
            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
        }
        .accentColor(Color.fromHex("#FF8F6D"))
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

