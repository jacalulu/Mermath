import SwiftUI

/// One clock per screen: feeds elapsed seconds into pure wave functions.
/// With Reduce Motion on, emits a constant t = 0 so every loop freezes at its
/// initial pose (matching the reference CSS prefers-reduced-motion behavior).
struct MotionClock<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ViewBuilder var content: (Double) -> Content

    private static var epoch: Date { MotionEpoch.shared }

    var body: some View {
        if reduceMotion {
            content(0)
        } else {
            TimelineView(.animation) { timeline in
                content(timeline.date.timeIntervalSince(Self.epoch))
            }
        }
    }
}

/// Shared start so separate clocks stay in phase with each other.
private enum MotionEpoch {
    static let shared = Date()
}
