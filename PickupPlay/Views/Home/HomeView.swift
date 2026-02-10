//
//  HomeView.swift
//  PickupPlay
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var animateCards = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome back,")
                                .font(.title3)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                            Text(authViewModel.currentUser?.displayName ?? "Player")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.gradient)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        HStack(spacing: 12) {
                            QuickStatCard(
                                title: "Games",
                                value: "\(authViewModel.currentUser?.gamesPlayed ?? 0)",
                                icon: "gamecontroller.fill",
                                color: AppTheme.accentCyan
                            )
                            QuickStatCard(
                                title: "Sports",
                                value: "\(authViewModel.currentUser?.sportSkills.count ?? 0)",
                                icon: "sportscourt.fill",
                                color: AppTheme.accentGreen
                            )
                            QuickStatCard(
                                title: "Rating",
                                value: String(format: "%.1f", authViewModel.currentUser?.reliabilityScore ?? 5.0),
                                icon: "star.fill",
                                color: AppTheme.accentAmber
                            )
                        }
                        .padding(.horizontal, 16)
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)

                        VStack(spacing: 16) {
                            SectionHeader(title: "Nearby Games", icon: "mappin.and.ellipse")

                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.accentGreen.opacity(0.08))
                                        .frame(width: 80, height: 80)

                                    Image(systemName: "map.fill")
                                        .font(.system(size: 32, weight: .medium))
                                        .foregroundStyle(AppTheme.gradient)
                                }

                                Text("Game discovery coming soon")
                                    .font(.headline)
                                    .fontDesign(.rounded)

                                Text("You'll see nearby games here with a map view, filters, and quick join.")
                                    .font(.subheadline)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .glassCard(padding: 0)
                            .padding(.horizontal, 16)
                        }
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    animateCards = true
                }
            }
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .glassCard(padding: 0)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.gradient)
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
