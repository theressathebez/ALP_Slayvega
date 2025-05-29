import SwiftUI

struct JournalDetailView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: JournalViewModel
    var journal: JournalModel

    @State private var isEditing: Bool = false
    @State private var editedTitle: String
    @State private var editedDescription: String

    init(viewModel: JournalViewModel, journal: JournalModel) {
        self.viewModel = viewModel
        self.journal = journal
        _editedTitle = State(initialValue: journal.journalTitle)
        _editedDescription = State(initialValue: journal.journalDescription)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(Color(hex: "3F3F59"))
                }

                Spacer()

                Text("My Journal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "3F3F59"))

                Spacer()

                Button("Edit") {
                    isEditing.toggle()
                }
                .foregroundColor(Color(hex: "FF7765"))
                .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal)
            .padding(.top)

            Text(formattedDate(journal.journalDate))
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 8) {
                Text("Journal Entry")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "3F3F59"))

                if isEditing {
                    TextField("Entry title", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(journal.journalTitle)
                        .foregroundColor(Color(hex: "3F3F59"))
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "3F3F59"))

                if isEditing {
                    TextEditor(text: $editedDescription)
                        .frame(height: 160)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    Text(journal.journalDescription)
                        .foregroundColor(Color(hex: "3F3F59"))
                }
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                viewModel.deleteJournal(id: journal.id)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Delete Journal")
                    .foregroundColor(.red)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)

            if isEditing {
                Button(action: {
                    viewModel.journalTitle = editedTitle
                    viewModel.journalDescription = editedDescription
                    viewModel.updateJournal(id: journal.id)
                    isEditing = false
                }) {
                    Text("Save Journal")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "FF8F6D"))
                        .cornerRadius(28)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}
#Preview {
    let sampleJournal = JournalModel(
        journalTitle: "A day full of tears..",
        journalDescription: """
        Today was... heavy.
        I woke up already feeling off—like the weight of something invisible had settled on my chest overnight.
        """,
        journalDate: Date(timeIntervalSince1970: 1747008000) 
    )

    let viewModel = JournalViewModel()
    viewModel.journals = [sampleJournal]

    return JournalDetailView(viewModel: viewModel, journal: sampleJournal)
}
