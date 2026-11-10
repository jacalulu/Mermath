import SwiftUI

/// "Where shall we dive?" Any unlocked zone is tappable; the child's usual
/// zone glows brighter. Deep Sea stays locked (its questions are not designed).
/// Legacy background until the map is repainted in the locked look.
struct ReefMapScreen: View {
    let child: ChildID
    var onDive: (Zone) -> Void = { _ in }
    var onSwitchMermaid: () -> Void = {}

    @Environment(\.stage) private var m

    var body: some View {
        let s = m.scale
        let usual = (child == .ophelia) ? Zone.coralReef : Zone.tidePool
        ZStack {
            Group {
                ArtImage("legacy/bg-map.jpg")
                    .stage(x: 0, y: 0, w: 800, h: 600)
                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
            }
            .bleed()

            Text("Where shall we dive?")
                .font(baloo(Tokens.TypeScale.nameTag, weight: 700, scale: s))
                .foregroundStyle(Tokens.Palette.midnight)
                .padding(.top, 6 * s)
                .padding(.bottom, 2 * s)
                .padding(.horizontal, 22 * s)
                .background(Capsule().fill(Tokens.Palette.pearl))
                .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                .stageTopLeft(x: 24, y: 26)

            GoldButton(title: "Switch mermaid", scale: s, action: onSwitchMermaid)
                .stageTopRight(right: 24, y: 24)

            ZoneCircle(
                name: "Tide Pool",
                subtitle: "Find the number",
                sample: "1 2 3",
                ring: Color(hex: 0x8FE9DF),
                highlighted: usual == .tidePool,
                scale: s,
                action: { onDive(.tidePool) }
            )
            .stage(x: 52, y: 150, w: 214, h: 214)

            ZoneCircle(
                name: "Coral Reef",
                subtitle: "Adding to 10",
                sample: "3 + 2",
                ring: Tokens.Palette.goldfish,
                highlighted: usual == .coralReef,
                scale: s,
                action: { onDive(.coralReef) }
            )
            .stage(x: 306, y: 242, w: 228, h: 228)

            LockedZoneCircle(
                name: "Deep Sea",
                subtitle: "Counting by 2s and 5s",
                scale: s
            )
            .stage(x: 568, y: 338, w: 186, h: 186)
        }
    }
}

private struct ZoneFill: View {
    var body: some View {
        Circle().fill(
            RadialGradient(
                stops: [
                    .init(color: Color.white.opacity(0.85), location: 0),
                    .init(color: Color.white.opacity(0.14), location: 0.11),
                    .init(color: Tokens.Palette.midnight.opacity(0.54), location: 0.38),
                    .init(color: Tokens.Palette.midnight.opacity(0.68), location: 1),
                ],
                center: UnitPoint(x: 0.26, y: 0.17),
                startRadius: 0,
                endRadius: 150
            )
        )
    }
}

struct ZoneCircle: View {
    let name: String
    let subtitle: String
    let sample: String
    let ring: Color
    let highlighted: Bool
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                ZoneFill()
                Circle().strokeBorder(ring, lineWidth: 4 * scale)
                VStack(spacing: 3 * scale) {
                    Text(name)
                        .font(baloo(30, weight: 700, scale: scale))
                        .foregroundStyle(Tokens.Palette.pearl)
                    Text(subtitle)
                        .font(baloo(16, weight: 700, scale: scale))
                        .foregroundStyle(Tokens.Palette.pearl)
                    Text(sample)
                        .font(baloo(42, weight: 700, scale: scale))
                        .foregroundStyle(ring)
                }
                .shadow(color: Tokens.Palette.midnight.opacity(0.8), radius: 5 * scale, y: 2 * scale)
            }
            .shadow(color: ring.opacity(highlighted ? 0.85 : 0.45), radius: (highlighted ? 26 : 16) * scale)
            .scaleEffect(highlighted ? 1.04 : 1)
        }
        .buttonStyle(.plain)
    }
}

struct LockedZoneCircle: View {
    let name: String
    let subtitle: String
    let scale: CGFloat

    private let gold = Color(hex: 0xFFD27A)

    var body: some View {
        ZStack {
            ZoneFill().opacity(0.85)
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 3 * scale, dash: [9 * scale, 7 * scale]))
                .foregroundStyle(gold)
            VStack(spacing: 3 * scale) {
                LockGlyph(color: gold)
                    .frame(width: 30 * scale, height: 30 * scale)
                Text(name)
                    .font(baloo(26, weight: 700, scale: scale))
                    .foregroundStyle(gold)
                Text(subtitle)
                    .font(baloo(14, weight: 700, scale: scale))
                    .foregroundStyle(Tokens.Palette.pearl)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14 * scale)
            }
            .shadow(color: Tokens.Palette.midnight.opacity(0.8), radius: 5 * scale, y: 2 * scale)
        }
        .shadow(color: gold.opacity(0.35), radius: 14 * scale)
    }
}

/// Simple padlock strokes (placeholder until a painted lock exists).
struct LockGlyph: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let line = w * 0.09
            ZStack {
                RoundedRectangle(cornerRadius: w * 0.12)
                    .stroke(color, lineWidth: line)
                    .frame(width: w * 0.62, height: w * 0.42)
                    .position(x: w / 2, y: w * 0.68)
                Path { p in
                    p.addArc(
                        center: CGPoint(x: w / 2, y: w * 0.42),
                        radius: w * 0.2,
                        startAngle: .degrees(180),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                }
                .stroke(color, style: StrokeStyle(lineWidth: line, lineCap: .round))
            }
        }
    }
}
