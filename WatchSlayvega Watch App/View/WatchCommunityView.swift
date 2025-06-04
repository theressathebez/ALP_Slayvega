// WatchSlayvega Watch App/View/WatchCommunityView.swift
import SwiftUI

struct WatchCommunityReadView: View { //
    @StateObject private var connectivity = WatchConnectivity() //
    @State private var showConnectionInfoSheet = false //

    var body: some View { //
        NavigationView { //
            VStack(spacing: 0) { //
                ConnectionStatusHeaderView(connectivity: connectivity, showInfoSheet: $showConnectionInfoSheet) //
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                if connectivity.isLoading && connectivity.communities.isEmpty { //
                    ProgressView("Fetching Posts...") //
                        .frame(maxHeight: .infinity)
                } else if let errorMsg = connectivity.errorMessage, connectivity.communities.isEmpty { //
                    ErrorDisplayView( //
                        message: errorMsg,
                        onRetry: { connectivity.manualRefresh() }, //
                        onTestConnection: { connectivity.testPingToPhone() } //
                    )
                    .frame(maxHeight: .infinity)
                } else if connectivity.communities.isEmpty { //
                    EmptyStateDisplayView(onRefresh: { connectivity.manualRefresh() }) //
                        .frame(maxHeight: .infinity)
                } else {
                    List { //
                        ForEach(connectivity.communities) { community in //
                            NavigationLink(destination: WatchCommunityPostDetailView(communityPost: community, connectivity: connectivity)) { //
                                CommunityPostRow(community: community) //
                            }
                        }
                    }
                    .listStyle(.carousel) //
                }
            }
            .navigationTitle("Community") //
            .navigationBarTitleDisplayMode(.inline) //
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        connectivity.manualRefresh() //
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(connectivity.isLoading) //
                }
            }
            .onAppear { //
                if connectivity.communities.isEmpty { //
                    connectivity.requestCommunitiesData(reason: "WatchCommunityReadView Appeared") //
                }
            }
            .sheet(isPresented: $showConnectionInfoSheet) { //
                DetailedConnectionInfoView(connectivity: connectivity) //
            }
        }
    }
}

// --- Subviews (ConnectionStatusHeaderView, ErrorDisplayView, EmptyStateDisplayView, CommunityPostRow, DetailedConnectionInfoView) ---
// Letakkan kode subview yang sudah ada di sini. Pastikan tidak ada duplikasi CommunityPostDetailView.
// ConnectionStatusHeaderView
struct ConnectionStatusHeaderView: View { //
    @ObservedObject var connectivity: WatchConnectivity //
    @Binding var showInfoSheet: Bool //

    var statusColor: Color { //
        if !connectivity.isConnectedToPhone { return .red } //
        if connectivity.isLoading || connectivity.isLoadingComments { return .yellow } //
        if connectivity.errorMessage != nil || connectivity.commentsErrorMessage != nil { return .orange } //
        return .green //
    }

    var body: some View { //
        Button(action: { showInfoSheet = true }) { //
            HStack(spacing: 4) { //
                Circle().fill(statusColor).frame(width: 8, height: 8) //
                Text(connectivity.connectionStatusMessage) //
                    .font(.system(size: 10))
                    .lineLimit(1) //
                Spacer() //
                if connectivity.isLoading || connectivity.isLoadingComments { //
                    ProgressView().scaleEffect(0.5) //
                }
            }
        }
        .buttonStyle(PlainButtonStyle()) //
    }
}

// ErrorDisplayView
struct ErrorDisplayView: View { //
    let message: String //
    let onRetry: () -> Void //
    let onTestConnection: () -> Void //

    var body: some View { //
        VStack(spacing: 10) { //
            Image(systemName: "wifi.exclamationmark").font(.title).foregroundColor(.red) //
            Text("Error").font(.headline) //
            Text(message).font(.caption).multilineTextAlignment(.center).padding(.horizontal) //
            Button("Retry", action: onRetry).font(.caption).buttonStyle(.borderedProminent).tint(.blue) //
            Button("Test Ping", action: onTestConnection).font(.caption2) //
        }
    }
}

// EmptyStateDisplayView
struct EmptyStateDisplayView: View { //
    let onRefresh: () -> Void //
    var body: some View { //
        VStack(spacing: 10) { //
            Image(systemName: "bubble.left.and.bubble.right").font(.title).foregroundColor(.gray) //
            Text("No Posts").font(.headline) //
            Text("Pull down to refresh or tap button.").font(.caption).foregroundColor(.secondary) //
            Button("Refresh", action: onRefresh).font(.caption) //
        }
    }
}

// CommunityPostRow
struct CommunityPostRow: View { //
    let community: WatchCommunityModel //

    var body: some View { //
        VStack(alignment: .leading, spacing: 4) { //
            HStack { //
                Text(community.username).font(.system(size: 13, weight: .semibold)).foregroundColor(.orange) //
                Spacer() //
                Text(community.formattedDate).font(.system(size: 10)).foregroundColor(.gray) //
            }
            Text(community.communityContent) //
                .font(.system(size: 12))
                .lineLimit(2) //
            if !community.hashtags.isEmpty { //
                Text(community.hashtags).font(.system(size: 10, weight: .medium)).foregroundColor(.blue).lineLimit(1) //
            }
            HStack { //
                Image(systemName: "heart.fill").font(.system(size: 10)).foregroundColor(.red) //
                Text("\(community.communityLikeCount)").font(.system(size: 10)) //
                Spacer() //
            }
        }
        .padding(.vertical, 2)
    }
}

// DetailedConnectionInfoView
struct DetailedConnectionInfoView: View { //
    @ObservedObject var connectivity: WatchConnectivity //
    @Environment(\.dismiss) var dismiss //

    var body: some View { //
        NavigationView { //
            List { //
                Section("Current Status") { //
                    ForEach(connectivity.getConnectionInfo().sorted(by: { $0.key < $1.key }), id: \.key) { key, value in //
                        VStack(alignment: .leading) { //
                            Text(key).font(.caption.weight(.semibold)) //
                            Text(value).font(.caption2) //
                        }
                    }
                }
                Section("Actions") { //
                    Button("Test Ping to iPhone") { connectivity.testPingToPhone() } //
                    Button("Force Refresh Posts") { connectivity.manualRefresh() } //
                }
            }
            .navigationTitle("Connection Details") //
            .toolbar { //
                ToolbarItem(placement: .cancellationAction) { //
                    Button("Done") { dismiss() } //
                }
            }
        }
    }
}

#Preview { //
    WatchCommunityReadView() //
}
