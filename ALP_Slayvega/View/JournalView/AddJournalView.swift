import SwiftUI

struct AddJournalView: View {
    @State private var title: String = ""
    @State private var description: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("🧘 Good Morning")
                .font(.title2).bold()

            Text("How have things\nbeen today ?")
                .font(.title).bold()

            TextField("Journal Entry", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextEditor(text: $description)
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )

            Button("Save Journal") {
                // Save logic placeholder
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(25)

            Spacer()
        }
        .padding()
    }
}
