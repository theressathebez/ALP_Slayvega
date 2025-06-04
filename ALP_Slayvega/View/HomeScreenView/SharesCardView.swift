import SwiftUI

struct SharesCardView: View {
    let community: CommunityModel
//    let commentCount: Int

    @EnvironmentObject var authVM: AuthViewModel
    @State private var isActive = false
    @StateObject private var commentVM = CommentViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Avatar & Username
            HStack(spacing: 10) {
                if community.username.isEmpty {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .padding(5)
                        )
                } else {
                    Image("sampleProfile") // Replace with actual image loading if available
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
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
                Label("\(commentVM.comments.count)", systemImage: "bubble.right")
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

            // ✅ Internal navigation
            NavigationLink(
                destination: CommentDetailView(community: community, authVM: authVM),
                isActive: $isActive,
                label: { EmptyView() }
            )
            .hidden()
        }
        .onAppear{
            commentVM.loadComments(for: community.id)
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

