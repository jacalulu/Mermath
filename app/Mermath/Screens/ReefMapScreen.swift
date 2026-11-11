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
                // Sign first, crab after: his claw rests against the post
                SignPost(name: "Tide Pool", w: 126, t: t, scale: s, tilt: 2)
                    .stage(x: 196, y: 64, w: 126, h: 102)
                CrabView(t: t, scale: s, blinkCycle: 5.1, bobTo: -3)
                    .frame(width: 76 * s, height: 64 * s)
                    .allowsHitTesting(false)
                    .stage(x: 182, y: 84, w: 76, h: 64)

                // Coral Reef on the mid-water ledge: the picked sister floats
                // over the coral, her sign planted in the seagrass where the
                // pearl trail ends
                Button(action: { onDive(.coralReef) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 250, y: 210, w: 350, h: 280)
                GlowPulse(t: t, delay: -0.8)
                    .stage(x: 398, y: 346, w: 195, h: 82)
                SisterView(spec: child.puppet, t: t, scale: s)
                    .frame(width: 158 * s, height: 181 * s)
                    .allowsHitTesting(false)
                    .stage(x: 388, y: 220, w: 158, h: 181)
                SignPost(name: "Coral Reef", w: 140, t: t, scale: s, tilt: -2, delay: -0.9)
                    .stage(x: 252, y: 352, w: 140, h: 113)
                ArtImage("props/sea-star-pink.png")
                    .allowsHitTesting(false)
                    .stage(x: 328, y: 446, w: 26, h: 24)

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
                    SignPost(name: "Deep Sea", w: 140, t: t, scale: s, tilt: -2, delay: -1.7, cool: true)
                        .stage(x: 628, y: 406, w: 140, h: 113)
                } else {
                    SignPost(name: "Deep Sea", w: 140, t: t, scale: s, tilt: -2, delay: -1.7, locked: true, cool: true)
                        .stage(x: 628, y: 406, w: 140, h: 113)
                    // The painted padlock hangs from its rope over the plank
                    ArtImage("props/padlock-rope.png")
                        .shadow(color: Tokens.Palette.midnight.opacity(0.45), radius: 4 * s, y: 4 * s)
                        .allowsHitTesting(false)
                        .stage(x: 679, y: 434, w: 38, h: 68)
                }

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                HomeButton(scale: s, action: onHome)
                    .stageTopLeft(x: 24, y: 24)
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

/// A driftwood signpost planted in the scenery, the place name painted on its
/// plank in walnut ink. It breathes a gentle tap-me swell from its base. A
/// locked place keeps its sign but the ink fades (the padlock hangs on top).
private struct SignPost: View {
    let name: String
    /// Design-space width; height follows the painted plank's 320:258 aspect.
    let w: CGFloat
    let t: Double
    let scale: CGFloat
    var tilt: Double = 0
    var delay: Double = 0
    var locked = false
    /// Deep-water color grade: cools and darkens the wood to sit at depth.
    var cool = false

    var body: some View {
        let h = w * 258 / 320
        let ink = Color(hex: cool ? 0x2E2418 : 0x4A2C12)
        ZStack {
            // Contact shadow cast to the bottom-right (light from upper left)
            Ellipse()
                .fill(Tokens.Palette.midnight.opacity(cool ? 0.4 : 0.26))
                .blur(radius: 3.5 * scale)
                .frame(width: w * 0.5 * scale, height: h * 0.08 * scale)
                .position(x: w * 0.6 * scale, y: h * 0.955 * scale)
            ArtImage("props/sign.png")
                .frame(width: w * scale, height: h * scale)
                .colorMultiply(cool ? Color(hex: 0xAEBACF) : .white)
            // Carved lettering: a light chisel catch under the walnut ink
            ZStack {
                carvedText.foregroundStyle(Color(hex: 0xF7E7C0).opacity(cool ? 0.4 : 0.75))
                    .offset(y: 1.6 * scale)
                carvedText.foregroundStyle(ink.opacity(locked ? 0.65 : 0.95))
            }
            .frame(width: w * 0.76 * scale)
            .position(x: w * 0.5 * scale, y: h * 0.19 * scale)
        }
        .frame(width: w * scale, height: h * scale)
        .rotationEffect(.degrees(tilt), anchor: .bottom)
        .scaleEffect(Wave.alternate(t, from: 1.0, to: 1.03, duration: 2.6, delay: delay), anchor: .bottom)
        .allowsHitTesting(false)
    }

    private var carvedText: some View {
        Text(name)
            .font(baloo(21, weight: 700, scale: scale))
            .lineLimit(1)
            .minimumScaleFactor(0.65)
    }
}
