import SwiftUI

/// Where each earned decoration lives: the painted sprite and the design-space
/// frame it was cropped at (art-pipeline/scenes4.py crops at 2x these boxes),
/// so every item lands exactly where scene_grotto composed it.
extension GrottoItem {
    var sprite: String {
        switch self {
        case .starfishLamp: return "props/starfish-lamp.png"
        case .kelpCurtain: return "props/kelp-curtain.png"
        case .shellBed: return "props/shell-bed.png"
        }
    }

    var grottoFrame: CGRect {
        switch self {
        case .starfishLamp: return CGRect(x: 270, y: 48, width: 260, height: 260)
        case .kelpCurtain: return CGRect(x: 580, y: 40, width: 150, height: 420)
        case .shellBed: return CGRect(x: 380, y: 360, width: 280, height: 200)
        }
    }

    var labelSpot: CGPoint {
        switch self {
        case .starfishLamp: return CGPoint(x: 400, y: 268)
        case .kelpCurtain: return CGPoint(x: 655, y: 340)
        case .shellBed: return CGPoint(x: 520, y: 528)
        }
    }
}

/// "My grotto": earned decorations labelled in place, dashed circles showing
/// what is still to come. The reason to come back tomorrow.
struct GrottoScreen: View {
    let child: ChildID
    let progress: ChildProgress
    var onDiveAgain: () -> Void = {}

    @Environment(\.stage) private var m

    private static let upcomingSpots: [CGPoint] = [
        CGPoint(x: 210, y: 130),
        CGPoint(x: 150, y: 540),
        CGPoint(x: 712, y: 540),
    ]

    private static let upcomingLabels = ["Next dive", "2 more dives", "3 more dives"]

    var body: some View {
        let s = m.scale
        ZStack {
            Group {
                ArtImage("scenes/grotto/bg.jpg")
                    .stage(x: 0, y: 0, w: 800, h: 600)
                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
            }
            .bleed()

            // Earned decorations, placed where the scene composed them
            ForEach(progress.grottoItems) { item in
                if item == .starfishLamp {
                    // The lamp hangs from the top of the light shaft
                    Rectangle()
                        .fill(Color(hex: 0x06182C))
                        .stage(x: 398.75, y: 0, w: 2.5, h: 150)
                }
                ArtImage(item.sprite)
                    .stage(x: item.grottoFrame.minX, y: item.grottoFrame.minY,
                           w: item.grottoFrame.width, h: item.grottoFrame.height)
                    .transition(.opacity)
            }

            // The visiting mermaid, glowing in her sister color
            MotionClock { t in
                SisterView(spec: child.puppet, t: t, scale: s)
                    .frame(width: 226 * s, height: 259 * s)
                    .shadow(color: child.color.opacity(0.65), radius: 8 * s)
            }
            .stage(x: 100, y: 216, w: 226, h: 259)

            Text("My grotto")
                .font(baloo(Tokens.TypeScale.nameTag, weight: 700, scale: s))
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
                let spot = item.labelSpot
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
