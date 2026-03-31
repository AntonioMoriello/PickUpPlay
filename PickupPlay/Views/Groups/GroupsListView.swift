import SwiftUI
import FirebaseAuth

struct GroupsListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var groupVM = GroupViewModel()
    @State private var selectedTab = 0
    @State private var showCreateGroup = false

    private var currentUserId: String {
        FirebaseManager.shared.auth.currentUser?.uid ?? authViewModel.currentUser?.id ?? ""
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("My Groups").tag(0)
                        Text("Discover").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    if groupVM.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        let displayGroups = selectedTab == 0 ? groupVM.groups : groupVM.discoverGroups
                        if displayGroups.isEmpty {
                            EmptyStateView(
                                icon: "person.3.fill",
                                title: selectedTab == 0 ? "No Groups" : "No Groups Found",
                                message: selectedTab == 0 ? "Join or create a group to connect with players!" : "No public groups available yet.",
                                actionTitle: selectedTab == 0 ? "Create Group" : nil,
                                action: selectedTab == 0 ? { showCreateGroup = true } : nil
                            )
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(displayGroups) { group in
                                        NavigationLink(destination: GroupDetailsView(group: group)) {
                                            GroupCard(group: group, isMember: group.memberIds.contains(currentUserId))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 40)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateGroup = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.gradient)
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                NavigationStack {
                    CreateGroupView()
                }
            }
            .onAppear {
                Task { await loadGroups() }
            }
            .onChange(of: selectedTab) { _, _ in
                Task { await loadGroups() }
            }
            .onChange(of: currentUserId) { _, _ in
                Task { await loadGroups() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .groupsDidChange)) { _ in
                Task { await loadGroups() }
            }
            .errorBanner(message: $groupVM.errorMessage)
        }
    }

    private func loadGroups() async {
        if selectedTab == 0 {
            await groupVM.fetchMyGroups(userId: currentUserId)
        } else {
            await groupVM.fetchDiscoverGroups()
        }
    }
}

struct GroupCard: View {
    let group: SportGroup
    var isMember: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.accentCyan.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppTheme.gradient)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text("\(group.memberCount) members")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isMember {
                    Text("Joined")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(AppTheme.accentGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppTheme.accentGreen.opacity(0.12)))
                }
            }

            if !group.description.isEmpty {
                Text(group.description)
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(group.sportIds, id: \.self) { sportId in
                        let sportName = Sport.allSports.first(where: { $0.id == sportId })?.name ?? sportId
                        Text(sportName)
                            .font(.caption2)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color(.systemGray6)))
                    }

                    Text(group.isPublic ? "Public" : "Private")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundColor(group.isPublic ? AppTheme.accentGreen : AppTheme.accentAmber)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill((group.isPublic ? AppTheme.accentGreen : AppTheme.accentAmber).opacity(0.1)))
                }
            }
        }
        .padding(16)
        .glassCard(padding: 0)
    }
}
