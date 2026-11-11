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
                // swoops down open water to the reef; the locked drop is dim
                ForEach(Array([(212.0, 150.0), (238, 186), (268, 230), (300, 276), (332, 322), (362, 364)].enumerated()), id: \.offset) { i, dot in
                    TrailDot(opacity: Wave.alternate(t, from: 0.55, to: 1, duration: 1, delay: Double(i) * 0.25), scale: s)
                        .stage(x: dot.0, y: dot.1, w: 17, h: 17)
                }
                ForEach(Array([(578.0, 444.0), (606, 464), (634, 482), (660, 498)].enumerated()), id: \.offset) { _, dot in
                    TrailDot(opacity: 0.4, scale: s, shadow: false)
                        .stage(x: dot.0, y: dot.1, w: 17, h: 17)
                }

                // Tide Pool, hollowed into the DRY shore rock above the
                // waterline: the crab perches on its rim against the sky,
                // label floating in the shallows just under the line
                Button(action: { onDive(.tidePool) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 14, y: 80, w: 266, h: 190)
                GlowPulse(t: t)
                    .stage(x: 86, y: 116, w: 150, h: 56)
                CrabView(t: t, scale: s, blinkCycle: 5.1, bobTo: -3)
                    .frame(width: 76 * s, height: 64 * s)
                    .allowsHitTesting(false)
                    .stage(x: 182, y: 84, w: 76, h: 64)
                ZoneLabel(name: "Tide Pool", subtitle: "Find the number", scale: s)
                    .stage(x: 134, y: 200, w: 0, h: 0)

                // Coral Reef on the mid-water ledge: the picked sister floats
                // over the coral
                Button(action: { onDive(.coralReef) }) {
                    Color.clear.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .stage(x: 340, y: 210, w: 260, h: 280)
                GlowPulse(t: t, delay: -0.8)
                    .stage(x: 398, y: 346, w: 195, h: 82)
                SisterView(spec: child.puppet, t: t, scale: s)
                    .frame(width: 158 * s, height: 181 * s)
                    .allowsHitTesting(false)
                    .stage(x: 388, y: 220, w: 158, h: 181)
                ZoneLabel(name: "Coral Reef", subtitle: "Adding to 10", scale: s)
                    .stage(x: 424, y: 466, w: 0, h: 0)

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
