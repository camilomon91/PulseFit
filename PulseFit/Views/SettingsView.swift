import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var authController: AuthController

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                VStack(spacing: 6) {
                    Text("Signed in as")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(authController.email.isEmpty ? "Current user" : authController.email)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }

                Button("Sign Out") {
                    Task { await authController.signOut() }
                }
                .neonPrimaryButton()
            }
            .padding(16)
            .neonCard()
            .padding(16)
            .neonScreenBackground()
            .navigationTitle("Account")
        }
    }
}
