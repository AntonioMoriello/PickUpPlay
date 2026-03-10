//
//  SkillLevelBadge.swift
//  PickupPlay
//
import SwiftUI

struct SkillLevelBadge: View {
    let level: SkillLevel

    private var color: Color {
        switch level {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.iconName)
                .font(.caption2)
            Text(level.displayName)
                .font(.caption2)
                .fontWeight(.medium)
                .fontDesign(.rounded)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(color.opacity(0.1)))
    }
}
