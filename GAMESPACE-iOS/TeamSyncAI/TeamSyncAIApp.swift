import SwiftUI

@main
struct TeamSyncAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthViewModel())
                .environmentObject(TeamViewModel())
        }
    }
}
