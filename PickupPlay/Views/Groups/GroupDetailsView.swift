import SwiftUI
import FirebaseAuth

struct GroupDetailsView: View {
    let group: SportGroup
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var groupVM = GroupViewModel()
    @State private var showMembers = false
    @State private var showChat = false
    @State private var showLeaveConfirm = false

    private var currentUserId: String {
        FirebaseManager.shared.auth.currentUser?.uid ?? authViewModel.currentUser?.id ?? ""
    }

    private var currentGroup: SportGroup {
        groupVM.selectedGroup ?? group
    }

    private var isMember: Bool {
        currentGroup.memberIds.contains(currentUserId)
    }

    private var isAdmin: Bool {
        currentGroup.adminIds.contains(currentUserId)
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentCyan.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(AppTheme.gradient)
                    }
                    .padding(.top, 16)

                    Text(currentGroup.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)

                    if !currentGroup.description.isEmpty {
                        Text(currentGroup.description)
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    HStack(spacing: 20) {
                        ProfileStatItem(value: "\(currentGroup.memberCount)", label: "Members")
                        ProfileStatItem(value: "\(currentGroup.sportIds.count)", label: "Sports")
                        ProfileStatItem(value: currentGroup.isPublic ? "Public" : "Private", label: "Privacy")
                    }

                    VStack(spacing: 16) {
                        InfoRow(icon: "calendar", label: "Created", value: currentGroup.createdAt.formatted(date: .abbreviated, time: .omitted))

                        Divider()

                        HStack(spacing: 12) {
                            Image(systemName: "sportscourt.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppTheme.gradient)
                                .frame(width: 24)
                            Text("Sports")
                                .font(.subheadline)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                            Spacer()
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(currentGroup.sportIds, id: \.self) { sportId in
                                        let name = Sport.allSports.first(where: { $0.id == sportId })?.name ?? sportId
                                        Text(name)
                                            .font(.caption)
                                            .fontDesign(.rounded)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(AppTheme.accentGreen.opacity(0.1)))
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        ProfileMenuRow(icon: "person.3.fill", title: "Members (\(currentGroup.memberCount))", color: AppTheme.accentCyan) {
                            showMembers = true
                        }
                        if isMember {
                            Divider().padding(.leading, 56)
                            ProfileMenuRow(icon: "message.fill", title: "Group Chat", color: AppTheme.accentGreen) {
                                showChat = true
                            }
                        }
                    }
                    .glassCard(padding: 0)
                    .padding(.horizontal, 16)

                    if isMember && !isAdmin {
                        Button("Leave Group") {
                            showLeaveConfirm = true
                        }
                        .buttonStyle(AppSecondaryButtonStyle())
                        .padding(.horizontal, 20)
                    } else if !isMember {
                        Button("Join Group") {
                            Task { await groupVM.joinGroup(groupId: currentGroup.id, userId: currentUserId) }
                        }
                        .buttonStyle(AppPrimaryButtonStyle())
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Group Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showMembers) {
            GroupMembersView(group: currentGroup)
        }
        .navigationDestination(isPresented: $showChat) {
            GroupChatView(chatRoomId: currentGroup.chatRoomId)
        }
        .alert("Leave Group?", isPresented: $showLeaveConfirm) {
            Button("Leave", role: .destructive) {
                Task { await groupVM.leaveGroup(groupId: currentGroup.id, userId: currentUserId) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            groupVM.selectedGroup = group
        }
        .loading(isLoading: groupVM.isLoading)
        .errorBanner(message: $groupVM.errorMessage)
    }
}
