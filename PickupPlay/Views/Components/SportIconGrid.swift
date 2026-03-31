import SwiftUI

struct SportIconGrid: View {
    let sports: [Sport]
    @Binding var selectedSportIds: Set<String>
    var allowMultiSelect: Bool = true
    var columns: Int = 3

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: columns)
    }

    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(sports) { sport in
                SportIconCell(
                    sport: sport,
                    isSelected: selectedSportIds.contains(sport.id)
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if allowMultiSelect {
                            if selectedSportIds.contains(sport.id) {
                                selectedSportIds.remove(sport.id)
                            } else {
                                selectedSportIds.insert(sport.id)
                            }
                        } else {
                            selectedSportIds = [sport.id]
                        }
                    }
                }
            }
        }
    }
}

struct SportIconCell: View {
    let sport: Sport
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                            ? AnyShapeStyle(AppTheme.gradient)
                            : AnyShapeStyle(Color(.systemGray6))
                        )
                        .frame(width: 64, height: 64)
                        .shadow(
                            color: isSelected ? AppTheme.accentGreen.opacity(0.35) : .clear,
                            radius: isSelected ? 10 : 0,
                            y: 4
                        )

                    Image(systemName: sport.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primary)
                }

                Text(sport.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .medium)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AppTheme.accentGreen.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? AnyShapeStyle(AppTheme.gradient) : AnyShapeStyle(Color.clear),
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SportIconGrid(
        sports: Array(Sport.allSports.prefix(9)),
        selectedSportIds: .constant(["basketball", "soccer"])
    )
    .padding()
}
