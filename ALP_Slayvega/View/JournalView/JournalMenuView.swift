import SwiftUI

struct JournalingHomeView: View {
    var body: some View {
        JournalMainView()
    }
}

struct JournalMainView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var isPresentingAddJournal = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    GreetingsViewCard()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Journal")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "3F3F59"))
                            .padding(.horizontal, 24)

                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.journals) { entry in
                                    NavigationLink(destination: JournalDetailView(viewModel: viewModel, journal: entry)) {
                                        JournalEntryCard(entry: entry)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    Spacer()

                    Button(action: {
                        isPresentingAddJournal = true
                    }) {
                        Text("Add Journal")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "FF8F6D"))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isPresentingAddJournal) {
            JournalInputView { newEntry in
                viewModel.journals.append(newEntry)
            }
        }
    }
}



#Preview {
    JournalingHomeView()
}
