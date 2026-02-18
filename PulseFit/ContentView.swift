import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo, .purple, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                Text("PulseFit")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("Clean architecture scaffold generated. Open the project navigator to add new folders/files to the target.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
