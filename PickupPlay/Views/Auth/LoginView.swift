//
//  LoginView.swift
//  PickupPlay
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
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

                            Image(systemName: "sportscourt.fill")
                                .font(.system(size: 34, weight: .medium))
                                .foregroundStyle(AppTheme.gradient)
                        }

                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Sign in to continue playing")
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(AppTheme.gradient)
                                    .font(.system(size: 16))
                                TextField("your@email.com", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .focused($focusedField, equals: .email)
                            }
                            .modernInput(isFocused: focusedField == .email)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(AppTheme.gradient)
                                    .font(.system(size: 16))
                                SecureField("Enter your password", text: $password)
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                            }
                            .modernInput(isFocused: focusedField == .password)
                        }

                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showForgotPassword = true
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .foregroundStyle(AppTheme.gradient)
                        }
                    }
                    .glassCard()
                    .padding(.horizontal)

                    Button {
                        Task {
                            await authViewModel.signIn(email: email, password: password)
                        }
                    } label: {
                        Text("Sign In")
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
        .loading(authViewModel.isLoading, message: "Signing in...")
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
