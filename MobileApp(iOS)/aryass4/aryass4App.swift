
import SwiftUI

@main
struct aryass4App: App {
    @State private var showLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // 3 seconds delay
                            showLaunchScreen = false
                        }
                    }
            } else {
                SearchForm()
            }
        }
    }
}

// ... (rest of your LaunchScreen and SearchForm code)
