import SwiftUI

struct JournalMenuView: View {
    let sampleJournals: [JournalModel] = [
        JournalModel(journalTitle: "Grateful Thoughts", journalDescription: "Had a productive day today!", journalDate: Date()),
        JournalModel(journalTitle: "Reflecting...", journalDescription: "Feeling peaceful after a walk.", journalDate: Date().addingTimeInterval(-86400))
    ]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("🧘 Good Morning")
                    .font(.title2).bold()

                Text("How have things\nbeen today ?")
                    .font(.title).bold()
                    .padding(.vertical)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(sampleJournals, id: \.id) { journal in
                            NavigationLink(destination: ViewJournalView(journal: journal)) {
                                VStack(alignment: .leading) {
                                    Text(journal.journalDate, style: .date)
                                        .bold()
                                    Text(journal.journalTitle)
                                        .lineLimit(1)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
                            }
                        }
                    }
                }

                Button("Add Journal") {
                    // Placeholder
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(25)
                .padding(.top)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}
#Preview {
    JournalMenuView()
}
