import SwiftUI

struct AuthView: View {
    @ObservedObject var authController: AuthController

    var body: some View {
        ZStack {
            Neon.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("PulseFit")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.white)

                VStack(spacing: 12) {
                    TextField("Email", text: $authController.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $authController.password)
                        .textFieldStyle(.roundedBorder)

                    if let error = authController.errorMessage {
                        Text(error).font(.caption).foregroundStyle(.red)
                    }

                    HStack(spacing: 12) {
                        Button(authController.isLoading ? "Signing In..." : "Sign In") {
                            Task { await authController.signIn() }
                        }
                        .disabled(authController.isLoading)
                        .neonPrimaryButton()

                        Button("Sign Up") {
                            Task { await authController.signUp() }
                        }
                        .disabled(authController.isLoading)
                        .neonSecondaryButton()
                    }
                }
                .neonCard()
                .padding(.horizontal, 16)
            }
        }
        .tint(Neon.neon)
    }
}
