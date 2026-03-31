import SwiftUI

struct FilterSearchView: View {
    @Binding var filterOptions: GameFilterOptions
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sport")
                                .font(.headline)
                                .fontDesign(.rounded)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterChip(
                                        title: "All Sports",
                                        isSelected: filterOptions.sportId == nil || filterOptions.sportId?.isEmpty == true
                                    ) {
                                        filterOptions.sportId = nil
                                    }

                                    ForEach(Sport.allSports) { sport in
                                        FilterChip(
                                            title: sport.name,
                                            icon: sport.iconName,
                                            isSelected: filterOptions.sportId == sport.id
                                        ) {
                                            filterOptions.sportId = sport.id
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Skill Level")
                                .font(.headline)
                                .fontDesign(.rounded)

                            HStack(spacing: 8) {
                                FilterChip(
                                    title: "Any",
                                    isSelected: filterOptions.skillLevel == nil
                                ) {
                                    filterOptions.skillLevel = nil
                                }

                                ForEach(SkillLevel.allCases, id: \.self) { level in
                                    FilterChip(
                                        title: level.displayName,
                                        isSelected: filterOptions.skillLevel == level
                                    ) {
                                        filterOptions.skillLevel = level
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Distance")
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                Spacer()
                                Text("\(Int(filterOptions.maxDistance)) km")
                                    .font(.subheadline)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                            }

                            Slider(value: $filterOptions.maxDistance, in: 1...100, step: 1)
                                .tint(AppTheme.accentGreen)
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Date")
                                .font(.headline)
                                .fontDesign(.rounded)

                            HStack(spacing: 8) {
                                ForEach(GameFilterOptions.DateRange.allCases, id: \.self) { range in
                                    FilterChip(
                                        title: range.rawValue,
                                        isSelected: filterOptions.dateRange == range
                                    ) {
                                        filterOptions.dateRange = range
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            Button("Apply Filters") {
                                onApply()
                                dismiss()
                            }
                            .buttonStyle(AppPrimaryButtonStyle())

                            Button("Reset") {
                                filterOptions = .default
                            }
                            .buttonStyle(AppSecondaryButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontDesign(.rounded)
                        .foregroundStyle(AppTheme.gradient)
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? AnyShapeStyle(AppTheme.gradient) : AnyShapeStyle(Color(.systemGray6)))
            )
        }
    }
}
