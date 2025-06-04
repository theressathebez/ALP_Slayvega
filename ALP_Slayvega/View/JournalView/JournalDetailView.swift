import SwiftUI

struct JournalDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: JournalViewModel
    var journal: JournalModel

    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedDescription: String

    @State private var showDeleteAlert = false
    @State private var showSaveSuccess = false

    init(viewModel: JournalViewModel, journal: JournalModel) {
        self.viewModel = viewModel
        self.journal = journal
        _editedTitle = State(initialValue: journal.journalTitle)
        _editedDescription = State(initialValue: journal.journalDescription)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(Color.fromHex("3F3F59"))
                }

                Spacer()

                Text("My Journal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.fromHex("3F3F59"))

                Spacer()

                if !isEditing {
                    Button("Edit") {
                        isEditing = true
                    }
                    .foregroundColor(Color.fromHex("FF7765"))
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .padding(.horizontal)
            .padding(.top)

            // Tanggal
            Text(formattedDate(journal.journalDate))
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .center)

            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Journal Entry")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.fromHex("3F3F59"))

                if isEditing {
                    TextField("Entry title", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(journal.journalTitle)
                        .foregroundColor(Color.fromHex("3F3F59"))
                        .font(.system(size: 16, weight: .regular))
                }
            }
            .padding(.horizontal)

            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.fromHex("3F3F59"))

                if isEditing {
                    TextEditor(text: $editedDescription)
                        .frame(height: 160)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    Text(journal.journalDescription)
                        .foregroundColor(Color.fromHex("3F3F59"))
                        .font(.system(size: 15))
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 40)

           
            Button(action: {
                showDeleteAlert = true
            }) {
                Text("Delete Journal")
                    .foregroundColor(.red)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 24) 

           
            if isEditing {
                Button(action: {
                    if editedTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                        
                        return
                    }

                    viewModel.journalTitle = editedTitle
                    viewModel.journalDescription = editedDescription
                    viewModel.updateJournal(id: journal.id)
                    isEditing = false
                    showSaveSuccess = true
                }) {
                    Text("Save Journal")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.fromHex("FF8F6D"), Color.fromHex("FF7765")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .alert("Are you sure?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteJournal(id: journal.id)
                dismiss()
            }
        } message: {
            Text("This will permanently delete this journal.")
        }
        .alert("Success", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your journal has been saved successfully.")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

