//
//  EmptyStateView.swift
//  PickupPlay
//
import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.accentGreen.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(AppTheme.gradient)
            }

            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)

            Text(message)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, 60)
            }

            Spacer()
        }
    }
}
