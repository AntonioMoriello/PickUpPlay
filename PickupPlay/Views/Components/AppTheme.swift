//
//  AppTheme.swift
//  PickupPlay
//
import SwiftUI

enum AppTheme {

    static let accentGreen = Color(red: 0.20, green: 0.83, blue: 0.60)
    static let accentCyan = Color(red: 0.02, green: 0.71, blue: 0.83)
    static let accentAmber = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let accentRose = Color(red: 0.96, green: 0.24, blue: 0.37)

    static let gradient = LinearGradient(
        colors: [accentGreen, accentCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradientHorizontal = LinearGradient(
        colors: [accentGreen, accentCyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let disabledGradient = LinearGradient(
        colors: [Color(.systemGray3), Color(.systemGray4)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 16
    static let inputRadius: CGFloat = 14
}

struct AppPrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontDesign(.rounded)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if isEnabled {
                        AppTheme.gradientHorizontal
                    } else {
                        AppTheme.disabledGradient
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous))
            .shadow(
                color: isEnabled ? AppTheme.accentGreen.opacity(0.35) : .clear,
                radius: isEnabled ? 12 : 0,
                y: 6
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct AppSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontDesign(.rounded)
            .foregroundStyle(AppTheme.gradient)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous)
                    .strokeBorder(AppTheme.gradient, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GlassCard: ViewModifier {
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 16, y: 8)
    }
}

extension View {
    func glassCard(padding: CGFloat = 20) -> some View {
        modifier(GlassCard(padding: padding))
    }
}

struct ModernInputStyle: ViewModifier {
    var isFocused: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.inputRadius, style: .continuous)
                    .fill(Color(.systemGray6).opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.inputRadius, style: .continuous)
                    .strokeBorder(
                        isFocused ? AnyShapeStyle(AppTheme.gradient) : AnyShapeStyle(Color(.systemGray4).opacity(0.3)),
                        lineWidth: isFocused ? 1.5 : 0.5
                    )
            )
    }
}

extension View {
    func modernInput(isFocused: Bool = false) -> some View {
        modifier(ModernInputStyle(isFocused: isFocused))
    }
}

struct AnimatedMeshBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color(.systemBackground)

            Circle()
                .fill(AppTheme.accentGreen.opacity(0.15))
                .frame(width: 340, height: 340)
                .blur(radius: 100)
                .offset(x: animate ? -40 : 40, y: animate ? -60 : 60)

            Circle()
                .fill(AppTheme.accentCyan.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(x: animate ? 60 : -60, y: animate ? 40 : -40)

            Circle()
                .fill(Color.purple.opacity(0.07))
                .frame(width: 220, height: 220)
                .blur(radius: 80)
                .offset(x: animate ? -30 : 50, y: animate ? 70 : -50)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

struct StepProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? AnyShapeStyle(AppTheme.gradient) : AnyShapeStyle(Color(.systemGray5)))
                    .frame(height: 4)
                    .animation(.spring(response: 0.4), value: currentStep)
            }
        }
        .padding(.horizontal, 40)
    }
}
