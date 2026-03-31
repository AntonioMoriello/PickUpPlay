import SwiftUI
import FirebaseAuth

struct GroupMembersView: View {
    let group: SportGroup
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var groupVM = GroupViewModel()

    private var currentUserId: String {
        FirebaseManager.shared.auth.currentUser?.uid ?? authViewModel.currentUser?.id ?? ""
    }

    private var isAdmin: Bool {
        group.adminIds.contains(currentUserId)
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            if groupVM.isLoading && groupVM.members.isEmpty {
                ProgressView("Loading members...")
                    .fontDesign(.rounded)
            } else if groupVM.members.isEmpty {
                EmptyStateView(
                    icon: "person.3.fill",
                    title: "No Members",
                    message: "This group has no members yet."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(groupVM.members) { member in
                            MemberRow(
                                member: member,
                                isAdmin: group.adminIds.contains(member.id),
                                isCreator: group.creatorId == member.id,
                                showActions: isAdmin && member.id != currentUserId,
                                onPromote: {
                                    Task { await groupVM.promoteToAdmin(groupId: group.id, userId: member.id) }
                                },
                                onRemove: {
                                    Task { await groupVM.removeMember(groupId: group.id, userId: member.id) }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Members (\(group.memberCount))")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await groupVM.fetchMembers(groupId: group.id) }
        }
        .errorBanner(message: $groupVM.errorMessage)
    }
}

struct MemberRow: View {
    let member: User
    var isAdmin: Bool = false
    var isCreator: Bool = false
    var showActions: Bool = false
    var onPromote: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 14) {
            NavigationLink(destination: PlayerProfileView(userId: member.id)) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gradient)
                            .frame(width: 44, height: 44)
                        Text(String(member.displayName.prefix(1)).uppercased())
                            .font(.headline)
                            .fontDesign(.rounded)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(member.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)

                        HStack(spacing: 4) {
                            if isCreator {
                                Text("Creator")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(AppTheme.accentAmber)
                            } else if isAdmin {
                                Text("Admin")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(AppTheme.accentCyan)
                            }

                            Text("\(member.gamesPlayed) games")
                                .font(.caption2)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            if showActions {
                Menu {
                    if !isAdmin {
                        Button {
                            onPromote?()
                        } label: {
                            Label("Promote to Admin", systemImage: "arrow.up.circle")
                        }
                    }
                    Button(role: .destructive) {
                        onRemove?()
                    } label: {
                        Label("Remove", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(AppTheme.gradient)
                }
            }
        }
        .padding(14)
        .glassCard(padding: 0)
    }
}
