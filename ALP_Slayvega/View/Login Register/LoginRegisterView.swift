import SwiftUI

struct LoginRegisterSheet: View {
    @Binding var showAuthSheet: Bool
    @EnvironmentObject var authVM: AuthViewModel
    @State var registerClicked: Bool = true

    var body: some View {
        if registerClicked {
            VStack {
                Spacer()
                Text("Login")
                    .font(.title).fontWeight(.bold)

                TextField("Email", text: $authVM.myUser.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $authVM.myUser.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if authVM.falseCredential {

                    Text("Invalid Username and Password")

                        .fontWeight(.medium)

                        .foregroundColor(Color.red)

                }

                Button(
                    action: {
                        Task {
                            await authVM.signIn()
                            authVM.checkUserSession()
                            
                            if !authVM.falseCredential {
                                showAuthSheet = false
                                authVM.myUser = MyUser()
                            }
                        }
                    }
                ) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.borderedProminent)


             

                Button(

                    action: {

                        registerClicked = false

                    }

                ) {

                    Text("Don't have an account? Register").font(.system(size: 15)).fontWeight(.medium)

                }
                Spacer()

            }

            .interactiveDismissDisabled(true)

        } else {

            VStack {
                Spacer()

                Text("Register")
                    .font(.title).fontWeight(.bold)

                TextField("Name", text: $authVM.myUser.name)

                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    .padding()

                TextField("Email", text: $authVM.myUser.email)

                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    .padding()

                SecureField("Password", text: $authVM.myUser.password)

                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    .padding()

                if authVM.falseCredential {

                    Text("Invalid Username and Password")

                        .fontWeight(.medium)

                        .foregroundColor(Color.red)

                }

                Button(

                    action: {

                        Task {

                            await authVM.signUp()

                            if authVM.falseCredential {
                                authVM.checkUserSession()
                                showAuthSheet = !authVM.isSignedIn
                                authVM.myUser = MyUser()
                            }
                        }
                    }
                ) {
                    Text("Register").frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.borderedProminent)


                Button(
                    action: {
                        registerClicked = true
                    }
                ) {
                    Text("Login").font(.system(size: 15)).fontWeight(.medium)
                }
                Spacer()
            }
            .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    LoginRegisterSheet(
        showAuthSheet:
            .constant(true)
    )
    .environmentObject(AuthViewModel())
}
