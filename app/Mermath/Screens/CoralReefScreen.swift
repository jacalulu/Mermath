import SwiftUI

/// Coral Reef: adding to 10, with countable shells above each addend that fade
/// as she gets quicker. Legacy background and shells until repainted.
struct CoralReefScreen: View {
    let dive: DiveSession
    var onOpenChest: () -> Void = {}
    var onMap: () -> Void = {}

    @Environment(\.stage) private var m

    var body: some View {
        let s = m.scale
        ZStack {
            Group {
                ArtImage("legacy/bg-coral.jpg")
                    .stage(x: 0, y: 0, w: 800, h: 600)
                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
            }
            .bleed()

            MapButton(scale: s, action: onMap)
                .stage(x: 22, y: 20, w: 66, h: 66)
            PearlCounter(filled: dive.pearls, scale: s)
                .stageTopRight(right: 24, y: 26)

            if case let .addition(a, b, showShells) = dive.question.presentation {
                EquationPanel(
                    a: a, b: b,
                    answer: dive.solved ? dive.question.target : nil,
                    showShells: showShells,
                    scale: s,
                    replay: { dive.replay() }
                )
                .stageTopCenter(y: 100)
            }

            HStack(spacing: Tokens.Space.answerGap * s) {
                ForEach(dive.question.choices, id: \.self) { n in
                    AnswerBubble(
                        number: n,
                        state: bubbleState(for: n),
                        scale: s,
                        tap: { dive.answer(n) }
                    )
                }
            }
            .stageTopCenter(y: 300)

            if dive.diveComplete {
                SolvedPanel(
                    text: dive.solvedText,
                    buttonTitle: "Open the chest",
                    scale: s,
                    action: onOpenChest
                )
                .stageBottomCenter(bottom: 24)
                .transition(.opacity)
            } else if dive.showHint, case let .addition(a, b, _) = dive.question.presentation {
                Text("Count all the shells: \(countText(a, b))")
                    .font(baloo(Tokens.TypeScale.panel, weight: 600, scale: s))
                    .foregroundStyle(Tokens.Palette.pearl)
                    .padding(.top, 3 * s)
                    .padding(.vertical, 12 * s)
                    .padding(.horizontal, 26 * s)
                    .background(Capsule().fill(Tokens.Palette.panel))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                    .stageBottomCenter(bottom: 24)
                    .transition(.opacity)
            }
        }
    }

    private func bubbleState(for n: Int) -> AnswerBubbleState {
        if dive.solved && n == dive.question.target { return .gold }
        if dive.faded.contains(n) { return .faded }
        return .normal
    }

    private func countText(_ a: Int, _ b: Int) -> String {
        let first = (1...a).map(String.init).joined(separator: ", ")
        let rest = ((a + 1)...(a + b)).map(String.init).joined(separator: ", ")
        return "\(first) and then \(rest)"
    }
}

/// The sum with countable shells over each addend and a gold answer box.
struct EquationPanel: View {
    let a: Int
    let b: Int
    let answer: Int?
    let showShells: Bool
    let scale: CGFloat
    let replay: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 20 * scale) {
            addend(a, shell: "legacy/shell-orange.png")
            op("+")
            addend(b, shell: "legacy/shell-teal.png")
            op("=")
            Text(answer.map(String.init) ?? "?")
                .font(baloo(64, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.midnight)
                .frame(minWidth: 76 * scale)
                .padding(.horizontal, 12 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 18 * scale)
                        .fill(Tokens.Gradients.button)
                )
                .shadow(color: Color(hex: 0xFFAA50, opacity: 0.8), radius: 11 * scale)
            Button(action: replay) {
                ArtImage("ui/icon-shell.png")
                    .frame(width: 62 * scale, height: 53 * scale)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 6 * scale)
        }
        .padding(.vertical, 14 * scale)
        .padding(.horizontal, 30 * scale)
        .background(
            RoundedRectangle(cornerRadius: 32 * scale)
                .fill(Tokens.Palette.panel)
        )
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 11 * scale, y: 10 * scale)
    }

    private func addend(_ n: Int, shell: String) -> some View {
        VStack(spacing: 4 * scale) {
            if showShells {
                HStack(spacing: 4 * scale) {
                    ForEach(0..<n, id: \.self) { _ in
                        ArtImage(shell)
                            .frame(width: 42 * scale, height: 34 * scale)
                    }
                }
                .transition(.opacity)
            }
            Text("\(n)")
                .font(baloo(64, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.pearl)
        }
    }

    private func op(_ symbol: String) -> some View {
        Text(symbol)
            .font(baloo(56, weight: 700, scale: scale))
            .foregroundStyle(Color(hex: 0xBFEFEA))
            .padding(.bottom, 2 * scale)
    }
}
