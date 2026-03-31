import SwiftUI

struct ProfileCardView: View {
    let user: User
    var isEditable: Bool = false
    var onEditTap: (() -> Void)? = nil
    var onFollowTap: (() -> Void)? = nil
    var isFollowing: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.gradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: AppTheme.accentGreen.opacity(0.3), radius: 16, y: 8)

                if !user.profileImageURL.isEmpty {
                    AsyncImage(url: URL(string: user.profileImageURL)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Text(String(user.displayName.prefix(1)).uppercased())
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Text(String(user.displayName.prefix(1)).uppercased())
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            VStack(spacing: 6) {
                Text(user.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)

                Text(user.email)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 20) {
                ProfileStatItem(value: "\(user.gamesPlayed)", label: "Games")
                ProfileStatItem(value: "\(user.gamesOrganized)", label: "Organized")
                ProfileStatItem(value: String(format: "%.1f", user.reliabilityScore), label: "Rating")
                ProfileStatItem(value: "\(user.followerIds.count)", label: "Followers")
            }

            if !user.sportSkills.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sports")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(user.sportSkills) { skill in
                                let sportName = Sport.allSports.first(where: { $0.id == skill.sportId })?.name ?? skill.sportId
                                HStack(spacing: 4) {
                                    Text(sportName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .fontDesign(.rounded)
                                    SkillLevelBadge(level: skill.level)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color(.systemGray6)))
                            }
                        }
                    }
                }
            }

            if isEditable {
                Button {
                    onEditTap?()
                } label: {
                    Text("Edit Profile")
                }
                .buttonStyle(AppSecondaryButtonStyle())
                .padding(.horizontal, 20)
            } else if let onFollowTap {
                Button {
                    onFollowTap()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isFollowing ? "person.badge.minus" : "person.badge.plus")
                        Text(isFollowing ? "Unfollow" : "Follow")
                    }
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
    }
}

struct ProfileStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
        }
    }
}
