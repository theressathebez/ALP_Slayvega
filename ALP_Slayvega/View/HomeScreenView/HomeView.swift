import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var quotesVM: QuotesViewModel
    @EnvironmentObject var communityVM: CommunityViewModel

    let notificationCount = 9

    var topShares: [CommunityModel] {
        communityVM.communities
            .sorted { $0.communityLikeCount > $1.communityLikeCount }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    // Header: Profile Card
                    ProfileCardView(
                        user: MyUser(name: authVM.myUser.getDisplayName()),
                        notificationCount: notificationCount
                    )
                    .environmentObject(authVM)
                    .padding(.horizontal, 20)

                    // Quotes of the Day
                    if let quote = quotesVM.getCurrentQuote() {
                        QuotesCardView(quote: quote)
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                quotesVM.getNextQuote()
                            }
                    }

                    // Section Header: Most Popular Shares
                    HStack {
                        Text("Most Popular Shares")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.fromHex("#2C2C45"))
                            .padding(.top, 15)

                        Spacer()

                        NavigationLink {
                            CommunityView()
                                .navigationBarBackButtonHidden(false)
                                .toolbar(.hidden, for: .tabBar)
                        } label: {
                            Text("See More")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.fromHex("#FF8F6D"))
                        }
                    }
                    .padding(.horizontal, 20)

                    // Share Cards (Horizontal Scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(topShares.indices, id: \.self) { index in
                                SharesCardView(
                                    community: topShares[index],
                                    commentCount: 33
                                )
                                .environmentObject(authVM)
                                .padding(.leading, index == 0 ? 20 : 0)
                            }
                        }
                        .padding(.trailing, 10)
                    }

                    // Dashboard Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(authVM.myUser.getDisplayName())’s Dashboard")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.fromHex("#2C2C45"))
                            .padding(.horizontal, 12)
                            .padding(.top, 15)

                        DashboardView()
                    }
                    .padding(.horizontal, 10)

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
            .onAppear {
                if authVM.myUser.name.isEmpty {
                    authVM.fetchUserProfile()
                }
                communityVM.loadAllCommunities()
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(QuotesViewModel())
        .environmentObject(CommunityViewModel())
}
