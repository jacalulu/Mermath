import SwiftUI

/// The hidden-object hunt: the chest's map leads here. A legend along the
/// bottom shows what to find and how many; tap each treasure where it hides
/// and it lights its legend slot. Find them all and the lost grotto treasure
/// sparkles into view. Pure reward play - no math, no misses, no penalties.
struct HuntScreen: View {
    let earned: GrottoItem?
    var onDone: () -> Void = {}
    var onFind: (Int) -> Void = { _ in }
    var speakFound: () -> Void = {}

    @Environment(\.stage) private var m

    enum Kind: Int, CaseIterable {
        case star, shell, pearl

        var sprite: String {
            switch self {
            case .star: return "props/sea-star-pink.png"
            case .shell: return "props/shell-orange.png"
            case .pearl: return "ui/pearl.png"
            }
        }

        /// Sprite aspect (h/w), so nothing squashes.
        var aspect: CGFloat {
            switch self {
            case .star: return 1
            case .shell: return 0.8
            case .pearl: return 1
            }
        }
    }

    struct Findable: Identifiable {
        let id: Int
        let kind: Kind
        let x: CGFloat
        let y: CGFloat
        let w: CGFloat
    }

    /// Where the treasures hide (design space), tucked against the scenery.
    private static let findables: [Findable] = [
        Findable(id: 0, kind: .star, x: 146, y: 452, w: 46),
        Findable(id: 1, kind: .star, x: 438, y: 468, w: 42),
        Findable(id: 2, kind: .star, x: 712, y: 496, w: 44),
        Findable(id: 3, kind: .shell, x: 330, y: 504, w: 46),
        Findable(id: 4, kind: .shell, x: 596, y: 466, w: 44),
        Findable(id: 5, kind: .pearl, x: 390, y: 450, w: 28),
    ]

    @State private var found: Set<Int> = []
    @State private var revealed = false

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                // The treasure garden
                Group {
                    ArtImage("scenes/hunt/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t)
                        .stage(x: 0, y: 0, w: 800, h: 340)
                    ArtImage("scenes/hunt/foreground.png")
                        .stage(x: 0, y: 266, w: 800, h: 334)
                    KelpLayer(t: t, path: "scenes/hunt/seagrass.png",
                              from: -7, to: 7, duration: 2.8, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 128, y: 528, w: 598, h: 72)
                }
                .bleed()

                // The treasures, hiding in plain sight
                ForEach(Self.findables) { f in
                    if !found.contains(f.id) {
                        Button {
                            onFind(found.count)
                            withMotion(.easeOut(duration: 0.3)) {
                                _ = found.insert(f.id)
                                if found.count == Self.findables.count {
                                    revealed = true
                                }
                            }
                            if found.count == Self.findables.count {
                                speakFound()
                                // No button: the treasure sparkles in, the
                                // cheer plays, and off to the grotto it goes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
                                    onDone()
                                }
                            }
                        } label: {
                            ArtImage(f.kind.sprite)
                                .rotationEffect(.degrees(Double((f.id * 23) % 30) - 15))
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle().inset(by: -14 * s))
                        .transition(.scale(scale: 1.6).combined(with: .opacity))
                        .stage(x: f.x - f.w / 2, y: f.y - f.w * f.kind.aspect / 2,
                               w: f.w, h: f.w * f.kind.aspect)
                    }
                }

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                // The legend: what to find, and how many are still hiding
                HStack(spacing: 20 * s) {
                    legendGroup(.star, total: 3, scale: s)
                    legendGroup(.shell, total: 2, scale: s)
                    legendGroup(.pearl, total: 1, scale: s)
                    if let earned {
                        // The lost treasure, waiting to be revealed
                        let a = earned.spriteAspect
                        ArtImage(earned.sprite)
                            .saturation(revealed ? 1 : 0)
                            .opacity(revealed ? 1 : 0.35)
                            .frame(width: min(44, 44 / a) * s, height: min(44, 44 / a) * a * s)
                    }
                }
                .padding(.vertical, 10 * s)
                .padding(.horizontal, 24 * s)
                .background(Capsule().fill(Tokens.Palette.panel))
                .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                .opacity(revealed ? 0 : 1)
                .stageBottomCenter(bottom: 24)

                Text("Find the treasures!")
                    .font(baloo(Tokens.TypeScale.nameTag, weight: 700, scale: s))
                    .foregroundStyle(Tokens.Palette.midnight)
                    .padding(.top, 6 * s)
                    .padding(.bottom, 2 * s)
                    .padding(.horizontal, 24 * s)
                    .background(Capsule().fill(Tokens.Palette.pearl))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                    .stageTopCenter(y: 24)

                // Found them all: the lost treasure sparkles into view
                if revealed, let earned {
                    GlowPulse(t: t, color: Color(hex: 0xFFE9A8), fromOpacity: 0.45, toOpacity: 1, duration: 1.8)
                        .stage(x: 300, y: 130, w: 200, h: 200)
                    let a = earned.spriteAspect
                    let rw: CGFloat = a > 1.4 ? 90 : 130
                    ArtImage(earned.sprite)
                        .shadow(color: Color(hex: 0xFFD27A, opacity: 0.8), radius: 20 * s)
                        .offset(y: Wave.bob(t, from: 0, to: -8, duration: 3) * s)
                        .stage(x: 400 - rw / 2, y: 230 - rw * a / 2, w: rw, h: rw * a)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                    TwinkleStar(t: t, duration: 2.2).stage(x: 300, y: 150, w: 22, h: 22)
                    TwinkleStar(t: t, duration: 2.6, delay: 0.7).stage(x: 480, y: 180, w: 18, h: 18)
                    TwinkleStar(t: t, duration: 2, delay: 1.2).stage(x: 420, y: 120, w: 20, h: 20)

                    Text("Off to your grotto it goes!")
                        .font(baloo(24, weight: 700, scale: s))
                        .foregroundStyle(Tokens.Palette.midnight)
                        .padding(.top, 7 * s)
                        .padding(.bottom, 3 * s)
                        .padding(.horizontal, 26 * s)
                        .background(Capsule().fill(Tokens.Palette.pearl))
                        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                        .stageBottomCenter(bottom: 28)
                        .transition(.opacity)
                }
            }
        }
    }

    private func legendGroup(_ kind: Kind, total: Int, scale: CGFloat) -> some View {
        let foundCount = found.intersection(
            Set(Self.findables.filter { $0.kind == kind }.map(\.id))
        ).count
        return HStack(spacing: 6 * scale) {
            ForEach(0..<total, id: \.self) { i in
                ArtImage(kind.sprite)
                    .saturation(i < foundCount ? 1 : 0)
                    .opacity(i < foundCount ? 1 : 0.4)
                    .frame(width: 34 * scale, height: 34 * scale * kind.aspect)
            }
        }
    }
}
