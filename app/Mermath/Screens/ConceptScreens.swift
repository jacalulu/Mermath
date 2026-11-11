import SwiftUI

#if DEBUG
/// Two full-screen concept comps of the reef map, synthesizing the parent's
/// reference board: a richer, light-filled scene (foreground coral framing, a
/// school of fish) with the labels woven into the world.
///   -screen compA  luminous storybook lettering, soap-bubble home button
///   -screen compB  Liquid Glass capsules grown into the reef

// MARK: - Comp A: luminous storybook lettering

struct MapConceptA: View {
    @Environment(\.stage) private var m

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                ConceptScenery(t: t, s: s)
                ConceptCast(t: t, s: s)
                ConceptFraming(t: t, s: s)

                GlowTitle(name: "Tide Pool", glow: Color(hex: 0x2FA6B8), t: t, s: s)
                    .stage(x: 134, y: 202, w: 0, h: 0)
                GlowTitle(name: "Coral Reef", glow: Color(hex: 0xE86A8C), t: t, s: s, delay: -1.2)
                    .stage(x: 424, y: 452, w: 0, h: 0)
                GlowTitle(name: "Deep Sea", glow: Color(hex: 0x7FD8E8), t: t, s: s, delay: -2.4, size: 27)
                    .stage(x: 666, y: 474, w: 0, h: 0)
                ArtImage("props/padlock-rope.png")
                    .shadow(color: Tokens.Palette.midnight.opacity(0.5), radius: 5 * s, y: 4 * s)
                    .offset(y: Wave.alternate(t, from: -2.4, to: 2.4, duration: 3.4, delay: -2.4) * s)
                    .stage(x: 652, y: 500, w: 30, h: 54)

                BubbleHomeButton(s: s)
                    .stage(x: 30, y: 30, w: 70, h: 70)

                Vignette().stage(x: 0, y: 0, w: 800, h: 600).bleed()
            }
        }
    }
}

// MARK: - Comp B: Liquid Glass grown into the reef

struct MapConceptB: View {
    @Environment(\.stage) private var m

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                ConceptScenery(t: t, s: s)
                ConceptCast(t: t, s: s)
                ConceptFraming(t: t, s: s)

                GrownGlassPill(name: "Tide Pool", tint: Color(hex: 0x2FA6B8),
                               prop: "props/shell-teal.png", t: t, s: s)
                    .stage(x: 134, y: 202, w: 0, h: 0)
                GrownGlassPill(name: "Coral Reef", tint: Color(hex: 0xE86A8C),
                               prop: "props/sea-star-pink.png", t: t, s: s, delay: -1.2)
                    .stage(x: 424, y: 452, w: 0, h: 0)
                GrownGlassPill(name: "Deep Sea", tint: Color(hex: 0x16324E),
                               prop: nil, t: t, s: s, delay: -2.4)
                    .stage(x: 666, y: 470, w: 0, h: 0)
                ArtImage("props/padlock-rope.png")
                    .rotationEffect(.degrees(10))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.5), radius: 5 * s, y: 4 * s)
                    .offset(y: Wave.alternate(t, from: -2.4, to: 2.4, duration: 3.4, delay: -2.4) * s)
                    .stage(x: 718, y: 458, w: 36, h: 64)

                GlassHomeButton(s: s)
                    .stage(x: 30, y: 30, w: 70, h: 70)

                Vignette().stage(x: 0, y: 0, w: 800, h: 600).bleed()
            }
        }
    }
}

// MARK: - Shared enriched scenery

/// The map scenery with the reference board's staging: stronger light, a
/// school of small fish, and life in every band.
private struct ConceptScenery: View {
    let t: Double
    let s: CGFloat

    var body: some View {
        Group {
            Group {
                ArtImage("scenes/reef-map/bg.jpg")
                    .stage(x: 0, y: 0, w: 800, h: 600)
                LightShimmer(t: t)
                    .stage(x: 0, y: 152, w: 800, h: 240)
                LightShimmer(t: t)
                    .opacity(0.5)
                    .stage(x: 120, y: 280, w: 660, h: 220)
                KelpLayer(t: t, path: "scenes/reef-map/kelp-far.png",
                          from: -0.8, to: 0.9, duration: 7, pivot: UnitPoint(x: 0.5, y: 1))
                    .opacity(0.75)
                    .stage(x: 288, y: 194, w: 368, h: 406)
                KelpLayer(t: t, path: "scenes/reef-map/kelp-mid.png",
                          from: 1.3, to: -1.4, duration: 6, pivot: UnitPoint(x: 0.5, y: 1))
                    .stage(x: 648, y: 192, w: 152, h: 408)
            }
            // A school of little fish crossing the open water
            ForEach(0..<5, id: \.self) { i in
                FishSwim(t: t, travel: 940,
                         bobDown: 4, bobUp: 5,
                         duration: 27 + Double(i) * 1.6,
                         delay: -3.5 * Double(i) - 2,
                         scale: s)
                    .stage(x: 830, y: 236 + CGFloat((i * 23) % 70),
                           w: 22 + CGFloat((i * 7) % 12), h: 14 + CGFloat((i * 5) % 8))
            }
            Group {
                ArtImage("scenes/reef-map/seabed.png")
                    .stage(x: 0, y: 88, w: 800, h: 512)
                ArtImage("scenes/reef-map/seagrass.png")
                    .stage(x: 294, y: 296, w: 324, h: 130)
                RisingBubble(t: t, duration: 9, scale: s)
                    .stage(x: 330, y: 430, w: 20, h: 20)
                RisingBubble(t: t, duration: 12, delay: 3, scale: s)
                    .stage(x: 730, y: 540, w: 22, h: 22)
                RisingBubble(t: t, duration: 10, delay: 6, scale: s)
                    .stage(x: 120, y: 350, w: 16, h: 16)
            }
        }
        .bleed()
    }
}

/// The crab at his pool and the sister over her reef.
private struct ConceptCast: View {
    let t: Double
    let s: CGFloat

    var body: some View {
        Group {
            CrabView(t: t, scale: s, blinkCycle: 5.1, bobTo: -3)
                .frame(width: 76 * s, height: 64 * s)
                .stage(x: 182, y: 84, w: 76, h: 64)
            SisterView(spec: ChildID.daphne.puppet, t: t, scale: s)
                .frame(width: 158 * s, height: 181 * s)
                .stage(x: 388, y: 220, w: 158, h: 181)
        }
    }
}

/// Foreground coral framing the bottom corners, from the reference board.
private struct ConceptFraming: View {
    let t: Double
    let s: CGFloat

    var body: some View {
        Group {
            ArtImage("props/coral-fan-a.png")
                .stage(x: -34, y: 444, w: 316, h: 248)
            ArtImage("props/coral-fan-b.png")
                .stage(x: 596, y: 500, w: 276, h: 221)
        }
        .bleed()
    }
}

// MARK: - Comp A pieces

/// Luminous hand-set lettering: per-letter tilt and bounce, cream fill, a
/// zone-tinted glow. (Baloo stands in until the display face is chosen.)
private struct GlowTitle: View {
    let name: String
    let glow: Color
    let t: Double
    let s: CGFloat
    var delay: Double = 0
    var size: CGFloat = 30

    var body: some View {
        HStack(spacing: 0.5 * s) {
            ForEach(Array(name.enumerated()), id: \.offset) { i, ch in
                Text(String(ch))
                    .font(baloo(size, weight: 700, scale: s))
                    .foregroundStyle(Color(hex: 0xFFF6E0))
                    .rotationEffect(.degrees(i.isMultiple(of: 2) ? -4 : 3))
                    .offset(y: (i.isMultiple(of: 2) ? -2.5 : 2.5) * s)
            }
        }
        .shadow(color: Color(hex: 0x0A2238, opacity: 0.85), radius: 1.2 * s, y: 1.2 * s)
        .shadow(color: glow.opacity(0.95), radius: 6 * s)
        .shadow(color: glow.opacity(0.55), radius: 16 * s)
        .offset(y: Wave.alternate(t, from: -2.2, to: 2.2, duration: 3.4, delay: delay) * s)
        .fixedSize()
        .frame(width: 0, height: 0)
    }
}

/// A soap-bubble home button: transparent, iridescent rim, crescent of light.
private struct BubbleHomeButton: View {
    let s: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(
                EllipticalGradient(colors: [
                    Color.white.opacity(0.03), Color.white.opacity(0.05),
                    Color.white.opacity(0.16),
                ], center: .center))
            Circle().strokeBorder(
                AngularGradient(colors: [
                    Color(hex: 0xFFC2DD, opacity: 0.85), Color(hex: 0xC9F2D8, opacity: 0.8),
                    Color(hex: 0xC8C2FF, opacity: 0.85), Color(hex: 0xFFE9B8, opacity: 0.8),
                    Color(hex: 0xFFC2DD, opacity: 0.85),
                ], center: .center, angle: .degrees(-40)),
                lineWidth: 3.5 * s)
                .blur(radius: 0.8 * s)
            Circle().strokeBorder(Color.white.opacity(0.9), lineWidth: 2.5 * s)
                .mask(LinearGradient(colors: [.white, .clear],
                                     startPoint: .topLeading, endPoint: .center))
            Image(systemName: "house.fill")
                .font(.system(size: 28 * s, weight: .bold))
                .foregroundStyle(Color(hex: 0xFFF6E0))
                .shadow(color: Color(hex: 0x0A2238, opacity: 0.7), radius: 1.2 * s, y: 1.2 * s)
        }
    }
}

// MARK: - Comp B pieces

/// A Liquid Glass capsule with a painted prop grown over its edge.
private struct GrownGlassPill: View {
    let name: String
    let tint: Color
    let prop: String?
    let t: Double
    let s: CGFloat
    var delay: Double = 0

    var body: some View {
        glassText
            .overlay(alignment: .bottomLeading) {
                if let prop {
                    ArtImage(prop)
                        .frame(width: 26 * s, height: 24 * s)
                        .offset(x: -9 * s, y: 9 * s)
                }
            }
            .offset(y: Wave.alternate(t, from: -2.2, to: 2.2, duration: 3.4, delay: delay) * s)
            .fixedSize()
            .frame(width: 0, height: 0)
    }

    @ViewBuilder
    private var glassText: some View {
        let text = Text(name)
            .font(baloo(25, weight: 700, scale: s))
            .foregroundStyle(Color(hex: 0x14324E))
            .padding(.top, 8 * s).padding(.bottom, 4 * s)
            .padding(.horizontal, 22 * s)
        if #available(iOS 26.0, *) {
            text.glassEffect(.clear.tint(tint.opacity(0.22)), in: Capsule())
        } else {
            text.background(SeaGlass(scale: s))
        }
    }
}

/// The home button in the same Liquid Glass.
private struct GlassHomeButton: View {
    let s: CGFloat

    var body: some View {
        let glyph = Image(systemName: "house.fill")
            .font(.system(size: 28 * s, weight: .bold))
            .foregroundStyle(Color(hex: 0x14324E))
            .frame(width: 70 * s, height: 70 * s)
        if #available(iOS 26.0, *) {
            glyph.glassEffect(.clear, in: Circle())
        } else {
            glyph.background(SeaGlass(scale: s))
        }
    }
}
#endif
