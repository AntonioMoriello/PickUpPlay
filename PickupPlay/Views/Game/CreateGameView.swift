//
//  CreateGameView.swift
//  PickupPlay
//
import SwiftUI
import MapKit

struct CreateGameView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var gameViewModel = GameViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false
    @State private var createdGameId: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        StepProgressIndicator(currentStep: gameViewModel.formStep, totalSteps: 4)
                            .padding(.top, 16)

                        switch gameViewModel.formStep {
                        case 0:
                            sportSelectionStep
                        case 1:
                            detailsStep
                        case 2:
                            venueSelectionStep
                        case 3:
                            reviewStep
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if gameViewModel.formStep > 0 {
                        Button("Back") {
                            withAnimation { gameViewModel.formStep -= 1 }
                        }
                        .fontDesign(.rounded)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .fontDesign(.rounded)
                }
            }
            .onAppear {
                Task { await gameViewModel.initializeCreateForm() }
            }
            .alert("Game Created!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your game has been published and is now visible to nearby players.")
            }
            .errorBanner(message: $gameViewModel.errorMessage)
            .loading(isLoading: gameViewModel.isLoading)
        }
    }

    private var stepTitle: String {
        switch gameViewModel.formStep {
        case 0: return "Choose Sport"
        case 1: return "Game Details"
        case 2: return "Select Venue"
        case 3: return "Review & Publish"
        default: return "Create Game"
        }
    }

    private var sportSelectionStep: some View {
        VStack(spacing: 20) {
            Text("What sport are you playing?")
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Sport.allSports) { sport in
                    Button {
                        gameViewModel.formData.sportId = sport.id
                        gameViewModel.formData.maxPlayers = sport.maxPlayers
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(gameViewModel.formData.sportId == sport.id
                                        ? AnyShapeStyle(AppTheme.gradient)
                                        : AnyShapeStyle(AppTheme.accentGreen.opacity(0.1)))
                                    .frame(width: 52, height: 52)
                                Image(systemName: sport.iconName)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(gameViewModel.formData.sportId == sport.id ? .white : AppTheme.accentGreen)
                            }
                            Text(sport.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .glassCard(padding: 0)
                    }
                }
            }
            .padding(.horizontal, 16)

            if !gameViewModel.formData.sportId.isEmpty {
                Button("Next") {
                    withAnimation { gameViewModel.formStep = 1 }
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, 20)
            }
        }
    }

    private var detailsStep: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Game Title")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                TextField("e.g., Sunday Basketball Pickup", text: $gameViewModel.formData.title)
                    .modernInput()
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                TextField("Tell players about the game...", text: $gameViewModel.formData.description, axis: .vertical)
                    .lineLimit(3...6)
                    .modernInput()
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("Date & Time")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                DatePicker("", selection: $gameViewModel.formData.dateTime, in: Date()...)
                    .datePickerStyle(.graphical)
                    .tint(AppTheme.accentGreen)
                    .glassCard()
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Max Players")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                    Spacer()
                    Text("\(gameViewModel.formData.maxPlayers)")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundStyle(AppTheme.gradient)
                }
                Stepper("", value: $gameViewModel.formData.maxPlayers, in: 2...50)
                    .labelsHidden()
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("Skill Level")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                HStack(spacing: 8) {
                    ForEach(SkillLevel.allCases, id: \.self) { level in
                        Button {
                            gameViewModel.formData.skillLevel = level
                        } label: {
                            Text(level.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .foregroundColor(gameViewModel.formData.skillLevel == level ? .white : .primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(gameViewModel.formData.skillLevel == level
                                            ? AnyShapeStyle(AppTheme.gradient)
                                            : AnyShapeStyle(Color(.systemGray6)))
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            Button("Next") {
                withAnimation { gameViewModel.formStep = 2 }
            }
            .buttonStyle(AppPrimaryButtonStyle(isEnabled: !gameViewModel.formData.title.isEmpty))
            .disabled(gameViewModel.formData.title.isEmpty)
            .padding(.horizontal, 20)
        }
    }

    private var venueSelectionStep: some View {
        VStack(spacing: 16) {
            if gameViewModel.nearbyVenues.isEmpty {
                EmptyStateView(
                    icon: "mappin.slash",
                    title: "No Venues Found",
                    message: "No venues nearby. Try expanding your search radius."
                )
            } else {
                ForEach(gameViewModel.nearbyVenues) { venue in
                    VenueCardView(venue: venue, onTap: {
                        gameViewModel.setVenue(venue)
                    })
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                            .strokeBorder(
                                gameViewModel.selectedVenue?.id == venue.id ? AppTheme.accentGreen : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal, 16)
                }
            }

            if gameViewModel.selectedVenue != nil {
                Button("Next") {
                    withAnimation { gameViewModel.formStep = 3 }
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, 20)
            }
        }
    }

    private var reviewStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                ReviewRow(icon: "sportscourt.fill", label: "Sport",
                          value: Sport.allSports.first(where: { $0.id == gameViewModel.formData.sportId })?.name ?? "")
                Divider()
                ReviewRow(icon: "textformat", label: "Title", value: gameViewModel.formData.title)
                Divider()
                ReviewRow(icon: "calendar", label: "Date", value: gameViewModel.formData.dateTime.formatted(date: .abbreviated, time: .shortened))
                Divider()
                ReviewRow(icon: "person.2.fill", label: "Max Players", value: "\(gameViewModel.formData.maxPlayers)")
                Divider()
                ReviewRow(icon: "star.fill", label: "Skill Level", value: gameViewModel.formData.skillLevel.displayName)
                Divider()
                ReviewRow(icon: "mappin.circle.fill", label: "Venue", value: gameViewModel.selectedVenue?.name ?? "")
            }
            .padding(20)
            .glassCard(padding: 0)
            .padding(.horizontal, 16)

            Button("Publish Game") {
                Task {
                    guard let userId = authViewModel.currentUser?.id else { return }
                    if let gameId = await gameViewModel.createGame(userId: userId) {
                        createdGameId = gameId
                        showSuccess = true
                    }
                }
            }
            .buttonStyle(AppPrimaryButtonStyle())
            .padding(.horizontal, 20)
        }
    }
}

struct ReviewRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.gradient)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
        }
    }
}
