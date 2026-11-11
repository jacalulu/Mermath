import SwiftUI

/// One poppable party bubble, rising from below the stage.
struct BonusBubble: Identifiable {
    let id: Int
    let x: CGFloat
    let size: CGFloat
    let born: Double
    let speed: Double
    let sway: Double
}

/// A pop's burst: five flung pearls and the running count, said and shown.
struct BubblePopFX: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let at: Double
    let n: Int
}

/// THE BUBBLE PARTY. When `trigger` rises (three right answers in a row), a
/// shower of bubbles - all sizes, all speeds - floats up from the bottom of
/// the screen, wobbling and swaying. It is never announced; the music and the
/// bubbles say it. Each pop plays the next rising note, bursts into little
/// pearls, and counts itself out loud and in a big popping numeral - so the
/// popping is counting practice. Popping none costs nothing.
/// Place in a full-stage container.
struct BonusBubbleField: View {
    let t: Double
    /// Fires a new party when it increases.
    let trigger: Int
    let scale: CGFloat
    /// Called with the running pop count (0-based).
    let onPop: (Int) -> Void

    @State private var bubbles: [BonusBubble] = []
    @State private var fx: [BubblePopFX] = []
    @State private var pops = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Spawn columns, shuffled so the shower feels scattered, never a wall.
    private static let lanes: [CGFloat] = [
        96, 420, 212, 612, 318, 700, 152, 490, 264, 660, 376, 548,
    ]

    var body: some View {
        ZStack {
            ForEach(bubbles) { b in
                let age = t - b.born
                let y = CGFloat(646 - age * b.speed)
                if age >= 0 && y > 36 {
                    PartyBubbleView(bubble: b, t: t, y: y, scale: scale) {
                        fx.append(BubblePopFX(id: b.id, x: b.x, y: y, at: t, n: pops + 1))
                        onPop(pops)
                        pops += 1
                        withMotion(.easeOut(duration: 0.15)) {
                            bubbles.removeAll { $0.id == b.id }
                        }
                    }
                }
            }
            // Pop bursts: pearls fling outward while the count pops up
            ForEach(fx) { f in
                let age = t - f.at
                if age >= 0 && age < 0.7 {
                    PopBurstView(n: f.n, p: age / 0.7, scale: scale)
                        .position(x: f.x * scale, y: f.y * scale)
                        .allowsHitTesting(false)
                }
            }
        }
        .onChange(of: trigger) { (old: Int, new: Int) in
            guard new > old, !reduceMotion else { return }
            pops = 0
            fx = []
            bubbles = Self.spawn(party: new, at: t)
        }
    }

    private static func spawn(party: Int, at t: Double) -> [BonusBubble] {
        var out: [BonusBubble] = []
        for i in 0..<12 {
            let size: CGFloat = 42 + CGFloat((i * 13) % 34)
            let born: Double = t + Double(i) * 0.42
            let speed: Double = 92 + Double((i * 11) % 26)
            let sway: Double = 1.6 + Double(i % 3) * 0.5
            out.append(BonusBubble(id: party * 100 + i, x: lanes[i % lanes.count],
                                   size: size, born: born, speed: speed, sway: sway))
        }
        return out
    }
}

/// One rising, swaying, wobbling bubble of the party.
private struct PartyBubbleView: View {
    let bubble: BonusBubble
    let t: Double
    let y: CGFloat
    let scale: CGFloat
    let pop: () -> Void

    var body: some View {
        let swayX: CGFloat = CGFloat(sin(t * bubble.sway + Double(bubble.id))) * 14
        Button(action: pop) {
            ArtImage("props/bubble.png")
                .frame(width: bubble.size * scale, height: bubble.size * scale)
                // An inviting wobble, so small fingers know
                .scaleEffect(Wave.alternate(t, from: 0.93, to: 1.09, duration: 0.6, delay: Double(bubble.id) * 0.23))
        }
        .buttonStyle(.plain)
        .contentShape(Circle().inset(by: -12 * scale))
        .transition(.scale.combined(with: .opacity))
        .position(x: (bubble.x + swayX) * scale, y: y * scale)
    }
}

/// One pop's 0.7s burst at progress `p`: five flung pearls, the count pops up.
private struct PopBurstView: View {
    let n: Int
    let p: Double
    let scale: CGFloat

    var body: some View {
        let fling: CGFloat = CGFloat(14 + p * 38) * scale
        ZStack {
            ForEach(0..<5, id: \.self) { k in
                let ang = Double(k) * 1.257 - 0.63
                Circle()
                    .fill(Tokens.Palette.pearl)
                    .frame(width: 7 * scale, height: 7 * scale)
                    .opacity(1 - p)
                    .offset(x: CGFloat(cos(ang)) * fling, y: CGFloat(sin(ang)) * fling)
            }
            Text("\(n)")
                .font(baloo(46, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.pearl)
                .shadow(color: Tokens.Palette.midnight.opacity(0.55), radius: 3 * scale, y: 2 * scale)
                .scaleEffect(0.5 + min(1, p * 3.5) * 0.55)
                .opacity(p < 0.72 ? 1 : 1 - (p - 0.72) * 3.6)
                .offset(y: CGFloat(-p * 34) * scale)
        }
    }
}
