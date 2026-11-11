import SwiftUI

/// The painted art for each earned decoration. The chest reveal reuses
/// `sprite` for the curtain and bed; the lamp has its own treasure-chest copy.
extension GrottoItem {
    var sprite: String {
        switch self {
        case .starfishLamp: return "scenes/grotto/starfish-lamp.png"
        case .kelpCurtain: return "scenes/grotto/kelp-curtain.png"
        case .shellBed: return "scenes/grotto/shell-bed.png"
        }
    }

    /// Height over width of the sprite art, for aspect-correct previews.
    var spriteAspect: CGFloat {
        switch self {
        case .starfishLamp: return 100.0 / 104
        case .kelpCurtain: return 390.0 / 166
        case .shellBed: return 170.0 / 252
        }
    }

    /// Where this item's label pill sits in the grotto (centered on x, top y).
    var labelSpot: CGPoint {
        switch self {
        case .starfishLamp: return CGPoint(x: 400, y: 240)
        case .kelpCurtain: return CGPoint(x: 483, y: 294)
        case .shellBed: return CGPoint(x: 330, y: 556)
        }
    }

    /// The dashed "coming soon" circle for this item (stage top-left, 92px).
    var slotSpot: CGPoint {
        switch self {
        case .starfishLamp: return CGPoint(x: 330, y: 128)
        case .kelpCurtain: return CGPoint(x: 440, y: 140)
        case .shellBed: return CGPoint(x: 290, y: 448)
        }
    }
}

/// "My grotto": earned decorations in place under the string lights, dashed
/// circles for what is still to come. Ported from reference/html/grotto.html.
struct GrottoScreen: View {
    let child: ChildID
    let progress: ChildProgress
    var onDiveAgain: () -> Void = {}

    @Environment(\.stage) private var m

    private static let slotLabels = ["Next dive", "2 more dives", "3 more dives"]

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                // THE grotto from the story: the sisters' cozy home from the
                // intro, with the round window onto open water and the shelves
                // waiting to be filled again (bleeds to the physical edges)
                Group {
                    ArtImage("scenes/intro/home-bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 26, delay: -6, scale: s)
                        .stage(x: 830, y: 240, w: 40, h: 25)
                    FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 31, delay: -19, scale: s)
                        .stage(x: 850, y: 330, w: 30, h: 19)
                    ArtImage("scenes/intro/home-wall.png")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t, center: UnitPoint(x: 0.5, y: 0), maxOpacity: 0.3)
                        .stage(x: 440, y: 60, w: 350, h: 430)
                }
                .bleed()

                // Earned decorations, back exactly where the story keeps them
                if progress.grottoItems.contains(.kelpCurtain) {
                    KelpLayer(t: t, path: "scenes/grotto/kelp-curtain.png",
                              from: -2.4, to: 2.2, duration: 4.2, pivot: UnitPoint(x: 0.5, y: 0))
                        .stage(x: 424, y: 0, w: 118, h: 277)
                        .transition(.opacity)
                }
                ArtImage("scenes/grotto/string-lights.png")
                    .opacity(Wave.alternate(t, from: 0.72, to: 1, duration: 1.7))
                    .stage(x: 142, y: 52, w: 516, h: 100)
                RisingBubble(t: t, duration: 10, scale: s)
                    .stage(x: 350, y: 560, w: 26, h: 26)
                RisingBubble(t: t, duration: 13, delay: 4, scale: s)
                    .stage(x: 660, y: 580, w: 20, h: 20)

                if progress.grottoItems.contains(.starfishLamp) {
                    SwingingLamp(t: t, scale: s)
                        .frame(width: 180 * s, height: 240 * s)
                        .stage(x: 310, y: 0, w: 180, h: 240)
                        .transition(.opacity)
                }
                if progress.grottoItems.contains(.shellBed) {
                    ArtImage("scenes/grotto/shell-bed.png")
                        .stage(x: 210, y: 430, w: 240, h: 162)
                        .transition(.opacity)
                }

                // The visiting mermaid, big - this is her home
                SisterView(spec: child.puppet, t: t, scale: s)
                    .frame(width: 280 * s, height: 321 * s)
                    .stage(x: 80, y: 210, w: 280, h: 321)

                // Dashed circles where each missing treasure belongs
                let remaining = GrottoItem.allCases.filter { !progress.grottoItems.contains($0) }
                ForEach(Array(remaining.enumerated()), id: \.element) { index, item in
                    if index < Self.slotLabels.count {
                        let spot = item.slotSpot
                        ZStack {
                            Circle().fill(Tokens.Palette.midnight.opacity(0.46))
                            Circle().strokeBorder(
                                style: StrokeStyle(lineWidth: 3 * s, dash: [8 * s, 6 * s])
                            )
                            .foregroundStyle(Tokens.Palette.pearl.opacity(0.95))
                            Text(Self.slotLabels[min(index, Self.slotLabels.count - 1)])
                                .font(baloo(16, weight: 700, scale: s))
                                .foregroundStyle(Tokens.Palette.pearl)
                                .multilineTextAlignment(.center)
                                .padding(6 * s)
                        }
                        .stage(x: spot.x, y: spot.y, w: 92, h: 92)
                    }
                }

                // Labels on the earned decorations
                ForEach(progress.grottoItems) { item in
                    ItemTag(
                        text: progress.newestItem == item ? "New! \(item.displayName)" : item.displayName,
                        isNew: progress.newestItem == item,
                        scale: s
                    )
                    .stage(x: item.labelSpot.x, y: item.labelSpot.y, w: 0, h: 0)
                }

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                Text("My grotto")
                    .font(baloo(26, weight: 700, scale: s))
                    .foregroundStyle(Tokens.Palette.midnight)
                    .padding(.top, 7 * s)
                    .padding(.bottom, 3 * s)
                    .padding(.horizontal, 24 * s)
                    .background(Capsule().fill(Tokens.Palette.pearl))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                    .stageTopLeft(x: 24, y: 24)

                GoldButton(title: "Dive again", scale: s, action: onDiveAgain)
                    .stageTopRight(right: 24, y: 24)
            }
        }
    }
}

/// The starfish lamp on its cord, swinging gently from the cave mouth.
private struct SwingingLamp: View {
    let t: Double
    let scale: CGFloat

    var body: some View {
        // Local frame 180x240; the cord hangs from (89, 0) to (89, 134).
        ZStack(alignment: .topLeading) {
            Color.clear
            Rectangle()
                .fill(Color(hex: 0x0A3444))
                .frame(width: 2.5 * scale, height: 134 * scale)
                .offset(x: 89 * scale)
            GlowPulse(t: t, color: Color(hex: 0xFFE9A8), fromOpacity: 0.45, toOpacity: 1, duration: 1.8)
                .frame(width: 160 * scale, height: 160 * scale)
                .offset(x: 10 * scale, y: 96 * scale)
            ArtImage("scenes/grotto/starfish-lamp.png")
                .frame(width: 104 * scale, height: 100 * scale)
                .offset(x: 38 * scale, y: 124 * scale)
            ArtImage("scenes/grotto/starfish-lamp-face.png")
                .frame(width: 36 * scale, height: 28 * scale)
                .offset(x: 72 * scale, y: 166 * scale)
        }
        .rotationEffect(
            .degrees(Wave.alternate(t, from: -3.5, to: 3.5, duration: 3.2)),
            anchor: UnitPoint(x: 0.5, y: 0)
        )
    }
}

/// An item label: gold "New!" pill or a small Pearl pill, centered on its spot.
private struct ItemTag: View {
    let text: String
    let isNew: Bool
    let scale: CGFloat

    var body: some View {
        Text(text)
            .font(baloo(isNew ? 16 : 15, weight: isNew ? 700 : 600, scale: scale))
            .foregroundStyle(Tokens.Palette.midnight)
            .padding(.top, (isNew ? 6 : 5) * scale)
            .padding(.bottom, 2 * scale)
            .padding(.horizontal, (isNew ? 16 : 14) * scale)
            .background(
                Capsule().fill(
                    isNew
                        ? AnyShapeStyle(Tokens.Gradients.button)
                        : AnyShapeStyle(Tokens.Palette.pearl)
                )
            )
            .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * scale, y: 6 * scale)
            .fixedSize()
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
    }
}
