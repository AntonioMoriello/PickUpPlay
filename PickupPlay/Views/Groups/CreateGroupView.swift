import SwiftUI
import FirebaseAuth

struct CreateGroupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var groupVM = GroupViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var selectedSports: Set<String> = []
    @State private var isPublic = true
    @State private var showSuccess = false

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !selectedSports.isEmpty
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Group Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                        TextField("e.g., Downtown Basketball Crew", text: $name)
                            .modernInput()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                        TextField("What's your group about?", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .modernInput()
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sports")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .padding(.horizontal, 20)

                        SportIconGrid(
                            sports: Sport.allSports,
                            selectedSportIds: $selectedSports
                        )
                        .padding(.horizontal, 16)
                    }

                    Toggle(isOn: $isPublic) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Public Group")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            Text(isPublic ? "Anyone can find and join" : "Invite only")
                                .font(.caption)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(AppTheme.accentGreen)
                    .padding(.horizontal, 20)

                    Button("Create Group") {
                        createGroup()
                    }
                    .buttonStyle(AppPrimaryButtonStyle(isEnabled: isFormValid))
                    .disabled(!isFormValid)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Create Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { dismiss() }
                    .fontDesign(.rounded)
            }
        }
        .alert("Group Created!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your group has been created. Invite friends to join!")
        }
        .loading(isLoading: groupVM.isLoading)
        .errorBanner(message: $groupVM.errorMessage)
    }

    private func createGroup() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid ?? authViewModel.currentUser?.id else {
            groupVM.errorMessage = "Please sign in again to create a group."
            return
        }

        Task {
            if let _ = await groupVM.createGroup(
                name: name,
                description: description,
                sportIds: Array(selectedSports),
                isPublic: isPublic,
                creatorId: userId
            ) {
                showSuccess = true
            }
        }
    }
}
