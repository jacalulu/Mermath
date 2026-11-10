import SwiftUI

/// One poppable reward bubble from the tollbooth burst.
struct BonusBubble: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let born: Double
}

/// The tollbooth payout, shared by every dive: when `trigger` (the pearl
/// count) rises, six bubbles shower out around `origin` and drift upward,
/// wobbling invitingly. Each pop plays the next rising note. They are pure
/// reward - popping none costs nothing. Place in a full-stage container.
struct BonusBubbleField: View {
    let t: Double
    /// Fires a new burst when it increases (the pearl count).
    let trigger: Int
    /// Where the burst comes from, evaluated at spawn time.
    let origin: CGPoint
    let scale: CGFloat
    let playNote: (Int) -> Void

    @State private var bubbles: [BonusBubble] = []
    @State private var pops = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let spread: [(CGFloat, CGFloat)] = [
        (-85, -10), (70, -45), (-25, 55), (95, 35), (-120, 60), (35, 100),
    ]

    var body: some View {
        ZStack {
            ForEach(bubbles) { b in
                if t >= b.born && t < b.born + 8 {
                    let age = t - b.born
                    Button {
                        playNote(pops)
                        pops += 1
                        withMotion(.easeOut(duration: 0.2)) {
                            bubbles.removeAll { $0.id == b.id }
                        }
                    } label: {
                        ArtImage("props/bubble.png")
                            .frame(width: 52 * scale, height: 52 * scale)
                            .opacity(age > 7 ? (8 - age) : 1)
                            // An inviting wobble, so small fingers know
                            .scaleEffect(Wave.alternate(t, from: 0.92, to: 1.1, duration: 0.7, delay: Double(b.id) * 0.3))
                    }
                    .buttonStyle(.plain)
                    .contentShape(Circle().inset(by: -10 * scale))
                    .transition(.scale.combined(with: .opacity))
                    .position(
                        x: (b.x + sin(t * 2 + Double(b.id)) * 8) * scale,
                        y: (b.y - age * 14) * scale
                    )
                }
            }
        }
        .onChange(of: trigger) { old, new in
            guard new > old, !reduceMotion else { return }
            bubbles = Self.spread.enumerated().map { i, d in
                BonusBubble(
                    id: new * 10 + i,
                    x: min(max(origin.x + d.0, 60), 740),
                    y: min(max(origin.y + d.1, 150), 540),
                    born: t + Double(i) * 0.1
                )
            }
        }
    }
}
