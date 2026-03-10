//
//  LoadingOverlay.swift
//  PickupPlay
//
import SwiftUI

struct LoadingOverlay: View {
    var message: String = "Loading..."
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.accentGreen.opacity(0.2), lineWidth: 4)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: 0.65)
                        .stroke(
                            AppTheme.gradient,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(
                            .linear(duration: 0.8).repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }

                Text(message)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    var message: String = "Loading..."

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)

            if isLoading {
                LoadingOverlay(message: message)
            }
        }
    }
}

extension View {
    func loading(_ isLoading: Bool, message: String = "Loading...") -> some View {
        modifier(LoadingModifier(isLoading: isLoading, message: message))
    }

    func loading(isLoading: Bool, message: String = "Loading...") -> some View {
        modifier(LoadingModifier(isLoading: isLoading, message: message))
    }
}

#Preview {
    ZStack {
        Color.blue
        Text("Content behind loading")
            .foregroundColor(.white)
    }
    .loading(true)
}
