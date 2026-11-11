import SwiftUI

#if DEBUG
/// A contact sheet of ten label treatments for the reef map, drawn over the
/// real painted scenery so each can be judged honestly in place.
/// Debug-only: launch with `-screen designLab`.
struct DesignLabScreen: View {
    @Environment(\.stage) private var m

    private static let cells: [(x: CGFloat, y: CGFloat)] = [
        (200, 64), (600, 64), (200, 182), (600, 182), (200, 300),
        (600, 300), (200, 418), (600, 418), (200, 536), (600, 536),
    ]

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                Group {
                    ArtImage("scenes/reef-map/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    ArtImage("scenes/reef-map/seabed.png")
                        .stage(x: 0, y: 88, w: 800, h: 512)
                }
                .bleed()
                ForEach(0..<10, id: \.self) { i in
                    Centered { option(i, t: t, s: s) }
                        .stage(x: Self.cells[i].x, y: Self.cells[i].y, w: 0, h: 0)
                    Badge(n: i + 1, s: s)
                        .stage(x: Self.cells[i].x - 178, y: Self.cells[i].y - 13, w: 26, h: 26)
                }
            }
        }
    }

    @ViewBuilder
    private func option(_ i: Int, t: Double, s: CGFloat) -> some View {
        switch i {
        case 0: storybook(s)
        case 1: enamel(s)
        case 2: livingGlass(t: t, s: s)
        case 3: bubbleBlob(s)
        case 4: bannerFish(s)
        case 5: ropeTag(s)
        case 6: coralTablet(s)
        case 7: nacre(s)
        case 8: wash(s)
        case 9: caustic(s)
        default: EmptyView()
        }
    }

    // 1. Storybook lettering: no container at all, film-title typography
    private func storybook(_ s: CGFloat) -> some View {
        Text("Coral Reef")
            .font(baloo(31, weight: 700, scale: s))
            .foregroundStyle(Color(hex: 0xFFF6E0))
            .shadow(color: Color(hex: 0x0A2238, opacity: 0.9), radius: 1.5 * s, y: 1.5 * s)
            .shadow(color: Color(hex: 0x0A2238, opacity: 0.5), radius: 9 * s, y: 3 * s)
            .rotationEffect(.degrees(-2))
    }

    // 2. Cream enamel badge: the wordmark's china finish
    private func enamel(_ s: CGFloat) -> some View {
        Text("Coral Reef")
            .font(baloo(25, weight: 700, scale: s))
            .foregroundStyle(Color(hex: 0x15456B))
            .padding(.top, 8 * s).padding(.bottom, 4 * s)
            .padding(.horizontal, 24 * s)
            .background(enamelBg(s))
            .shadow(color: Tokens.Palette.midnight.opacity(0.3), radius: 6 * s, y: 5 * s)
    }

    private func enamelBg(_ s: CGFloat) -> some View {
        let sheen: LinearGradient = LinearGradient(
            colors: [.white, .clear], startPoint: .top, endPoint: .center)
        return Capsule().fill(Color(hex: 0xFFF9EC))
            .overlay(Capsule().strokeBorder(Color(hex: 0xF0DCB8), lineWidth: 2 * s))
            .overlay(
                Capsule().strokeBorder(Color.white, lineWidth: 2 * s)
                    .padding(3 * s)
                    .mask(sheen)
            )
    }

    // 3. Sea-glass with life behind it: the glass refracts something
    private func livingGlass(t: Double, s: CGFloat) -> some View {
        ZStack {
            ArtImage("props/bubble.png")
                .frame(width: 24 * s, height: 24 * s)
                .offset(x: -74 * s, y: -22 * s)
            ArtImage("props/bubble.png")
                .frame(width: 15 * s, height: 15 * s)
                .offset(x: -94 * s, y: 2 * s)
            FishSwim(t: t, travel: 170, bobDown: 3, bobUp: 3, duration: 9, delay: -2, scale: s)
                .frame(width: 40 * s, height: 25 * s)
                .offset(x: -10 * s, y: 16 * s)
            Text("Coral Reef")
                .font(baloo(25, weight: 700, scale: s))
                .foregroundStyle(Color(hex: 0x1A3B5C))
                .padding(.top, 8 * s).padding(.bottom, 4 * s)
                .padding(.horizontal, 24 * s)
                .background(SeaGlass(scale: s))
        }
    }

    // 4. A true bubble: round, iridescent rim, one hard highlight
    private func bubbleBlob(_ s: CGFloat) -> some View {
        Text("Coral Reef")
            .font(baloo(24, weight: 700, scale: s))
            .foregroundStyle(Color(hex: 0x123C5E))
            .padding(.vertical, 18 * s)
            .padding(.horizontal, 26 * s)
            .background(
                ZStack {
                    Ellipse().fill(.ultraThinMaterial)
                    Ellipse().fill(Color(hex: 0xBFF0FF, opacity: 0.14))
                }
                .clipShape(Ellipse())
                .overlay(
                    Ellipse().strokeBorder(
                        AngularGradient(colors: [
                            .white.opacity(0.95), Color(hex: 0xFFB8D9, opacity: 0.55),
                            Color(hex: 0x9FE8E2, opacity: 0.6), .white.opacity(0.4),
                            .white.opacity(0.95),
                        ], center: .center),
                        lineWidth: 2.6 * s)
                )
                .overlay(alignment: .topLeading) {
                    Ellipse().fill(Color.white.opacity(0.85))
                        .frame(width: 22 * s, height: 10 * s)
                        .rotationEffect(.degrees(-28))
                        .offset(x: 26 * s, y: 12 * s)
                }
            )
    }

    // 5. A banner fish carries the name, like the answer fish carry numbers
    private func bannerFish(_ s: CGFloat) -> some View {
        HStack(spacing: -2 * s) {
            ArtImage("props/answer-fish.png")
                .frame(width: 88 * s, height: 56 * s)
                .scaleEffect(x: -1)
            Text("Coral Reef")
                .font(baloo(23, weight: 700, scale: s))
                .foregroundStyle(Color(hex: 0x15456B))
                .padding(.top, 7 * s).padding(.bottom, 3 * s)
                .padding(.horizontal, 16 * s)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 4 * s, bottomLeadingRadius: 4 * s,
                                           bottomTrailingRadius: 14 * s, topTrailingRadius: 14 * s)
                        .fill(Color(hex: 0xFFF9EC))
                        .overlay(
                            UnevenRoundedRectangle(topLeadingRadius: 4 * s, bottomLeadingRadius: 4 * s,
                                                   bottomTrailingRadius: 14 * s, topTrailingRadius: 14 * s)
                                .strokeBorder(Color(hex: 0xE8C98E), lineWidth: 2 * s)
                        )
                )
        }
        .shadow(color: Tokens.Palette.midnight.opacity(0.3), radius: 5 * s, y: 4 * s)
    }

    // 6. Rope and shells: the name on a tag strung like mermaid jewelry
    private func ropeTag(_ s: CGFloat) -> some View {
        VStack(spacing: -6 * s) {
            RopeArc()
                .stroke(Color(hex: 0xE2CBA2), style: StrokeStyle(lineWidth: 3.5 * s, lineCap: .round))
                .frame(width: 190 * s, height: 22 * s)
            Text("Coral Reef")
                .font(baloo(24, weight: 700, scale: s))
                .foregroundStyle(Color(hex: 0x15456B))
                .padding(.top, 7 * s).padding(.bottom, 3 * s)
                .padding(.horizontal, 18 * s)
                .background(
                    RoundedRectangle(cornerRadius: 12 * s)
                        .fill(Color(hex: 0xFFF9EC))
                        .overlay(RoundedRectangle(cornerRadius: 12 * s)
                            .strokeBorder(Color(hex: 0xE2CBA2), lineWidth: 2 * s))
                )
                .overlay(alignment: .topLeading) {
                    ArtImage("props/shell-teal.png")
                        .frame(width: 24 * s, height: 22 * s)
                        .offset(x: -10 * s, y: -8 * s)
                }
                .overlay(alignment: .bottomTrailing) {
                    ArtImage("props/sea-star-pink.png")
                        .frame(width: 22 * s, height: 20 * s)
                        .offset(x: 8 * s, y: 8 * s)
                }
        }
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 5 * s, y: 4 * s)
    }

    // 7. Carved coral tablet: engraved stone, Moana-style
    private func coralTablet(_ s: CGFloat) -> some View {
        ZStack {
            Text("Coral Reef")
                .font(baloo(24, weight: 700, scale: s))
                .foregroundStyle(Color(hex: 0xFFD9E2, opacity: 0.8))
                .offset(y: 1.6 * s)
            Text("Coral Reef")
                .font(baloo(24, weight: 700, scale: s))
                .foregroundStyle(Color(hex: 0x7E3049))
        }
        .padding(.top, 9 * s).padding(.bottom, 5 * s)
        .padding(.horizontal, 22 * s)
        .background(
            RoundedRectangle(cornerRadius: 16 * s)
                .fill(LinearGradient(colors: [Color(hex: 0xF2A0B2), Color(hex: 0xD16A86)],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(
                    RoundedRectangle(cornerRadius: 16 * s)
                        .strokeBorder(Color(hex: 0xFFD2DC, opacity: 0.9), lineWidth: 2 * s)
                        .mask(LinearGradient(colors: [.white, .clear],
                                             startPoint: .top, endPoint: .bottom))
                )
                .overlay(alignment: .bottomTrailing) {
                    HStack(spacing: 3 * s) {
                        Circle().fill(Color(hex: 0xFFE4EB, opacity: 0.7)).frame(width: 5 * s)
                        Circle().fill(Color(hex: 0xFFE4EB, opacity: 0.5)).frame(width: 3.5 * s)
                    }
                    .padding(8 * s)
                }
        )
        .shadow(color: Tokens.Palette.midnight.opacity(0.32), radius: 6 * s, y: 5 * s)
    }

    // 8. Mother-of-pearl: nacre sheen with pearls at the ends
    private func nacre(_ s: CGFloat) -> some View {
        Text("Coral Reef")
            .font(baloo(25, weight: 700, scale: s))
            .foregroundStyle(Color(hex: 0x1A3B5C))
            .padding(.top, 8 * s).padding(.bottom, 4 * s)
            .padding(.horizontal, 26 * s)
            .background(nacreBg(s))
            .overlay(alignment: .leading) {
                ArtImage("ui/pearl.png").frame(width: 18 * s, height: 18 * s)
                    .offset(x: -8 * s, y: -12 * s)
            }
            .overlay(alignment: .trailing) {
                ArtImage("ui/pearl.png").frame(width: 13 * s, height: 13 * s)
                    .offset(x: 6 * s, y: 12 * s)
            }
            .shadow(color: Tokens.Palette.midnight.opacity(0.3), radius: 6 * s, y: 5 * s)
    }

    private func nacreBg(_ s: CGFloat) -> some View {
        let sheen: LinearGradient = LinearGradient(colors: [
            Color(hex: 0xFFF3F0), Color(hex: 0xE4F6EE),
            Color(hex: 0xEFEAFF), Color(hex: 0xFFF8E6),
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
        return Capsule().fill(sheen)
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.9), lineWidth: 2 * s))
    }

    // 9. Watercolor wash: the label painted into the picture
    private func wash(_ s: CGFloat) -> some View {
        ZStack {
            Ellipse().fill(Color(hex: 0xBFE9F2, opacity: 0.6))
                .frame(width: 236 * s, height: 62 * s)
                .blur(radius: 5 * s)
                .rotationEffect(.degrees(-3))
            Ellipse().fill(Color(hex: 0x8FD4E8, opacity: 0.4))
                .frame(width: 198 * s, height: 44 * s)
                .blur(radius: 7 * s)
                .offset(x: 10 * s, y: 7 * s)
            Text("Coral Reef")
                .font(baloo(28, weight: 700, scale: s))
                .foregroundStyle(Color(hex: 0x124A66))
                .rotationEffect(.degrees(-2))
        }
    }

    // 10. Caustic light: letters made of sunbeams through water
    private func caustic(_ s: CGFloat) -> some View {
        Text("Coral Reef")
            .font(baloo(30, weight: 700, scale: s))
            .foregroundStyle(
                LinearGradient(colors: [Color(hex: 0xFFFBE8), Color(hex: 0xFFE9A8)],
                               startPoint: .top, endPoint: .bottom))
            .shadow(color: Color(hex: 0xFFD86B, opacity: 0.9), radius: 6 * s)
            .shadow(color: Color(hex: 0xFFF6D8, opacity: 0.8), radius: 1.5 * s)
            .shadow(color: Color(hex: 0x0A2238, opacity: 0.35), radius: 10 * s, y: 4 * s)
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
    let n: Int
    let s: CGFloat
    var body: some View {
        ZStack {
            Circle().fill(Color(hex: 0x0A2238, opacity: 0.8))
            Text("\(n)")
                .font(baloo(16, weight: 700, scale: s))
                .foregroundStyle(.white)
        }
    }
}

private struct RopeArc: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height))
        p.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height),
                       control: CGPoint(x: rect.width / 2, y: -rect.height * 0.8))
        return p
    }
}
#endif
