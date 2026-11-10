import SwiftUI

/// "10 pearls! The chest is open." The reward is a surprise: the earned item
/// floats in the chest's column of light.
struct ChestScreen: View {
    let earned: GrottoItem?
    var onPlace: () -> Void = {}

    @Environment(\.stage) private var m

    /// Where the earned item floats above the open chest (design space).
    private func revealFrame(_ item: GrottoItem) -> CGRect {
        switch item {
        case .starfishLamp: return CGRect(x: 270, y: 50, width: 260, height: 260)
        case .kelpCurtain: return CGRect(x: 359, y: 56, width: 82, height: 231)
        case .shellBed: return CGRect(x: 260, y: 88, width: 280, height: 200)
        }
    }

    var body: some View {
        let s = m.scale
        ZStack {
            Group {
                ArtImage("scenes/chest/bg.jpg")
                    .stage(x: 0, y: 0, w: 800, h: 600)
                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
            }
            .bleed()

            if let earned {
                let f = revealFrame(earned)
                ArtImage(earned.sprite)
                    .shadow(color: Color(hex: 0xFFD27A, opacity: 0.7), radius: 24 * s)
                    .stage(x: f.minX, y: f.minY, w: f.width, h: f.height)
                    .transition(.opacity)
            }

            VStack(spacing: 12 * s) {
                Text("10 pearls! The chest is open.")
                    .font(baloo(Tokens.TypeScale.nameTag, weight: 700, scale: s))
                    .foregroundStyle(Tokens.Palette.midnight)
                    .padding(.top, 6 * s)
                    .padding(.bottom, 2 * s)
                    .padding(.horizontal, 24 * s)
                    .background(Capsule().fill(Tokens.Palette.pearl))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                HStack(spacing: 9 * s) {
                    ForEach(0..<10, id: \.self) { _ in
                        ArtImage("ui/pearl.png")
                            .frame(width: 20 * s, height: 20 * s)
                            .shadow(color: Tokens.Palette.pearl.opacity(0.9), radius: 6 * s)
                    }
                }
            }
            .stageTopCenter(y: 28)

            SolvedPanel(
                text: earned.map { "You earned a \($0.displayName.lowercased())" }
                    ?? "Your grotto is full of treasures!",
                buttonTitle: earned == nil ? "See my grotto" : "Put it in my grotto",
                scale: s,
                action: onPlace
            )
            .stageBottomCenter(bottom: 24)
        }
    }
}
