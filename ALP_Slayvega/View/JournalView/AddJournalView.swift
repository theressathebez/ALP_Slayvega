import SwiftUI

struct AddJournalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var journalVM: JournalViewModel

    var body: some View {
        VStack(spacing: 24) {
            GreetingsViewCard()

            VStack(alignment: .leading, spacing: 16) {
                Text("Journal Entry")
                    .font(.headline)
                    .foregroundColor(Color.fromHex("3F3F59"))

                TextField("What's on your mind...", text: $journalVM.journalTitle)
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
                    .foregroundColor(Color.fromHex("3F3F59"))

                TextEditor(text: $journalVM.journalDescription)
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
                journalVM.addJournal()
                dismiss()
            }) {
                Text("Save Journal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.fromHex("FF8F6D"), Color.fromHex("FF7765")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .opacity(journalVM.journalTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.3 : 1.0)
                    )
                    .cornerRadius(28)
            }
            .disabled(journalVM.journalTitle.trimmingCharacters(in: .whitespaces).isEmpty)
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


//import SwiftUI
//
//struct JournalInputView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var title: String = ""
//    @State private var description: String = ""
//
//    var onSave: (JournalModel) -> Void
//
//    var body: some View {
//        VStack(spacing: 24) {
//            GreetingsViewCard()
//
//            VStack(alignment: .leading, spacing: 16) {
//                Text("Journal Entry")
//                    .font(.headline)
//                    .foregroundColor(Color.fromHex("3F3F59"))
//
//                TextField("What's on your mind..", text: $title)
//                    .autocapitalization(.none)
//                    .disableAutocorrection(true)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(16)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                    )
//
//                Text("Description")
//                    .font(.headline)
//                    .foregroundColor(Color.fromHex("3F3F59"))
//
//                TextEditor(text: $description)
//                    .autocapitalization(.none) 
//                    .disableAutocorrection(false)
//                    .keyboardType(.default)
//                    .frame(height: 160)
//                    .padding(8)
//                    .background(Color.white)
//                    .cornerRadius(16)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                    )
//            }
//
//            .padding(.horizontal, 24)
//
//            Spacer()
//
//            Button(action: {
//                let newEntry = JournalModel(
//                    journalTitle: title,
//                    journalDescription: description,
//                    journalDate: Date()
//                )
//                onSave(newEntry)
//                presentationMode.wrappedValue.dismiss()
//            }) {
//                Text("Save Journal")
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 56)
//                    .background(LinearGradient(
//                        gradient: Gradient(colors: [Color.fromHex("FF8F6D"), Color.fromHex("FF7765")]),
//                        startPoint: .leading,
//                        endPoint: .trailing
//                    ))
//                    .cornerRadius(28)
//            }
//            .padding(.horizontal, 24)
//            .padding(.bottom, 32)
//        }
//        .padding(.top, 40)
//        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//        )
//    }
//}
//
//#Preview {
//    JournalInputView { newEntry in
//        print("Preview Save Journal: \(newEntry.journalTitle)")
//    }
//}
