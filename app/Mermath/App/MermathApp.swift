import SwiftUI

@main
struct MermathApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}
