import SwiftUI

struct GameMapPin: View {
    let annotation: GameAnnotation
    var isSelected: Bool = false

    private var sportIcon: String {
        Sport.allSports.first(where: { $0.id == annotation.sportId })?.iconName ?? "sportscourt.fill"
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.accentGreen : Color.white)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: AppTheme.accentGreen.opacity(0.3), radius: isSelected ? 8 : 4, y: 2)

                Image(systemName: sportIcon)
                    .font(.system(size: isSelected ? 20 : 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : AppTheme.accentGreen)
            }

            Image(systemName: "triangle.fill")
                .font(.system(size: 8))
                .foregroundColor(isSelected ? AppTheme.accentGreen : .white)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct VenueMapPin: View {
    let annotation: VenueAnnotation
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.accentCyan : Color.white)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: AppTheme.accentCyan.opacity(0.3), radius: isSelected ? 8 : 4, y: 2)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: isSelected ? 20 : 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : AppTheme.accentCyan)
            }

            Image(systemName: "triangle.fill")
                .font(.system(size: 8))
                .foregroundColor(isSelected ? AppTheme.accentCyan : .white)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
