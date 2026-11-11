import SwiftUI

/// "Where shall we dive?" The map is a real dive, top to bottom: the Tide Pool
/// sits in a rocky shore shelf right under the waterline, a sandy slope leads
/// down to the Coral Reef ledge in open water, and a second cliff falls away
/// into the dark navy Deep Sea in the bottom corner. The crab waits at the
/// pool, the picked sister floats over the reef, and a pearl trail twinkles
/// down the open stretch.
struct ReefMapScreen: View {
    let child: ChildID
    /// Two clean dives (no hints) open the Deep Sea.
    var deepSeaUnlocked = false
    var onDive: (Zone) -> Void = { _ in }
    var onHome: () -> Void = {}
    var speak: (Prompt) -> Void = { _ in }

    @Environment(\.stage) private var m
    @State private var start: Double?
    @State private var invited = false

    var body: some View {
        let s = m.scale
        MotionClock { t in
            let tl = t - (start ?? t)
            ZStack {
                // Scenery (bleeds to the physical edges)
                Group {
                    ArtImage("scenes/reef-map/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t)
                        .stage(x: 0, y: 152, w: 800, h: 240)
                    KelpLayer(t: t, path: "scenes/reef-map/kelp-far.png",
                              from: -0.8, to: 0.9, duration: 7, pivot: UnitPoint(x: 0.5, y: 1))
                        .opacity(0.75)
                        .stage(x: 288, y: 194, w: 368, h: 406)
                    KelpLayer(t: t, path: "scenes/reef-map/kelp-mid.png",
                              from: 1.3, to: -1.4, duration: 6, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 648, y: 192, w: 152, h: 408)
                    FishSwim(t: t, travel: 940, bobDown: 5, bobUp: 6, duration: 32, delay: -4, scale: s)
                        .stage(x: 830, y: 212, w: 40, h: 25)
                    FishSwim(t: t, travel: 940, bobDown: 5, bobUp: 6, duration: 36, delay: -18, scale: s)
                        .stage(x: 830, y: 238, w: 30, h: 19)
                    ArtImage("scenes/reef-map/seabed.png")
                        .stage(x: 0, y: 88, w: 800, h: 512)
                    // The grass spans two ledges, so it holds still here
                    ArtImage("scenes/reef-map/seagrass.png")
                        .stage(x: 294, y: 296, w: 324, h: 130)
                    RisingBubble(t: t, duration: 9, scale: s)
                        .stage(x: 330, y: 430, w: 20, h: 20)
                    RisingBubble(t: t, duration: 12, delay: 3, scale: s)
                        .stage(x: 730, y: 540, w: 22, h: 22)
                }
                .bleed()

                // Pearl trail: it leaves the pool, crosses the waterline, and
                // swoops down to the Coral Reef signpost; the locked drop is dim
                ForEach(Array([(212.0, 150.0), (238, 186), (268, 230), (300, 276)].enumerated()), id: \.offset) { i, dot in
                    TrailDot(opacity: Wave.alternate(t, from: 0.55, to: 1, duration: 1, delay: Double(i) * 0.25), scale: s)
                        .stage(x: dot.0, y: dot.1, w: 17, h: 17)
                }
                ForEach(Array([(578.0, 444.0), (606, 464)].enumerated()), id: \.offset) { _, dot in
                    TrailDot(opacity: 0.4, scale: s, shadow: false)
                        .stage(x: dot.0, y: dot.1, w: 17, h: 17)
                }

                // Tide Pool, hollowed into the DRY shore rock above the
                // waterline: the crab perches on its rim against the sky, and
                // a driftwood sign stands on the rock beside it
                Button(action: { onDive(.tidePool) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 14, y: 40, w: 330, h: 230)
                GlowPulse(t: t)
                    .stage(x: 86, y: 116, w: 150, h: 56)
                CrabView(t: t, scale: s, blinkCycle: 5.1, bobTo: -3)
                    .frame(width: 76 * s, height: 64 * s)
                    .allowsHitTesting(false)
                    .stage(x: 182, y: 84, w: 76, h: 64)
                RisingBubble(t: t, duration: 6, delay: 1.5, scale: s)
                    .stage(x: 148, y: 252, w: 12, h: 12)
                GlassPill(name: "Tide Pool", t: t, scale: s)
                    .stage(x: 174, y: 216, w: 0, h: 0)

                // Coral Reef on the mid-water ledge: the picked sister floats
                // over the coral, her sign planted in the seagrass where the
                // pearl trail ends
                Button(action: { onDive(.coralReef) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 340, y: 210, w: 260, h: 290)
                GlowPulse(t: t, delay: -0.8)
                    .stage(x: 398, y: 346, w: 195, h: 82)
                SisterView(spec: child.puppet, t: t, scale: s)
                    .frame(width: 158 * s, height: 181 * s)
                    .allowsHitTesting(false)
                    .stage(x: 388, y: 220, w: 158, h: 181)
                RisingBubble(t: t, duration: 7, delay: 3.5, scale: s)
                    .stage(x: 398, y: 492, w: 13, h: 13)
                GlassPill(name: "Coral Reef", t: t, scale: s, delay: -1.1)
                    .stage(x: 424, y: 458, w: 0, h: 0)

                // Deep Sea, down the cliff in the dark corner: the padlock
                // hangs on its sign until two clean dives open it
                if deepSeaUnlocked {
                    Button(action: { onDive(.deepSea) }) {
                        Color.clear.contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .stage(x: 602, y: 390, w: 174, h: 186)
                    GlowPulse(t: t, delay: -0.4)
                        .stage(x: 630, y: 468, w: 166, h: 80)
                    GlassPill(name: "Deep Sea", t: t, scale: s, delay: -2.3)
                        .stage(x: 672, y: 478, w: 0, h: 0)
                } else {
                    GlassPill(name: "Deep Sea", t: t, scale: s, delay: -2.3, locked: true)
                        .stage(x: 672, y: 478, w: 0, h: 0)
                    // The painted padlock sits locked around the pill's right
                    // end, bobbing with it
                    ArtImage("props/padlock-rope.png")
                        .rotationEffect(.degrees(10))
                        .shadow(color: Tokens.Palette.midnight.opacity(0.5), radius: 5 * s, y: 4 * s)
                        .offset(y: Wave.alternate(t, from: -2.4, to: 2.4, duration: 3.4, delay: -2.3) * s)
                        .allowsHitTesting(false)
                        .stage(x: 729, y: 462, w: 42, h: 75)
                }

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                HomeButton(scale: s, action: onHome)
                    .stageTopLeft(x: 30, y: 30)
            }
            .onChange(of: Int(t * 10)) {
                if start == nil { start = t }
                if !invited && tl >= 6.5 {
                    invited = true
                    speak(PromptScript.tapAPlace)
                }
            }
        }
    }
}

/// One 11px pearl dot of the trail between places.
private struct TrailDot: View {
    let opacity: Double
    let scale: CGFloat
    var shadow = true

    var body: some View {
        Circle()
            .fill(Tokens.Palette.pearl)
            .shadow(color: shadow ? Tokens.Palette.midnight.opacity(0.35) : .clear, radius: 2 * scale, y: 2 * scale)
            .opacity(opacity)
    }
}

/// The game's floating UI material: sea-glass. A frosted lens of water with a
/// bright rim where it catches the light from above, drifting buoyantly like
/// the game's own bubbles. Labels float in it over their places rather than
/// pretending to be scenery. Locked places get dark glass and pearl ink.
private struct GlassPill: View {
    let name: String
    let t: Double
    let scale: CGFloat
    var delay: Double = 0
    var locked = false

    var body: some View {
        Text(name)
            .font(baloo(25, weight: 700, scale: scale))
            .foregroundStyle(locked ? Tokens.Palette.pearl.opacity(0.92) : Color(hex: 0x1A3B5C))
            .padding(.top, 9 * scale)
            .padding(.bottom, 5 * scale)
            .padding(.horizontal, 24 * scale)
            .background(SeaGlass(scale: scale, locked: locked))
            // satellite bubbles break the perfect capsule into something alive
            .overlay(alignment: .topTrailing) {
                SeaGlassDot(d: 13, scale: scale).offset(x: 3 * scale, y: -7 * scale)
            }
            .overlay(alignment: .bottomLeading) {
                SeaGlassDot(d: 9, scale: scale).offset(x: -5 * scale, y: 5 * scale)
            }
            .shadow(color: Tokens.Palette.midnight.opacity(0.22), radius: 8 * scale, y: 5 * scale)
            .offset(y: Wave.alternate(t, from: -2.4, to: 2.4, duration: 3.4, delay: delay) * scale)
            .fixedSize()
            .frame(width: 0, height: 0, alignment: .top)
            .allowsHitTesting(false)
    }
}
