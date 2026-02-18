import SwiftUI

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel
    let onAuthenticated: (AuthSession) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.indigo, .purple, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                GlassCard {
                    Text("PulseFit")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $viewModel.password)
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    Toggle("Create a new account", isOn: $viewModel.isSignUp)
                        .foregroundStyle(.white)

                    Button {
                        Task {
                            if let session = await viewModel.submit() {
                                onAuthenticated(session)
                            }
                        }
                    } label: {
                        Text(viewModel.isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.mint)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding(20)
            }
        }
    }
}
