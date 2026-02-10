//
//  ForgotPasswordView.swift
//  PickupPlay
//
import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var emailSent = false
    @FocusState private var emailFocused: Bool

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: 28) {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    emailSent
                                    ? AppTheme.accentGreen.opacity(0.15)
                                    : AppTheme.accentCyan.opacity(0.12)
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: emailSent ? "checkmark.circle.fill" : "lock.rotation")
                                .font(.system(size: 44, weight: .medium))
                                .foregroundStyle(
                                    emailSent
                                    ? AnyShapeStyle(AppTheme.accentGreen)
                                    : AnyShapeStyle(AppTheme.gradient)
                                )
                                .contentTransition(.symbolEffect(.replace))
                        }

                        Text(emailSent ? "Email Sent!" : "Reset Password")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text(emailSent ?
                             "Check your inbox for password reset instructions." :
                             "Enter your email and we'll send you a reset link.")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)

                    if !emailSent {
                        if let error = authViewModel.errorMessage {
                            ErrorBanner(message: error) {
                                authViewModel.errorMessage = nil
                            }
                        }

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
                                    .focused($emailFocused)
                            }
                            .modernInput(isFocused: emailFocused)
                        }
                        .glassCard()
                        .padding(.horizontal)

                        Button {
                            Task {
                                await authViewModel.resetPassword(email: email)
                                if authViewModel.errorMessage == nil {
                                    withAnimation(.spring(response: 0.5)) {
                                        emailSent = true
                                    }
                                }
                            }
                        } label: {
                            Text("Send Reset Link")
                        }
                        .buttonStyle(AppPrimaryButtonStyle(isEnabled: isFormValid))
                        .disabled(!isFormValid)
                        .padding(.horizontal, 24)
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Back to Login")
                        }
                        .buttonStyle(AppPrimaryButtonStyle())
                        .padding(.horizontal, 24)
                    }

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                }
            }
            .loading(authViewModel.isLoading, message: "Sending reset link...")
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthViewModel())
}
