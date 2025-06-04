import SwiftUI

struct JournalMenuView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var isPresentingAddJournal = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header greeting card
                    GreetingsViewCard()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Journal")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.fromHex("3F3F59"))
                            .padding(.horizontal, 24)

                        if viewModel.journals.isEmpty {
                            VStack(spacing: 24) {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 36))
                                    .foregroundColor(.gray)

                                Text("No journal entries yet")
                                    .font(.body)
                                    .foregroundColor(.gray)

                                Text("Tap the button below to write your first one.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 230)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.journals, id: \.id) { entry in
                                        NavigationLink {
                                            JournalDetailView(viewModel: viewModel, journal: entry)
                                                .toolbar(.hidden, for: .tabBar) // ✅ SEMBUNYIKAN TAB BAR
                                        } label: {
                                            JournalEntryCard(entry: entry)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
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
                            .background(Color.fromHex("FF8F6D"))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isPresentingAddJournal) {
            AddJournalView(journalVM: viewModel)
        }
        .onAppear {
            viewModel.fetchJournals()
        }
    }
}



//import SwiftUI
//
//struct JournalingHomeView: View {
//    var body: some View {
//        JournalMainView()
//    }
//}
//
//struct JournalMainView: View {
//    @StateObject private var viewModel = JournalViewModel()
//    @State private var isPresentingAddJournal = false
//
//    var body: some View {
//        NavigationView {
//            ZStack(alignment: .bottom) {
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//
//                VStack(spacing: 0) {
//                    GreetingsViewCard()
//
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Your Journal")
//                            .font(.title3)
//                            .fontWeight(.semibold)
//                            .foregroundColor(Color.fromHex("3F3F59"))
//                            .padding(.horizontal, 24)
//
//                        ScrollView {
//                            LazyVStack(spacing: 12) {
//                                ForEach(viewModel.journals) { entry in
//                                    NavigationLink(destination: JournalDetailView(viewModel: viewModel, journal: entry)) {
//                                        JournalEntryCard(entry: entry)
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//                                }
//                            }
//                            .padding(.horizontal, 24)
//                        }
//                    }
//
//                    Spacer()
//
//                    Button(action: {
//                        isPresentingAddJournal = true
//                    }) {
//                        Text("Add Journal")
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 56)
//                            .background(Color.fromHex("FF8F6D"))
//                            .cornerRadius(28)
//                    }
//                    .padding(.horizontal, 24)
//                    .padding(.bottom, 32)
//                }
//            }
//            .navigationBarHidden(true)
//        }
//        .sheet(isPresented: $isPresentingAddJournal) {
//            JournalInputView { newEntry in
//                viewModel.journals.append(newEntry)
//            }
//        }
//    }
//}
//
//
//
//#Preview {
//    JournalingHomeView()
//}
