import SwiftUI

/// Temporary root while the screens come up: shows the Tide Pool with the
/// reference style-frame state (2 / 4 / 7, target 4, nine pearls) and the
/// StyleFrame tap logic. Replaced by the route switch and DiveSession.
struct RootView: View {
    @State private var state = TidePoolViewState(
        prompt: "Find the number four!",
        choices: [2, 4, 7],
        target: 4,
        pearls: 9
    )

    var body: some View {
        StageView {
            TidePoolScreen(
                state: state,
                onAnswer: { n in
                    withAnimation(.easeOut(duration: 0.35)) {
                        if n == state.target {
                            state.solved = true
                            state.showHint = false
                            state.pearls = 10
                            state.solvedText = "You found four! That makes 10 pearls."
                        } else {
                            state.faded.insert(n)
                            state.showHint = true
                        }
                    }
                },
                onReplay: { state.popTrigger += 1 }
            )
        }
    }
}
