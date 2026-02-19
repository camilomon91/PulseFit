import SwiftUI
import Combine

struct AuthView: View {
    @ObservedObject var authController: AuthController

    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.7), .purple.opacity(0.6), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("PulseFit")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    TextField("Email", text: $authController.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $authController.password)

                    if let error = authController.errorMessage {
                        Text(error).foregroundStyle(.red)
                    }

                    HStack {
                        Button("Sign In") { Task { await authController.signIn() } }
                            .buttonStyle(.borderedProminent)
                        Button("Sign Up") { Task { await authController.signUp() } }
                            .buttonStyle(.bordered)
                    }
                }
                .glassCard()
                .padding(.horizontal)
            }
        }
    }
}
