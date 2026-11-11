import SwiftUI

/// The travelling shot between the chest and the treasure's hiding place: a
/// continuous multiplane swim across the bright journey reef. On the way OUT
/// the open map leads the mermaid; on the way HOME she brings the rescued
/// treasure with her. Tap to skip. Under Reduce Motion it ends immediately.
struct JourneyScreen: View {
    let child: ChildID?
    let earned: GrottoItem?
    /// false: following the map out. true: bringing the treasure home.
    let home: Bool
    var speak: (Prompt) -> Void = { _ in }
    var onDone: () -> Void = {}

    @Environment(\.stage) private var m
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start: Double?
    @State private var spoke = false
    @State private var finished = false
    /// The tap that opened this screen must not also skip it.
    @State private var appeared = Date()

    private static let duration = 6.5

    var body: some View {
        let s = m.scale
        MotionClock { t in
            let tl = t - (start ?? t)
            let p = min(1, tl / Self.duration)
            // ease in and out of the scroll; home runs the reef backwards
            let ease = p * p * (3 - 2 * p)
            let cam = CGFloat(home ? 1 - ease : ease) * 1600
            ZStack {
                Group {
                    ArtImage("scenes/journey/strip-a.jpg")
                        .stage(x: 0 - cam - 1, y: 0, w: 802, h: 600)
                    ArtImage("scenes/journey/strip-b.jpg")
                        .stage(x: 800 - cam - 1, y: 0, w: 802, h: 600)
                    ArtImage("scenes/journey/strip-c.jpg")
                        .stage(x: 1600 - cam - 1, y: 0, w: 802, h: 600)
                    // Foreground coral fans drift by faster for depth
                    ForEach(0..<4, id: \.self) { i in
                        ArtImage("props/coral-fan-\(i % 2 == 0 ? "a" : "b").png")
                            .stage(x: CGFloat(i) * 840 + 300 - cam * 1.4, y: 452, w: 280, h: 220)
                    }
                    Vignette()
                        .stage(x: 0, y: 0, w: 800, h: 600)
                }
                .bleed()

                // The traveller, swimming hard, trailing bubbles
                if let child {
                    let bob = Wave.alternate(t, from: -10, to: 10, duration: 1.7)
                    ForEach(0..<4, id: \.self) { i in
                        let drift = (t * 60 + Double(i) * 37).truncatingRemainder(dividingBy: 150)
                        ArtImage("props/bubble.png")
                            .opacity(max(0, 0.7 - drift / 150))
                            .stage(x: (home ? 470 : 330) + CGFloat(home ? 1 : -1) * (40 + drift),
                                   y: 300 + bob + CGFloat((i * 29) % 70) - 35,
                                   w: 13 + CGFloat(i) * 3, h: 13 + CGFloat(i) * 3)
                    }
                    SisterView(spec: child.puppet, t: t, scale: s, swim: 1)
                        .frame(width: 210 * s, height: 241 * s)
                        .scaleEffect(x: home ? -1 : 1)
                        .rotationEffect(.degrees((home ? -8 : 8) + Wave.alternate(t, from: -3, to: 3, duration: 0.8)))
                        .stage(x: home ? 380 : 300, y: 210 + bob, w: 210, h: 241)
                }

                if home {
                    // The rescued treasure rides along, glowing
                    if let earned {
                        let a = earned.spriteAspect
                        let rw: CGFloat = a > 1.4 ? 76 : 110
                        ArtImage(earned.sprite)
                            .shadow(color: Color(hex: 0xFFD27A, opacity: 0.8), radius: 14 * s)
                            .rotationEffect(.degrees(Wave.alternate(t, from: -6, to: 6, duration: 2.1)))
                            .stage(x: 320, y: 290 + Wave.alternate(t, from: -8, to: 8, duration: 1.7),
                                   w: rw, h: rw * a)
                    }
                } else {
                    // The open map leads the way, just ahead of her nose
                    ArtImage("props/big-map.png")
                        .rotationEffect(.degrees(Wave.alternate(t, from: -4, to: 4, duration: 1.9)))
                        .stage(x: 520, y: 220 + Wave.alternate(t, from: -9, to: 9, duration: 1.5),
                               w: 170, h: 133)
                }

                Text("Tap to skip")
                    .font(baloo(15, weight: 600, scale: s))
                    .foregroundStyle(Tokens.Palette.pearl.opacity(0.65))
                    .stageTopRight(right: 28, y: 28)
            }
            .onChange(of: Int(t * 10)) {
                if start == nil { start = t }
                if !spoke && tl >= 0.4 {
                    spoke = true
                    speak(home ? PromptScript.swimHome : PromptScript.followMap)
                }
                if (tl >= Self.duration + 0.2 || reduceMotion) && !finished {
                    finished = true
                    onDone()
                }
            }
        }
        .contentShape(Rectangle())
        .onAppear { appeared = Date() }
        .onTapGesture {
            guard !finished, Date().timeIntervalSince(appeared) > 0.8 else { return }
            finished = true
            onDone()
        }
    }
}
