import SwiftUI

struct SharesCardView: View {
    let community: CommunityModel
    let commentCount: Int

    @EnvironmentObject var authVM: AuthViewModel
    @State private var isActive = false

    var avatarLetter: String {
        if community.username.isEmpty {
            return "A"
        } else {
            return String(community.username.prefix(1)).uppercased()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Avatar & Username
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(avatarLetter)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                }

                Text(community.username.isEmpty ? "Anonymous" : community.username)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.fromHex("#2C2C45"))

                Spacer()
            }

            // Post Content
            Text(community.communityContent)
                .font(.system(size: 16))
                .foregroundColor(Color.fromHex("#7D7D93"))
                .lineLimit(2)

            // Footer: Comments, Likes, More button
            HStack {
                Label("\(commentCount)", systemImage: "bubble.right")
                    .font(.subheadline)
                    .foregroundColor(Color.fromHex("#7D7D93"))

                Label("\(community.communityLikeCount)", systemImage: "heart.fill")
                    .font(.subheadline)
                    .foregroundColor(.red)

                Spacer()

                Button(action: {
                    isActive = true
                }) {
                    Text("More")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.fromHex("#FF8F6D"))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }

            // Internal navigation
            NavigationLink(
                destination: CommentDetailView(community: community, authVM: authVM),
                isActive: $isActive,
                label: { EmptyView() }
            )
            .hidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 1).opacity(0.2)
        )
        .frame(width: 240)
        .padding(.horizontal, 5)
    }
}
