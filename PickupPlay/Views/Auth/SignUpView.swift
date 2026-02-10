//
//  SignUpView.swift
//  PickupPlay
//
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case name, email, password, confirm }

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var passwordError: String? {
        if !password.isEmpty && password.count < 6 {
            return "Password must be at least 6 characters"
        }
        if !confirmPassword.isEmpty && password != confirmPassword {
            return "Passwords do not match"
        }
        return nil
    }

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accentGreen.opacity(0.12))
                                .frame(width: 80, height: 80)

                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 34, weight: .medium))
                                .foregroundStyle(AppTheme.gradient)
                        }

                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Join the PickupPlay community")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    if let error = authViewModel.errorMessage {
                        ErrorBanner(message: error) {
                            authViewModel.errorMessage = nil
                        }
                    }

                    VStack(spacing: 20) {
                        FormField(
                            label: "Display Name",
                            icon: "person.fill",
                            placeholder: "Your name",
                            text: $displayName,
                            isFocused: focusedField == .name
                        )
                        .focused($focusedField, equals: .name)

                        FormField(
                            label: "Email",
                            icon: "envelope.fill",
                            placeholder: "your@email.com",
                            text: $email,
                            keyboardType: .emailAddress,
                            contentType: .emailAddress,
                            autocapitalization: false,
                            isFocused: focusedField == .email
                        )
                        .focused($focusedField, equals: .email)

                        SecureFormField(
                            label: "Password",
                            icon: "lock.fill",
                            placeholder: "At least 6 characters",
                            text: $password,
                            isFocused: focusedField == .password
                        )
                        .focused($focusedField, equals: .password)

                        SecureFormField(
                            label: "Confirm Password",
                            icon: "lock.shield.fill",
                            placeholder: "Re-enter password",
                            text: $confirmPassword,
                            isFocused: focusedField == .confirm
                        )
                        .focused($focusedField, equals: .confirm)

                        if let error = passwordError {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(AppTheme.accentRose)
                                    .font(.caption)
                                Text(error)
                                    .font(.caption)
                                    .fontDesign(.rounded)
                                    .foregroundColor(AppTheme.accentRose)
                                Spacer()
                            }
                        }
                    }
                    .glassCard()
                    .padding(.horizontal)

                    Button {
                        Task {
                            await authViewModel.signUp(
                                email: email,
                                password: password,
                                displayName: displayName.trimmingCharacters(in: .whitespaces)
                            )
                        }
                    } label: {
                        Text("Create Account")
                    }
                    .buttonStyle(AppPrimaryButtonStyle(isEnabled: isFormValid))
                    .disabled(!isFormValid)
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .loading(authViewModel.isLoading, message: "Creating account...")
    }
}

struct FormField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var autocapitalization: Bool = true
    var isFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.gradient)
                    .font(.system(size: 16))
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(contentType)
                    .autocapitalization(autocapitalization ? .words : .none)
                    .disableAutocorrection(!autocapitalization)
            }
            .modernInput(isFocused: isFocused)
        }
    }
}

struct SecureFormField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.gradient)
                    .font(.system(size: 16))
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
            }
            .modernInput(isFocused: isFocused)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
