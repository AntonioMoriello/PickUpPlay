import SwiftUI

struct EditGameView: View {
    let game: Game
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var gameViewModel = GameViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var dateTime: Date
    @State private var maxPlayers: Int
    @State private var skillLevel: SkillLevel
    @State private var showCancelConfirm = false
    @State private var showSaveSuccess = false

    init(game: Game) {
        self.game = game
        _title = State(initialValue: game.title)
        _description = State(initialValue: game.description)
        _dateTime = State(initialValue: game.dateTime)
        _maxPlayers = State(initialValue: game.maxPlayers)
        _skillLevel = State(initialValue: game.skillLevel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Game Title")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            TextField("Game title", text: $title)
                                .modernInput()
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            TextField("Description", text: $description, axis: .vertical)
                                .lineLimit(3...6)
                                .modernInput()
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date & Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            DatePicker("", selection: $dateTime, in: Date()...)
                                .datePickerStyle(.compact)
                                .tint(AppTheme.accentGreen)
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Players")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .fontDesign(.rounded)
                                Spacer()
                                Text("\(maxPlayers)")
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(AppTheme.gradient)
                            }
                            Stepper("", value: $maxPlayers, in: max(2, game.currentPlayers)...50)
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
                                        skillLevel = level
                                    } label: {
                                        Text(level.displayName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .fontDesign(.rounded)
                                            .foregroundColor(skillLevel == level ? .white : .primary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(skillLevel == level
                                                        ? AnyShapeStyle(AppTheme.gradient)
                                                        : AnyShapeStyle(Color(.systemGray6)))
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Button("Save Changes") {
                            Task { await saveChanges() }
                        }
                        .buttonStyle(AppPrimaryButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        Button("Cancel Game") {
                            showCancelConfirm = true
                        }
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundColor(AppTheme.accentRose)
                        .padding(.top, 8)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontDesign(.rounded)
                        .foregroundStyle(AppTheme.gradient)
                }
            }
            .alert("Cancel Game?", isPresented: $showCancelConfirm) {
                Button("Cancel Game", role: .destructive) {
                    Task {
                        await gameViewModel.cancelGame(gameId: game.id, organizerId: game.organizerId)
                        dismiss()
                    }
                }
                Button("Keep", role: .cancel) {}
            } message: {
                Text("This will cancel the game for all players. This action cannot be undone.")
            }
            .alert("Saved!", isPresented: $showSaveSuccess) {
                Button("OK") { dismiss() }
            }
            .errorBanner(message: $gameViewModel.errorMessage)
            .loading(isLoading: gameViewModel.isLoading)
        }
    }

    private func saveChanges() async {
        var updated = game
        updated.title = title
        updated.description = description
        updated.dateTime = dateTime
        updated.maxPlayers = maxPlayers
        updated.skillLevel = skillLevel
        await gameViewModel.updateGame(updated)
        if gameViewModel.errorMessage == nil {
            showSaveSuccess = true
        }
    }
}
