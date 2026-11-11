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
                        .stage(x: 276, y: 0, w: 414, h: 600)
                    KelpLayer(t: t, path: "scenes/reef-map/kelp-mid.png",
                              from: 1.3, to: -1.4, duration: 6, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 664, y: 0, w: 136, h: 600)
                    FishSwim(t: t, travel: 940, bobDown: 5, bobUp: 6, duration: 32, delay: -4, scale: s)
                        .stage(x: 830, y: 86, w: 40, h: 25)
                    FishSwim(t: t, travel: 940, bobDown: 5, bobUp: 6, duration: 36, delay: -18, scale: s)
                        .stage(x: 830, y: 104, w: 30, h: 19)
                    ArtImage("scenes/reef-map/seabed.png")
                        .stage(x: 0, y: 120, w: 800, h: 480)
                    // The grass spans pool to ledge, so it holds still here
                    ArtImage("scenes/reef-map/seagrass.png")
                        .stage(x: 68, y: 170, w: 538, h: 260)
                    RisingBubble(t: t, duration: 9, scale: s)
                        .stage(x: 148, y: 200, w: 20, h: 20)
                    RisingBubble(t: t, duration: 12, delay: 3, scale: s)
                        .stage(x: 730, y: 540, w: 22, h: 22)
                }
                .bleed()

                // Pearl trail: pool to reef it swoops through open water and
                // twinkles; the locked drop down the cliff sits dim and still
                ForEach(Array([(234.0, 300.0), (272, 340), (310, 380), (346, 418), (378, 450)].enumerated()), id: \.offset) { i, dot in
                    TrailDot(opacity: Wave.alternate(t, from: 0.55, to: 1, duration: 1, delay: Double(i) * 0.25), scale: s)
                        .stage(x: dot.0, y: dot.1, w: 17, h: 17)
                }
                ForEach(Array([(578.0, 444.0), (606, 464), (634, 482), (660, 498)].enumerated()), id: \.offset) { _, dot in
                    TrailDot(opacity: 0.4, scale: s, shadow: false)
                        .stage(x: dot.0, y: dot.1, w: 17, h: 17)
                }

                // Tide Pool, in the shore shelf at the surface: the crab waits
                // on the rocks beside the pool, label on the slope below
                Button(action: { onDive(.tidePool) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 14, y: 110, w: 270, h: 196)
                GlowPulse(t: t)
                    .stage(x: 52, y: 148, w: 195, h: 76)
                CrabView(t: t, scale: s, blinkCycle: 5.1, bobTo: -3)
                    .frame(width: 104 * s, height: 88 * s)
                    .allowsHitTesting(false)
                    .stage(x: 34, y: 94, w: 104, h: 88)
                ZoneLabel(name: "Tide Pool", subtitle: "Find the number", scale: s)
                    .stage(x: 120, y: 262, w: 0, h: 0)

                // Coral Reef on the mid-water ledge: the picked sister floats
                // over the coral
                Button(action: { onDive(.coralReef) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 336, y: 186, w: 264, h: 296)
                GlowPulse(t: t, delay: -0.8)
                    .stage(x: 392, y: 346, w: 205, h: 88)
                SisterView(spec: child.puppet, t: t, scale: s)
                    .frame(width: 158 * s, height: 181 * s)
                    .allowsHitTesting(false)
                    .stage(x: 396, y: 148, w: 158, h: 181)
                ZoneLabel(name: "Coral Reef", subtitle: "Adding to 10", scale: s)
                    .stage(x: 428, y: 474, w: 0, h: 0)

                // Deep Sea, down the cliff in the dark corner: padlocked until
                // two clean dives open it
                if deepSeaUnlocked {
                    Button(action: { onDive(.deepSea) }) {
                        Color.clear.contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .stage(x: 602, y: 400, w: 194, h: 176)
                    GlowPulse(t: t, delay: -0.4)
                        .stage(x: 630, y: 468, w: 166, h: 80)
                    ZoneLabel(name: "Deep Sea", subtitle: "Counting by 2s and 5s", scale: s)
                        .stage(x: 692, y: 506, w: 0, h: 0)
                } else {
                    ArtImage("ui/padlock.png")
                        .shadow(color: Tokens.Palette.midnight.opacity(0.5), radius: 4 * s, y: 4 * s)
                        .stage(x: 702, y: 420, w: 52, h: 67)
                    ZoneLabel(name: "Deep Sea", subtitle: "Counting by 2s and 5s", scale: s, locked: true)
                        .stage(x: 692, y: 506, w: 0, h: 0)
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
