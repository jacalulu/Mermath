import SwiftUI

/// Everything the Tide Pool screen shows; owned by the game layer.
struct TidePoolViewState {
    var prompt: String
    var choices: [Int]
    var target: Int
    var pearls: Int
    var faded: Set<Int> = []
    var solved = false
    var showHint = false
    var solvedText = ""
    var popTrigger = 0
}

/// The locked Tide Pool screen, ported from reference/html/tide-pool-*.html.
/// All coordinates are the 800x600 design space.
struct TidePoolScreen: View {
    let state: TidePoolViewState
    var onAnswer: (Int) -> Void = { _ in }
    var onReplay: () -> Void = {}
    var onMap: () -> Void = {}
    var onOpenChest: () -> Void = {}

    @Environment(\.stage) private var m

    var body: some View {
        MotionClock { t in
            let s = m.scale
            ZStack {
                // Scenery behind the crab (bleeds to the physical edges)
                Group {
                    ArtImage("scenes/tide-pool/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t)
                        .stage(x: 0, y: 0, w: 800, h: 340)
                    KelpLayer(t: t, path: "scenes/tide-pool/kelp-far.png",
                              from: -0.8, to: 0.9, duration: 7, pivot: UnitPoint(x: 0.5, y: 1))
                        .opacity(0.75)
                        .stage(x: 200, y: 0, w: 560, h: 600)
                    KelpLayer(t: t, path: "scenes/tide-pool/kelp-mid.png",
                              from: 1.3, to: -1.4, duration: 6, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 30, scale: s)
                        .stage(x: 820, y: 430, w: 44, h: 28)
                    FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 30, delay: 2.5, scale: s)
                        .stage(x: 856, y: 448, w: 33, h: 21)
                    KelpLayer(t: t, path: "scenes/tide-pool/kelp-left.png",
                              from: -1.7, to: 1.3, duration: 5, pivot: UnitPoint(x: 0, y: 1))
                        .stage(x: 0, y: 0, w: 240, h: 600)
                    ArtImage("scenes/tide-pool/foreground.png")
                        .stage(x: 0, y: 350, w: 800, h: 250)
                    KelpLayer(t: t, path: "scenes/tide-pool/seagrass.png",
                              from: -7, to: 7, duration: 2.8, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 0, y: 480, w: 800, h: 102)
                    RockingStar(t: t)
                        .stage(x: 392, y: 452, w: 66, h: 66)
                    HoppingStar(t: t, scale: s)
                        .stage(x: 498, y: 468, w: 52, h: 52)
                    RisingBubble(t: t, duration: 9, scale: s)
                        .stage(x: 258, y: 560, w: 30, h: 30)
                    RisingBubble(t: t, duration: 12, delay: 3, scale: s)
                        .stage(x: 766, y: 580, w: 24, h: 24)
                    RisingBubble(t: t, duration: 15, delay: 6, scale: s)
                        .stage(x: 46, y: 590, w: 20, h: 20)
                }
                .bleed()

                // The crab: the whole puppet replays the prompt
                Button(action: onReplay) {
                    CrabView(t: t, scale: s)
                }
                .buttonStyle(.plain)
                .stage(x: 15, y: 204, w: 250, h: 211)

                // Scenery in front of the crab
                Group {
                    KelpLayer(t: t, path: "scenes/tide-pool/kelp-right.png",
                              from: -1.4, to: 1.6, duration: 5.5, pivot: UnitPoint(x: 1, y: 1),
                              rotate: true)
                        .stage(x: 580, y: 0, w: 220, h: 600)
                    Vignette()
                        .stage(x: 0, y: 0, w: 800, h: 600)
                }
                .bleed()

                // Controls (inside the guaranteed 800x600)
                MapButton(scale: s, action: onMap)
                    .stage(x: 22, y: 20, w: 66, h: 66)
                PearlCounter(filled: state.pearls, scale: s)
                    .stageTopRight(right: 24, y: 26)
                SpeechBubbleTail()
                    .stage(x: 180, y: 176, w: 70, h: 54)
                SpeechBubbleView(
                    text: state.prompt,
                    scale: s,
                    popTrigger: state.popTrigger,
                    replay: onReplay
                )
                .stageTopLeft(x: 196, y: 96)

                HStack(spacing: Tokens.Space.answerGap * s) {
                    ForEach(state.choices, id: \.self) { n in
                        AnswerBubble(
                            number: n,
                            state: bubbleState(for: n),
                            scale: s,
                            tap: { onAnswer(n) }
                        )
                    }
                }
                .stageTopLeft(x: 288, y: 230)

                if state.solved {
                    SolvedPanel(
                        text: state.solvedText,
                        buttonTitle: "Open the chest",
                        scale: s,
                        action: onOpenChest
                    )
                    .stageBottomCenter(bottom: 24)
                    .transition(.opacity)
                } else if state.showHint {
                    HintPanel(count: state.target, scale: s)
                        .stageBottomCenter(bottom: 24)
                        .transition(.opacity)
                }
            }
        }
    }

    private func bubbleState(for n: Int) -> AnswerBubbleState {
        if state.solved && n == state.target { return .gold }
        if state.faded.contains(n) { return .faded }
        return .normal
    }
}
