import SwiftUI

struct JournalInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var description: String = ""

    var onSave: (JournalModel) -> Void

    var body: some View {
        VStack(spacing: 24) {
            GreetingsViewCard()

            VStack(alignment: .leading, spacing: 16) {
                Text("Journal Entry")
                    .font(.headline)
                    .foregroundColor(Color(hex: "3F3F59"))

                TextField("What's on your mind..", text: $title)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                Text("Description")
                    .font(.headline)
                    .foregroundColor(Color(hex: "3F3F59"))

                TextEditor(text: $description)
                    .autocapitalization(.none) 
                    .disableAutocorrection(false)
                    .keyboardType(.default)
                    .frame(height: 160)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                let newEntry = JournalModel(
                    journalTitle: title,
                    journalDescription: description,
                    journalDate: Date()
                )
                onSave(newEntry)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save Journal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "FF8F6D"), Color(hex: "FF7765")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding(.top, 40)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    JournalInputView { newEntry in
        print("Preview Save Journal: \(newEntry.journalTitle)")
    }
}
