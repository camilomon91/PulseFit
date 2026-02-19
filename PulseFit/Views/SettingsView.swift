import SwiftUI

struct SettingsView: View {
    @ObservedObject var authController: AuthController

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Signed in as")
                    .font(.headline)
                Text(authController.email.isEmpty ? "Current user" : authController.email)
                    .foregroundStyle(.secondary)

                Button("Sign Out") {
                    Task { await authController.signOut() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .glassCard()
            .padding()
            .navigationTitle("Account")
        }
    }
}
