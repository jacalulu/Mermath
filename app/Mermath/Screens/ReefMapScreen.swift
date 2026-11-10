import SwiftUI

/// "Where shall we dive?" One painted seabed steps down from the bright
/// shallows to the dark deep, with a place on each step. The crab waits at the
/// Tide Pool, the picked sister floats over the Coral Reef, and a pearl trail
/// twinkles along the open stretch. Ported from reference/html/reef-map.html.
struct ReefMapScreen: View {
    let child: ChildID
    /// Two clean dives (no hints) open the Deep Sea.
    var deepSeaUnlocked = false
    var onDive: (Zone) -> Void = { _ in }
    var onSwitchMermaid: () -> Void = {}

    @Environment(\.stage) private var m

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                // Scenery (bleeds to the physical edges)
                Group {
                    ArtImage("scenes/reef-map/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t)
                        .stage(x: 0, y: 0, w: 800, h: 340)
                    KelpLayer(t: t, path: "scenes/reef-map/kelp-far.png",
                              from: -0.8, to: 0.9, duration: 7, pivot: UnitPoint(x: 0.5, y: 1))
                        .opacity(0.75)
                        .stage(x: 192, y: 0, w: 504, h: 600)
                    KelpLayer(t: t, path: "scenes/reef-map/kelp-mid.png",
                              from: 1.3, to: -1.4, duration: 6, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    FishSwim(t: t, travel: 940, bobDown: 5, bobUp: 6, duration: 32, delay: -4, scale: s)
                        .stage(x: 830, y: 86, w: 40, h: 25)
                    FishSwim(t: t, travel: 940, bobDown: 5, bobUp: 6, duration: 36, delay: -18, scale: s)
                        .stage(x: 830, y: 104, w: 30, h: 19)
                    ArtImage("scenes/reef-map/seabed.png")
                        .stage(x: 0, y: 206, w: 800, h: 394)
                    KelpLayer(t: t, path: "scenes/reef-map/seagrass.png",
                              from: -7, to: 7, duration: 2.8, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 92, y: 548, w: 520, h: 52)
                    RisingBubble(t: t, duration: 9, scale: s)
                        .stage(x: 300, y: 560, w: 26, h: 26)
                    RisingBubble(t: t, duration: 12, delay: 3, scale: s)
                        .stage(x: 586, y: 580, w: 22, h: 22)
                }
                .bleed()

                // Pearl trail: the open stretch twinkles, the locked one sits still
                ForEach(Array([(252.0, 376.0), (274, 388), (296, 400), (318, 410)].enumerated()), id: \.offset) { i, dot in
                    TrailDot(opacity: Wave.alternate(t, from: 0.55, to: 1, duration: 1, delay: Double(i) * 0.25), scale: s)
                        .stage(x: dot.0, y: dot.1, w: 11, h: 11)
                }
                ForEach(Array([(560.0, 436.0), (582, 450), (604, 464), (626, 476)].enumerated()), id: \.offset) { _, dot in
                    TrailDot(opacity: 0.4, scale: s, shadow: false)
                        .stage(x: dot.0, y: dot.1, w: 11, h: 11)
                }

                // Tide Pool: the crab on his rock, label below, soft pulsing glow
                Button(action: { onDive(.tidePool) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 14, y: 208, w: 256, h: 252)
                GlowPulse(t: t)
                    .stage(x: 36, y: 304, w: 220, h: 100)
                CrabView(t: t, scale: s, blinkCycle: 5.1, bobTo: -3)
                    .frame(width: 104 * s, height: 88 * s)
                    .allowsHitTesting(false)
                    .stage(x: 10, y: 216, w: 104, h: 88)
                ZoneLabel(name: "Tide Pool", subtitle: "Find the number", scale: s)
                    .stage(x: 142, y: 400, w: 0, h: 0)

                // Coral Reef: the picked sister floats on the coral
                Button(action: { onDive(.coralReef) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 306, y: 90, w: 262, h: 436)
                GlowPulse(t: t, delay: -0.8)
                    .stage(x: 320, y: 374, w: 234, h: 100)
                SisterView(spec: child.puppet, t: t, scale: s)
                    .frame(width: 158 * s, height: 181 * s)
                    .allowsHitTesting(false)
                    .stage(x: 358, y: 90, w: 158, h: 181)
                ZoneLabel(name: "Coral Reef", subtitle: "Adding to 10", scale: s)
                    .stage(x: 436, y: 468, w: 0, h: 0)

                // Deep Sea: padlocked until two clean dives open it
                if deepSeaUnlocked {
                    Button(action: { onDive(.deepSea) }) {
                        Color.clear.contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .stage(x: 600, y: 380, w: 200, h: 200)
                    GlowPulse(t: t, delay: -0.4)
                        .stage(x: 620, y: 420, w: 180, h: 90)
                    ZoneLabel(name: "Deep Sea", subtitle: "Counting by 2s and 5s", scale: s)
                        .stage(x: 700, y: 516, w: 0, h: 0)
                } else {
                    ArtImage("ui/padlock.png")
                        .shadow(color: Tokens.Palette.midnight.opacity(0.5), radius: 4 * s, y: 4 * s)
                        .stage(x: 678, y: 408, w: 52, h: 67)
                    ZoneLabel(name: "Deep Sea", subtitle: "Counting by 2s and 5s", scale: s, locked: true)
                        .stage(x: 700, y: 516, w: 0, h: 0)
                }

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                // Title and switch
                Button(action: onSwitchMermaid) {
                    Text("Switch mermaid")
                        .font(baloo(18, weight: 600, scale: s))
                        .foregroundStyle(Tokens.Palette.midnight)
                        .padding(.top, 7 * s)
                        .padding(.bottom, 3 * s)
                        .padding(.horizontal, 18 * s)
                        .background(Capsule().fill(Tokens.Palette.pearl))
                        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                }
                .buttonStyle(.plain)
                .stageTopLeft(x: 24, y: 24)

                Text("Where shall we dive?")
                    .font(baloo(24, weight: 700, scale: s))
                    .foregroundStyle(Tokens.Palette.midnight)
                    .padding(.top, 6 * s)
                    .padding(.bottom, 2 * s)
                    .padding(.horizontal, 24 * s)
                    .background(Capsule().fill(Tokens.Palette.pearl))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                    .stageTopCenter(y: 24)
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

/// The two-line place pill, centered on its stage point. Locked places get the
/// Midnight panel treatment instead of Pearl.
private struct ZoneLabel: View {
    let name: String
    let subtitle: String
    let scale: CGFloat
    var locked = false

    var body: some View {
        VStack(spacing: 0) {
            Text(name)
                .font(baloo(locked ? 22 : 24, weight: 700, scale: scale))
                .foregroundStyle(locked ? Tokens.Palette.pearl : Tokens.Palette.midnight)
            Text(subtitle)
                .font(baloo(locked ? 14 : 15, weight: 500, scale: scale))
                .foregroundStyle(locked ? Tokens.Palette.pearl.opacity(0.85) : Color(hex: 0x17617A))
        }
        .padding(.top, 7 * scale)
        .padding(.bottom, 4 * scale)
        .padding(.horizontal, (locked ? 18 : 20) * scale)
        .background(
            RoundedRectangle(cornerRadius: 22 * scale)
                .fill(locked ? Color(hex: 0x061A33, opacity: 0.8) : Tokens.Palette.pearl)
        )
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * scale, y: 6 * scale)
        .fixedSize()
        .frame(width: 0, height: 0, alignment: .top)
        .allowsHitTesting(false)
    }
}
