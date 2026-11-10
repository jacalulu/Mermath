import SwiftUI

/// Smoke-test root: Midnight background with the pearl wordmark.
/// Replaced by the route switch as screens are built.
struct RootView: View {
    var body: some View {
        ZStack {
            Color(red: 6 / 255, green: 26 / 255, blue: 51 / 255)
                .ignoresSafeArea()
            ArtImage("brand/wordmark-pearl.png")
                .aspectRatio(contentMode: .fit)
                .frame(width: 456)
        }
    }
}
