//
//  ErrorBanner.swift
//  PickupPlay
//
import SwiftUI

struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold))

            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Spacer()

            if let onDismiss = onDismiss {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        onDismiss()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 20))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accentRose, AppTheme.accentRose.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppTheme.accentRose.opacity(0.3), radius: 12, y: 6)
        )
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct ErrorBannerModifier: ViewModifier {
    let errorMessage: String?
    var onDismiss: (() -> Void)? = nil

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if let message = errorMessage {
                ErrorBanner(message: message, onDismiss: onDismiss)
                    .animation(.spring(response: 0.4), value: errorMessage)
            }
            content
        }
    }
}

extension View {
    func errorBanner(_ message: String?, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(ErrorBannerModifier(errorMessage: message, onDismiss: onDismiss))
    }

    func errorBanner(message: Binding<String?>) -> some View {
        modifier(ErrorBannerModifier(errorMessage: message.wrappedValue, onDismiss: {
            message.wrappedValue = nil
        }))
    }
}

#Preview {
    VStack {
        ErrorBanner(message: "Something went wrong. Please try again.") {
            print("Dismissed")
        }
        Spacer()
    }
}
