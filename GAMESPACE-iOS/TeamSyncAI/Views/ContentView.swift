import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        if authVM.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
