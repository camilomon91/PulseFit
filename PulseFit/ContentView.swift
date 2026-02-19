import SwiftUI

struct ContentView: View {
    @StateObject private var appController = AppController()

    var body: some View {
        Group {
            if appController.isAuthenticated {
                MainTabView(appController: appController)
            } else {
                AuthView(authController: appController.authController)
            }
        }
        .task {
            await appController.start()
        }
    }
}

#Preview {
    ContentView()
}
