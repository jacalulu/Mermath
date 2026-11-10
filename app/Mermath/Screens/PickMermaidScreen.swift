import SwiftUI

/// The locked pick-your-mermaid screen, ported from
/// reference/html/pick-your-mermaid.html. "Who is diving today?"
struct PickMermaidScreen: View {
    var onPick: (ChildID) -> Void = { _ in }
    var onParentGate: () -> Void = {}

    @Environment(\.stage) private var m

    private let sisterX: [ChildID: CGFloat] = [.ophelia: 38, .daphne: 278, .violet: 518]

    var body: some View {
        MotionClock { t in
            let s = m.scale
            ZStack {
                // Scenery (bleeds to the physical edges)
                Group {
                    ArtImage("scenes/home/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t)
                        .stage(x: 0, y: 0, w: 800, h: 340)
                    KelpLayer(t: t, path: "scenes/home/kelp-far.png",
                              from: -0.8, to: 0.9, duration: 7, pivot: UnitPoint(x: 0.5, y: 1))
                        .opacity(0.75)
                        .stage(x: 100, y: 0, w: 650, h: 600)
                    KelpLayer(t: t, path: "scenes/home/kelp-mid.png",
                              from: 1.3, to: -1.4, duration: 6, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    FishSwim(t: t, travel: 940, bobDown: 7, bobUp: 8, duration: 30, delay: -3, scale: s)
                        .stage(x: 830, y: 318, w: 44, h: 28)
                    FishSwim(t: t, travel: 940, bobDown: 7, bobUp: 8, duration: 34, delay: -9, scale: s)
                        .stage(x: 830, y: 352, w: 34, h: 22)
                    FishSwim(t: t, travel: 940, bobDown: 7, bobUp: 8, duration: 38, delay: -15, scale: s)
                        .stage(x: 830, y: 392, w: 28, h: 18)
                    FishSwim(t: t, travel: 940, bobDown: 7, bobUp: 8, duration: 31, delay: -21, scale: s)
                        .stage(x: 830, y: 334, w: 40, h: 25)
                    FishSwim(t: t, travel: 940, bobDown: 7, bobUp: 8, duration: 40, delay: -6, scale: s)
                        .stage(x: 830, y: 374, w: 30, h: 19)
                    KelpLayer(t: t, path: "scenes/home/kelp-left.png",
                              from: -1.7, to: 1.3, duration: 5, pivot: UnitPoint(x: 0, y: 1))
                        .stage(x: 0, y: 0, w: 260, h: 600)
                    KelpLayer(t: t, path: "scenes/home/kelp-right.png",
                              from: 1.5, to: -1.4, duration: 5.6, pivot: UnitPoint(x: 1, y: 1))
                        .stage(x: 540, y: 0, w: 260, h: 600)
                    ArtImage("scenes/home/foreground.png")
                        .stage(x: 0, y: 440, w: 800, h: 160)
                    KelpLayer(t: t, path: "scenes/home/seagrass.png",
                              from: -7, to: 7, duration: 2.8, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 0, y: 505, w: 800, h: 90)
                    RockingStar(t: t)
                        .stage(x: 392, y: 530, w: 80, h: 80)
                    HoppingStar(t: t, scale: s)
                        .stage(x: 560, y: 548, w: 64, h: 64)
                    RisingBubble(t: t, duration: 9, scale: s)
                        .stage(x: 258, y: 560, w: 30, h: 30)
                    RisingBubble(t: t, duration: 12, delay: 3, scale: s)
                        .stage(x: 512, y: 580, w: 24, h: 24)
                    RisingBubble(t: t, duration: 15, delay: 6, scale: s)
                        .stage(x: 764, y: 590, w: 20, h: 20)
                }
                .bleed()

                // The three sisters (tap = pick)
                ForEach(ChildID.allCases) { child in
                    Button(action: { onPick(child) }) {
                        ZStack(alignment: .topLeading) {
                            SisterView(spec: child.puppet, t: t, scale: s)
                                .frame(width: 242 * s, height: 278 * s)
                            // Centered on x = 117 inside the frame, 282 from its top
                            NamePill(name: child.displayName, dot: child.color, scale: s)
                                .fixedSize()
                                .frame(width: 234 * s)
                                .padding(.top, 282 * s)
                        }
                        .frame(width: 242 * s, height: 322 * s, alignment: .topLeading)
                    }
                    .buttonStyle(.plain)
                    .stage(x: sisterX[child] ?? 0, y: 156, w: 242, h: 322)
                }

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                // Wordmark; a two-second hold opens the parent screen
                WordmarkView(t: t)
                    .stage(x: 248, y: 18, w: 304, h: 102)
                    .onLongPressGesture(minimumDuration: 2, perform: onParentGate)

                Text("Who is diving today?")
                    .font(baloo(Tokens.TypeScale.pill, weight: 600, scale: s))
                    .foregroundStyle(Tokens.Palette.midnight)
                    .padding(.top, 6 * s)
                    .padding(.bottom, 2 * s)
                    .padding(.horizontal, 22 * s)
                    .background(Capsule().fill(Tokens.Palette.pearl))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                    .stageTopCenter(y: 134)
            }
        }
    }
}

/// Pearl name tag with the sister-color dot.
struct NamePill: View {
    let name: String
    let dot: Color
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 8 * scale) {
            Circle()
                .fill(dot)
                .frame(width: 16 * scale, height: 16 * scale)
                .padding(.bottom, 4 * scale)
            Text(name)
                .font(baloo(Tokens.TypeScale.nameTag, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.midnight)
        }
        .padding(.top, 6 * scale)
        .padding(.bottom, 2 * scale)
        .padding(.leading, 14 * scale)
        .padding(.trailing, 20 * scale)
        .background(Capsule().fill(Tokens.Palette.pearl))
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * scale, y: 6 * scale)
    }
}
