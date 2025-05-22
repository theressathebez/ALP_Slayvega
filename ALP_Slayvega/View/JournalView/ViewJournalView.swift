import SwiftUI

struct ViewJournalView: View {
    var journal: JournalModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "xmark")
                    .font(.title2)
                Spacer()
                Text("Edit")
                    .foregroundColor(.gray)
            }

            Text("My Journal")
                .font(.title).bold()

            Text(journal.journalDate, style: .date)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 10) {
                Text("**Journal Entry**")
                Text(journal.journalTitle)

                Text("**Description**")
                Text(journal.journalDescription)
            }

            Spacer()
        }
        .padding()
    }
}
