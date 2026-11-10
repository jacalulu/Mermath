import SwiftUI

/// Coral Reef: adding to 10. The Tide Pool layout with a reef scene, the sum
/// in the speech bubble (painted shells over each addend, a dashed slot after
/// the equals), and a colored counting hint. Ported from
/// reference/html/coral-reef-*.html.
struct CoralReefScreen: View {
    let dive: DiveSession
    var onOpenChest: () -> Void = {}
    var onMap: () -> Void = {}

    @Environment(\.stage) private var m
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Where the mermaid floats between answers, and where she is now.
    private static let rest = CGPoint(x: 614, y: 448)
    @State private var mermaidPos = Self.rest
    @State private var mermaidLean: Double = 0
    @State private var pendingAnswer: DispatchWorkItem?

    /// Answer bubble centers (140px bubbles, 26px apart, from x 288, y 240).
    private func bubbleCenter(_ i: Int) -> CGPoint {
        CGPoint(x: 358 + CGFloat(i) * 166, y: 310)
    }

    /// Tapping an answer sends the mermaid swimming to it; the answer counts
    /// when she arrives. Tapping another mid-swim just redirects her.
    private func swim(to lane: Int, answer n: Int) {
        pendingAnswer?.cancel()
        let target = CGPoint(x: bubbleCenter(lane).x, y: 428)
        withMotion(.easeInOut(duration: 0.65)) {
            mermaidLean = target.x > mermaidPos.x + 4 ? 10 : (target.x < mermaidPos.x - 4 ? -10 : 0)
            mermaidPos = target
        }
        let work = DispatchWorkItem { [weak dive] in
            withMotion(.easeOut(duration: 0.25)) { mermaidLean = 0 }
            dive?.answer(n)
        }
        pendingAnswer = work
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.05 : 0.66), execute: work)
    }

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                // Scenery behind the crab (bleeds to the physical edges)
                Group {
                    ArtImage("scenes/coral-reef/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t)
                        .stage(x: 0, y: 0, w: 800, h: 340)
                    KelpLayer(t: t, path: "scenes/coral-reef/kelp-far.png",
                              from: -0.8, to: 0.9, duration: 7, pivot: UnitPoint(x: 0.5, y: 1))
                        .opacity(0.75)
                        .stage(x: 184, y: 0, w: 544, h: 600)
                    FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 30, scale: s)
                        .stage(x: 820, y: 438, w: 44, h: 28)
                    FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 30, delay: 2.5, scale: s)
                        .stage(x: 856, y: 456, w: 33, h: 21)
                    FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 34, delay: 14, scale: s)
                        .stage(x: 830, y: 446, w: 38, h: 24)
                    KelpLayer(t: t, path: "scenes/coral-reef/fan-left.png",
                              from: -2.2, to: 1.8, duration: 4.6, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 0, y: 148, w: 90, h: 354)
                    KelpLayer(t: t, path: "scenes/coral-reef/fan-right.png",
                              from: 1.9, to: -2, duration: 5.2, pivot: UnitPoint(x: 0.78, y: 1))
                        .stage(x: 718, y: 372, w: 82, h: 162)
                    ArtImage("scenes/coral-reef/foreground.png")
                        .stage(x: 0, y: 272, w: 800, h: 328)
                    KelpLayer(t: t, path: "scenes/coral-reef/seagrass.png",
                              from: -7, to: 7, duration: 2.8, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 296, y: 540, w: 246, h: 60)
                    RockingStar(t: t)
                        .stage(x: 404, y: 458, w: 58, h: 58)
                    HoppingStar(t: t, scale: s)
                        .stage(x: 512, y: 470, w: 46, h: 46)
                    RisingBubble(t: t, duration: 9, scale: s)
                        .stage(x: 258, y: 560, w: 30, h: 30)
                    RisingBubble(t: t, duration: 12, delay: 3, scale: s)
                        .stage(x: 766, y: 580, w: 24, h: 24)
                    RisingBubble(t: t, duration: 15, delay: 6, scale: s)
                        .stage(x: 46, y: 590, w: 20, h: 20)
                }
                .bleed()

                // The crab: the whole puppet replays the prompt
                Button(action: { dive.replay() }) {
                    CrabView(t: t, scale: s)
                }
                .buttonStyle(.plain)
                .stage(x: 15, y: 204, w: 250, h: 211)

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                // Controls (inside the guaranteed 800x600)
                MapButton(scale: s, action: onMap)
                    .stage(x: 22, y: 20, w: 66, h: 66)
                PearlCounter(filled: dive.pearls, scale: s)
                    .stageTopRight(right: 24, y: 26)
                SpeechBubbleTail()
                    .stage(x: 180, y: 184, w: 70, h: 54)

                if case let .addition(a, b, showShells) = dive.question.presentation {
                    ReefSpeechBubble(
                        a: a, b: b,
                        answer: dive.solved ? dive.question.target : nil,
                        showShells: showShells,
                        scale: s,
                        popTrigger: dive.popTrigger,
                        replay: { dive.replay() }
                    )
                    .stageTopLeft(x: 196, y: 88)
                }

                HStack(spacing: Tokens.Space.answerGap * s) {
                    ForEach(Array(dive.question.choices.enumerated()), id: \.offset) { i, n in
                        AnswerBubble(
                            number: n,
                            state: bubbleState(for: n),
                            scale: s,
                            tap: { swim(to: i, answer: n) }
                        )
                    }
                }
                .stageTopLeft(x: 288, y: 240)

                // The diver herself: she swims to whichever bubble was tapped,
                // leaning into the turn, and spins when she wins the pearl.
                SisterView(spec: dive.child.puppet, t: t, scale: s)
                    .frame(width: 130 * s, height: 149 * s)
                    .rotationEffect(.degrees(mermaidLean))
                    .keyframeAnimator(initialValue: 0.0, trigger: reduceMotion ? 0 : dive.pearls) { content, spin in
                        content.rotationEffect(.degrees(dive.pearls > 0 ? spin : 0))
                    } keyframes: { _ in
                        KeyframeTrack {
                            LinearKeyframe(0.0, duration: 0.05)
                            LinearKeyframe(360.0, duration: 0.65, timingCurve: .easeInOut)
                        }
                    }
                    .allowsHitTesting(false)
                    .stage(x: mermaidPos.x - 65, y: mermaidPos.y - 74, w: 130, h: 149)

                // The won pearl arcs from the popped bubble into the counter
                let goldLane = dive.question.choices.firstIndex(of: dive.question.target) ?? 1
                PearlDelivery(
                    trigger: dive.pearls,
                    from: bubbleCenter(goldLane),
                    to: CGPoint(x: 486 + CGFloat(max(1, min(dive.pearls, 10)) - 1) * 28, y: 48),
                    scale: s
                )
                .stage(x: 0, y: 0, w: 800, h: 600)

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
                    ReefHintPanel(a: a, b: b, scale: s)
                        .stageBottomCenter(bottom: 24)
                        .transition(.opacity)
                }
            }
        }
    }

    private func bubbleState(for n: Int) -> AnswerBubbleState {
        if dive.solved && n == dive.question.target { return .gold }
        if dive.faded.contains(n) { return .faded }
        return .normal
    }
}

/// The sum in the speech bubble: shell replay button, countable painted shells
/// over each addend, and a dashed answer slot that turns gold when solved.
struct ReefSpeechBubble: View {
    let a: Int
    let b: Int
    let answer: Int?
    let showShells: Bool
    let scale: CGFloat
    let popTrigger: Int
    let replay: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 10 * scale) {
            Button(action: replay) {
                ArtImage("ui/icon-shell.png")
                    .frame(width: 82 * scale, height: 70 * scale)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 2 * scale)
            addend(a, shell: "props/shell-orange.png")
            op("+")
            addend(b, shell: "props/shell-teal.png")
            op("=")
            slot
        }
        .padding(.top, 8 * scale)
        .padding(.bottom, 6 * scale)
        .padding(.leading, 12 * scale)
        .padding(.trailing, 24 * scale)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.speechBubble * scale)
                .fill(Tokens.Palette.pearl)
        )
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 11 * scale, y: 10 * scale)
        .keyframeAnimator(initialValue: 1.0, trigger: popTrigger) { content, value in
            content.scaleEffect(value)
        } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(1.06, duration: 0.2, timingCurve: .easeOut)
                LinearKeyframe(1.0, duration: 0.3, timingCurve: .easeOut)
            }
        }
    }

    private func addend(_ n: Int, shell: String) -> some View {
        // Shells wrap five per row (like the counting bubbles), so the bubble
        // never pushes past the stage even for 7 + 3. The reference's 46px
        // size holds while a single row fits.
        let w = n <= 5 ? min(46, 190 / CGFloat(n)) * scale : 28 * scale
        let rows = stride(from: 0, to: n, by: 5).map { min(5, n - $0) }
        return VStack(spacing: 2 * scale) {
            if showShells {
                VStack(spacing: 3 * scale) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, count in
                        HStack(spacing: 3 * scale) {
                            ForEach(0..<count, id: \.self) { _ in
                                ArtImage(shell)
                                    .frame(width: w, height: w * 0.8)
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
            Text("\(n)")
                .font(baloo(60, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.midnight)
                .fixedSize()
        }
    }

    private func op(_ symbol: String) -> some View {
        Text(symbol)
            .font(baloo(44, weight: 700, scale: scale))
            .foregroundStyle(Color(hex: 0x17617A))
            .fixedSize()
            .padding(.bottom, 4 * scale)
    }

    @ViewBuilder private var slot: some View {
        if let answer {
            Text("\(answer)")
                .font(baloo(42, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.midnight)
                .frame(width: 60 * scale, height: 60 * scale)
                .background(
                    Circle().fill(
                        RadialGradient(
                            stops: [
                                .init(color: Tokens.Palette.pearl, location: 0),
                                .init(color: Color(hex: 0xFFD27A), location: 0.42),
                                .init(color: Color(hex: 0xFF9A3D), location: 1),
                            ],
                            center: UnitPoint(x: 0.32, y: 0.24),
                            startRadius: 0,
                            endRadius: 60 * scale
                        )
                    )
                )
                .overlay(Circle().stroke(Color.white, lineWidth: 3 * scale))
                .shadow(color: Color(hex: 0xFFD27A, opacity: 0.95), radius: 9 * scale)
                .padding(.bottom, 4 * scale)
        } else {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 3 * scale, dash: [8 * scale, 6 * scale]))
                .foregroundStyle(Tokens.Palette.midnight.opacity(0.4))
                .frame(width: 60 * scale, height: 60 * scale)
                .padding(.bottom, 4 * scale)
        }
    }
}

/// "Count all the shells: 1, 2, 3 and then 4, 5" with each run colored to
/// match its shells (soft orange, then soft teal).
struct ReefHintPanel: View {
    let a: Int
    let b: Int
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 12 * scale) {
            Text("Count all the shells:")
                .font(baloo(24, weight: 600, scale: scale))
                .foregroundStyle(Tokens.Palette.pearl)
            Text((1...a).map(String.init).joined(separator: ", "))
                .font(baloo(24, weight: 700, scale: scale))
                .foregroundStyle(Color(hex: 0xFFB267))
            Text("and then")
                .font(baloo(24, weight: 600, scale: scale))
                .foregroundStyle(Tokens.Palette.pearl)
            Text(((a + 1)...(a + b)).map(String.init).joined(separator: ", "))
                .font(baloo(24, weight: 700, scale: scale))
                .foregroundStyle(Color(hex: 0x8FE9DF))
        }
        .padding(.top, 15 * scale)
        .padding(.bottom, 12 * scale)
        .padding(.horizontal, 28 * scale)
        .background(Capsule().fill(Tokens.Palette.panel))
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * scale, y: 6 * scale)
    }
}
