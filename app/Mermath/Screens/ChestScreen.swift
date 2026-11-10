import SwiftUI

/// "10 pearls! The chest is open." The earned item floats and tilts in the
/// chest's warm light while the mermaid cheers. Ported from
/// reference/html/treasure-chest.html.
struct ChestScreen: View {
    let child: ChildID?
    let earned: GrottoItem?
    var onPlace: () -> Void = {}
    var onMap: () -> Void = {}

    @Environment(\.stage) private var m
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Clock time when the screen appeared: drives the opening overture
    /// (pearls drain into the lock, sparkles count down, then the reveal).
    @State private var t0: Double?

    var body: some View {
        let s = m.scale
        MotionClock { t in
            // Overture progress: 0 -> 1 over ~2s (instant under Reduce Motion)
            let ov = reduceMotion ? 1.0 : min(1, max(0, (t - (t0 ?? t)) / 2.0))
            ZStack {
                // Scenery (bleeds to the physical edges)
                Group {
                    ArtImage("scenes/treasure-chest/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t)
                        .stage(x: 0, y: 0, w: 800, h: 340)
                    KelpLayer(t: t, path: "scenes/treasure-chest/kelp-far.png",
                              from: -0.8, to: 0.9, duration: 7, pivot: UnitPoint(x: 0.5, y: 1))
                        .opacity(0.75)
                        .stage(x: 126, y: 0, w: 640, h: 600)
                    KelpLayer(t: t, path: "scenes/treasure-chest/kelp-mid.png",
                              from: 1.3, to: -1.4, duration: 6, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 36, y: 0, w: 720, h: 600)
                    KelpLayer(t: t, path: "scenes/home/kelp-left.png",
                              from: -1.7, to: 1.3, duration: 5, pivot: UnitPoint(x: 0, y: 1))
                        .stage(x: 0, y: 0, w: 260, h: 600)
                    KelpLayer(t: t, path: "scenes/home/kelp-right.png",
                              from: 1.5, to: -1.4, duration: 5.6, pivot: UnitPoint(x: 1, y: 1))
                        .stage(x: 540, y: 0, w: 260, h: 600)
                    ArtImage("scenes/treasure-chest/foreground.png")
                        .stage(x: 0, y: 442, w: 800, h: 158)
                    KelpLayer(t: t, path: "scenes/treasure-chest/seagrass.png",
                              from: -7, to: 7, duration: 2.8, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 146, y: 532, w: 518, h: 66)
                    RisingBubble(t: t, duration: 9, scale: s)
                        .stage(x: 596, y: 560, w: 28, h: 28)
                    RisingBubble(t: t, duration: 12, delay: 3, scale: s)
                        .stage(x: 250, y: 580, w: 22, h: 22)
                }
                .bleed()

                // The chest in its pulsing warm light
                GlowPulse(t: t, color: Color(hex: 0xFFE9A8), fromOpacity: 0.45, toOpacity: 1, duration: 1.8)
                    .stage(x: 240, y: 190, w: 320, h: 300)
                ArtImage("scenes/treasure-chest/chest-lid.png")
                    .stage(x: 284, y: 244, w: 232, h: 144)
                ArtImage("scenes/treasure-chest/chest-box.png")
                    .stage(x: 282, y: 330, w: 236, h: 152)

                // The overture: the ten pearls you earned drain one by one
                // into the chest's lock, sparkles build, then the reveal.
                if ov < 1 {
                    ForEach(0..<10, id: \.self) { i in
                        let p = min(1, max(0, (ov * 2.0 - Double(i) * 0.09) / 0.55))
                        if p > 0 && p < 1 {
                            let fx = 486.0 + Double(i) * 28
                            let ease = p * p * (3 - 2 * p)
                            ArtImage("ui/pearl.png")
                                .shadow(color: Tokens.Palette.pearl.opacity(0.9), radius: 6 * s)
                                .stage(x: fx + (400 - fx) * ease - 11,
                                       y: 48 + (402 - 48) * ease - sin(.pi * p) * 60 - 11,
                                       w: 22, h: 22)
                        }
                    }
                    // Sparkle countdown at the lock as the last pearls land
                    if ov > 0.55 {
                        let k = (ov - 0.55) / 0.45
                        FourPointStar()
                            .fill(Tokens.Palette.pearl)
                            .scaleEffect(0.5 + abs(sin(k * 3 * .pi)) * 0.9)
                            .opacity(0.4 + abs(sin(k * 3 * .pi)) * 0.6)
                            .stage(x: 378, y: 380, w: 44, h: 44)
                    }
                    // The flash as it bursts open
                    if ov > 0.92 {
                        Color.white
                            .opacity((ov - 0.92) / 0.08 * 0.7)
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()
                            .allowsHitTesting(false)
                    }
                }

                // What the chest holds: not the treasure itself, but the map
                // to it, floating and tilting in the column of light.
                if earned != nil && ov >= 1 {
                    MapReveal(t: t, scale: s)
                        .frame(width: 140 * s, height: 140 * s)
                        .stage(x: 330, y: 95, w: 140, h: 140)
                        .transition(.opacity)
                }

                // Twinkles around the chest and lamp
                TwinkleStar(t: t, duration: 2.2).stage(x: 258, y: 286, w: 22, h: 22)
                TwinkleStar(t: t, duration: 2.6, delay: 0.7).stage(x: 528, y: 302, w: 18, h: 18)
                TwinkleStar(t: t, duration: 2, delay: 1.2).stage(x: 486, y: 132, w: 20, h: 20)
                TwinkleStar(t: t, duration: 2.8, delay: 0.3).stage(x: 304, y: 150, w: 16, h: 16)
                TwinkleStar(t: t, duration: 2.4, delay: 1.6, color: .white).stage(x: 392, y: 318, w: 16, h: 16)

                // The mermaid, waving a little faster than usual
                if let child {
                    SisterView(spec: child.puppet, t: t, scale: s, armDuration: 1.1)
                        .frame(width: 230 * s, height: 264 * s)
                        .stage(x: 22, y: 190, w: 230, h: 264)
                }

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                MapButton(scale: s, action: onMap)
                    .stage(x: 22, y: 20, w: 66, h: 66)

                Text("10 pearls! The chest is open.")
                    .font(baloo(26, weight: 700, scale: s))
                    .foregroundStyle(Tokens.Palette.midnight)
                    .padding(.top, 7 * s)
                    .padding(.bottom, 3 * s)
                    .padding(.horizontal, 26 * s)
                    .background(Capsule().fill(Tokens.Palette.pearl))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                    .stageTopCenter(y: 26)

                SolvedPanel(
                    text: earned == nil ? "Your grotto is full of treasures!" : "You found a treasure map!",
                    buttonTitle: earned == nil ? "See my grotto" : "Follow the map",
                    scale: s,
                    action: onPlace
                )
                .opacity(ov >= 1 ? 1 : 0)
                .stageBottomCenter(bottom: 24)
            }
            .onChange(of: Int(t * 20)) {
                if t0 == nil { t0 = t }
            }
        }
    }
}

/// The floating map: glow behind, gentle rise and tilt, per the lamp's old
/// reveal motion (up 10px, -5 to 5deg, 3.4s).
private struct MapReveal: View {
    let t: Double
    let scale: CGFloat

    var body: some View {
        let frac = Wave.cycleFraction(t, duration: 3.4) ?? 0
        ZStack {
            GlowPulse(t: t, color: Color(hex: 0xFFE9A8), fromOpacity: 0.45, toOpacity: 1, duration: 1.8)
                .scaleEffect(1.8)
            ArtImage("ui/icon-map.png")
                .frame(width: 110 * scale, height: 110 * scale)
        }
        .offset(y: Wave.keyframes(frac, [(0, 0), (0.5, -10), (1, 0)]) * scale)
        .rotationEffect(.degrees(Wave.keyframes(frac, [(0, -5), (0.5, 5), (1, -5)])))
    }
}
