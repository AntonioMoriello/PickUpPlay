//
//  WelcomeView.swift
//  PickupPlay
//
import SwiftUI

struct WelcomeView: View {
    @State private var animateContent = false
    @State private var animateBackground = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(AppTheme.gradient)
                                .frame(width: 120, height: 120)
                                .blur(radius: 30)
                                .opacity(0.5)

                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(AppTheme.gradient)
                                .frame(width: 110, height: 110)
                                .shadow(color: AppTheme.accentGreen.opacity(0.4), radius: 20, y: 10)

                            Image(systemName: "sportscourt.fill")
                                .font(.system(size: 48, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animateContent ? 1.0 : 0.6)
                        .opacity(animateContent ? 1.0 : 0.0)

                        VStack(spacing: 8) {
                            Text("PickupPlay")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.gradient)

                            Text("Find your game. Play your way.")
                                .font(.title3)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                        }
                    }
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 30)

                    Spacer()

                    VStack(spacing: 12) {
                        FeatureRow(
                            icon: "mappin.and.ellipse",
                            title: "Discover",
                            text: "Find games near you"
                        )
                        FeatureRow(
                            icon: "person.3.fill",
                            title: "Connect",
                            text: "Join teams and play"
                        )
                        FeatureRow(
                            icon: "chart.bar.fill",
                            title: "Compete",
                            text: "Track your stats"
                        )
                    }
                    .padding(.horizontal, 28)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 20)

                    Spacer()

                    VStack(spacing: 14) {
                        NavigationLink(destination: SignUpView()) {
                            Text("Create Account")
                        }
                        .buttonStyle(AppPrimaryButtonStyle())

                        NavigationLink(destination: LoginView()) {
                            Text("Sign In")
                        }
                        .buttonStyle(AppSecondaryButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 20)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    animateContent = true
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGreen.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.gradient)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)

                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    WelcomeView()
}
