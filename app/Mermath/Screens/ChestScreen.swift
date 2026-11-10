import SwiftUI

/// "10 pearls! The chest is open." The reward is a surprise.
/// Legacy background until the chest is repainted in the locked look.
struct ChestScreen: View {
    let earned: GrottoItem?
    var onPlace: () -> Void = {}

    @Environment(\.stage) private var m

    var body: some View {
        let s = m.scale
        ZStack {
            Group {
                ArtImage("legacy/bg-chest.jpg")
                    .stage(x: 0, y: 0, w: 800, h: 600)
                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
            }
            .bleed()

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
