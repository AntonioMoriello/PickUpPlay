import SwiftUI

struct AchievementBadge: View {
    let achievement: Achievement
    var showProgress: Bool = true

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AnyShapeStyle(AppTheme.gradient) : AnyShapeStyle(Color(.systemGray5)))
                    .frame(width: 64, height: 64)
                    .shadow(
                        color: achievement.isUnlocked ? AppTheme.accentGreen.opacity(0.3) : .clear,
                        radius: achievement.isUnlocked ? 8 : 0,
                        y: 4
                    )

                Image(systemName: achievement.iconName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }

            Text(achievement.name)
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if showProgress && !achievement.isUnlocked {
                ProgressView(value: achievement.progressPercent)
                    .tint(AppTheme.accentGreen)
                    .frame(width: 50)

                Text("\(achievement.currentProgress)/\(achievement.requirement)")
                    .font(.caption2)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            } else if achievement.isUnlocked, let date = achievement.unlockedAt {
                Text(date, style: .date)
                    .font(.caption2)
                    .fontDesign(.rounded)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 100)
        .padding(.vertical, 8)
    }
}
