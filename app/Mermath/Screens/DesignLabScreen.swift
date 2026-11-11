import SwiftUI

#if DEBUG
/// Design lab v2: five refined label directions, each rendered at the three
/// real zones so per-zone theming can be judged in place.
/// Debug-only: launch with `-screen designLab`.
///   A. Apple Liquid Glass (regular) - the real iOS 26+ material
///   B. Apple Liquid Glass (clear)  - the more transparent lens variant
///   C. True soap bubble            - no frosting, only iridescence and light
///   D. Storybook lettering         - film-title type, zone-tinted glow
///   E. Painted wash                - zone-themed watercolor behind the name
struct DesignLabScreen: View {
    @Environment(\.stage) private var m

    private static let cols: [(x: CGFloat, name: String)] = [
        (150, "Tide Pool"), (410, "Coral Reef"), (665, "Deep Sea"),
    ]
    private static let rows: [CGFloat] = [52, 150, 248, 346, 444, 542]

    var body: some View {
        let s = m.scale
        MotionClock { _ in
            ZStack {
                Group {
                    ArtImage("scenes/reef-map/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    ArtImage("scenes/reef-map/seabed.png")
                        .stage(x: 0, y: 88, w: 800, h: 512)
                }
                .bleed()
                ForEach(0..<6, id: \.self) { r in
                    ForEach(0..<3, id: \.self) { c in
                        Centered { label(row: r, col: c, s: s) }
                            .stage(x: Self.cols[c].x, y: Self.rows[r], w: 0, h: 0)
                    }
                    Badge(text: ["A", "B", "C", "D", "E", "F"][r], s: s)
                        .stage(x: 18, y: Self.rows[r] - 13, w: 26, h: 26)
                }
            }
        }
    }

    @ViewBuilder
    private func label(row: Int, col: Int, s: CGFloat) -> some View {
        let name = Self.cols[col].name
        switch row {
        case 0: liquid(name, clear: false, s: s)
        case 1: liquid(name, clear: true, s: s)
        case 2: soap(name, s: s)
        case 3: story(name, glow: Self.glows[col], s: s)
        case 4: wash(name, col: col, s: s)
        case 5: bouncy(name, glow: Self.glows[col], s: s)
        default: EmptyView()
        }
    }

    // MARK: F, bouncy display lettering (Creatures-of-the-Deep energy;
    // same treatment would apply to a new display font)

    private func bouncy(_ name: String, glow: Color, s: CGFloat) -> some View {
        HStack(spacing: 0.5 * s) {
            ForEach(Array(name.enumerated()), id: \.offset) { i, ch in
                Text(String(ch))
                    .font(baloo(30, weight: 700, scale: s))
                    .foregroundStyle(Color(hex: 0xFFF6E0))
                    .rotationEffect(.degrees(i.isMultiple(of: 2) ? -4 : 3))
                    .offset(y: (i.isMultiple(of: 2) ? -2.5 : 2.5) * s)
            }
        }
        .shadow(color: Color(hex: 0x0A2238, opacity: 0.8), radius: 1.2 * s, y: 1.2 * s)
        .shadow(color: glow.opacity(0.6), radius: 7 * s, y: 2 * s)
    }

    // MARK: A + B, the real Apple material

    @ViewBuilder
    private func liquid(_ name: String, clear: Bool, s: CGFloat) -> some View {
        let text = Text(name)
            .font(baloo(25, weight: 700, scale: s))
            .foregroundStyle(Color(hex: 0x14324E))
            .padding(.top, 8 * s).padding(.bottom, 4 * s)
            .padding(.horizontal, 22 * s)
        if #available(iOS 26.0, *) {
            text.glassEffect(clear ? .clear : .regular, in: Capsule())
        } else {
            text.background(SeaGlass(scale: s))
        }
    }

    // MARK: C, a true soap bubble

    private func soap(_ name: String, s: CGFloat) -> some View {
        Text(name)
            .font(baloo(24, weight: 700, scale: s))
            .foregroundStyle(Color(hex: 0x14324E))
            .padding(.vertical, 15 * s)
            .padding(.horizontal, 26 * s)
            .background(SoapBubble(s: s))
    }

    // MARK: D, storybook lettering with a zone-tinted glow

    private static let glows: [Color] = [
        Color(hex: 0x2FA6B8), Color(hex: 0xE86A8C), Color(hex: 0x7FD8E8),
    ]

    private func story(_ name: String, glow: Color, s: CGFloat) -> some View {
        Text(name)
            .font(baloo(30, weight: 700, scale: s))
            .foregroundStyle(Color(hex: 0xFFF6E0))
            .shadow(color: glow.opacity(0.95), radius: 5 * s)
            .shadow(color: Color(hex: 0x0A2238, opacity: 0.75), radius: 1.2 * s, y: 1.2 * s)
            .shadow(color: Color(hex: 0x0A2238, opacity: 0.4), radius: 9 * s, y: 3 * s)
            .rotationEffect(.degrees(-2))
    }

    // MARK: E, zone-themed painted wash

    private static let washes: [(a: Color, b: Color, ink: Color)] = [
        (Color(hex: 0xF6E3B2, opacity: 0.65), Color(hex: 0xEFCF8E, opacity: 0.45), Color(hex: 0x1A3B5C)),
        (Color(hex: 0xF6B8C8, opacity: 0.6), Color(hex: 0xEC93AC, opacity: 0.4), Color(hex: 0x1A3B5C)),
        (Color(hex: 0x16324E, opacity: 0.7), Color(hex: 0x0E2238, opacity: 0.5), Color(hex: 0xFFF2D8)),
    ]

    private func wash(_ name: String, col: Int, s: CGFloat) -> some View {
        let w = Self.washes[col]
        return ZStack {
            Ellipse().fill(w.a)
                .frame(width: 226 * s, height: 60 * s)
                .blur(radius: 5 * s)
                .rotationEffect(.degrees(-3))
            Ellipse().fill(w.b)
                .frame(width: 190 * s, height: 42 * s)
                .blur(radius: 7 * s)
                .offset(x: 9 * s, y: 7 * s)
            Text(name)
                .font(baloo(28, weight: 700, scale: s))
                .foregroundStyle(w.ink)
                .rotationEffect(.degrees(-2))
        }
    }
}

/// A real soap bubble is nearly invisible: a hint of film, thin-band
/// iridescence at the rim, a crescent of light, and a counter-light below.
private struct SoapBubble: View {
    let s: CGFloat

    var body: some View {
        ZStack {
            Ellipse().fill(
                EllipticalGradient(colors: [
                    Color.white.opacity(0.02), Color.white.opacity(0.03),
                    Color.white.opacity(0.14),
                ], center: .center))
            Ellipse().strokeBorder(
                AngularGradient(colors: [
                    Color(hex: 0xFFC2DD, opacity: 0.8), Color(hex: 0xC9F2D8, opacity: 0.75),
                    Color(hex: 0xC8C2FF, opacity: 0.8), Color(hex: 0xFFE9B8, opacity: 0.75),
                    Color(hex: 0xFFC2DD, opacity: 0.8),
                ], center: .center, angle: .degrees(-40)),
                lineWidth: 4.5 * s)
            .blur(radius: 1.1 * s)
            Ellipse().strokeBorder(Color.white.opacity(0.75), lineWidth: 1.3 * s)
            Ellipse().strokeBorder(Color.white.opacity(0.9), lineWidth: 3 * s)
                .mask(LinearGradient(colors: [.white, .clear],
                                     startPoint: .topLeading, endPoint: .center))
        }
        .overlay(alignment: .bottomTrailing) {
            Ellipse().fill(Color.white.opacity(0.45))
                .frame(width: 16 * s, height: 6 * s)
                .rotationEffect(.degrees(-20))
                .offset(x: -18 * s, y: -9 * s)
        }
    }
}

/// Centers arbitrary content on its stage point.
private struct Centered<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content.fixedSize().frame(width: 0, height: 0)
    }
}

private struct Badge: View {
    let text: String
    let s: CGFloat
    var body: some View {
        ZStack {
            Circle().fill(Color(hex: 0x0A2238, opacity: 0.8))
            Text(text)
                .font(baloo(16, weight: 700, scale: s))
                .foregroundStyle(.white)
        }
    }
}
#endif
