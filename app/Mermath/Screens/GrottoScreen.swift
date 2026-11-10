import SwiftUI

/// "My grotto": earned decorations labelled in place, dashed circles showing
/// what is still to come. The reason to come back tomorrow.
/// Legacy background until the grotto is repainted in the locked look.
struct GrottoScreen: View {
    let child: ChildID
    let progress: ChildProgress
    var onDiveAgain: () -> Void = {}

    @Environment(\.stage) private var m

    private static let labelSpots: [GrottoItem: CGPoint] = [
        .starfishLamp: CGPoint(x: 306, y: 232),
        .kelpCurtain: CGPoint(x: 474, y: 306),
        .shellBed: CGPoint(x: 468, y: 549),
    ]

    private static let upcomingSpots: [CGPoint] = [
        CGPoint(x: 226, y: 126),
        CGPoint(x: 492, y: 132),
        CGPoint(x: 232, y: 486),
    ]

    private static let upcomingLabels = ["Next dive", "2 more dives", "3 more dives"]

    var body: some View {
        let s = m.scale
        ZStack {
            Group {
                ArtImage("legacy/bg-grotto.jpg")
                    .stage(x: 0, y: 0, w: 800, h: 600)
                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
            }
            .bleed()

            // The visiting mermaid, glowing in her sister color
            MotionClock { t in
                SisterView(spec: child.puppet, t: t, scale: s)
                    .frame(width: 226 * s, height: 259 * s)
                    .shadow(color: child.color.opacity(0.65), radius: 8 * s)
            }
            .stage(x: 100, y: 216, w: 226, h: 259)

            Text("My grotto")
                .font(baloo(Tokens.Type.nameTag, weight: 700, scale: s))
                .foregroundStyle(Tokens.Palette.midnight)
                .padding(.top, 6 * s)
                .padding(.bottom, 2 * s)
                .padding(.horizontal, 22 * s)
                .background(Capsule().fill(Tokens.Palette.pearl))
                .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                .stageTopLeft(x: 24, y: 24)

            GoldButton(title: "Dive again", scale: s, action: onDiveAgain)
                .stageTopRight(right: 24, y: 24)

            // Labels on the earned decorations
            ForEach(progress.grottoItems) { item in
                let spot = Self.labelSpots[item] ?? .zero
                let isNew = progress.newestItem == item
                Text(isNew ? "New! \(item.displayName)" : item.displayName)
                    .font(baloo(15, weight: 700, scale: s))
                    .foregroundStyle(isNew ? Tokens.Palette.midnight : Tokens.Palette.pearl)
                    .padding(.vertical, 6 * s)
                    .padding(.horizontal, 12 * s)
                    .background(
                        Capsule().fill(
                            isNew
                                ? AnyShapeStyle(Tokens.Gradients.button)
                                : AnyShapeStyle(Tokens.Palette.panel)
                        )
                    )
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                    .fixedSize()
                    .frame(width: 0, height: 0)   // center on the spot
                    .stage(x: spot.x, y: spot.y, w: 0, h: 0)
            }

            // Dashed circles for what is still to come
            let remaining = GrottoItem.allCases.filter { !progress.grottoItems.contains($0) }
            ForEach(Array(remaining.enumerated()), id: \.element) { index, _ in
                if index < Self.upcomingSpots.count {
                    let spot = Self.upcomingSpots[index]
                    ZStack {
                        Circle().fill(Tokens.Palette.midnight.opacity(0.42))
                        Circle().strokeBorder(
                            style: StrokeStyle(lineWidth: 2.5 * s, dash: [8 * s, 6 * s])
                        )
                        .foregroundStyle(Tokens.Palette.pearl.opacity(0.9))
                        Text(Self.upcomingLabels[min(index, Self.upcomingLabels.count - 1)])
                            .font(baloo(14, weight: 700, scale: s))
                            .foregroundStyle(Tokens.Palette.pearl)
                            .multilineTextAlignment(.center)
                            .padding(6 * s)
                    }
                    .stage(x: spot.x, y: spot.y, w: 88, h: 88)
                }
            }
        }
    }
}
