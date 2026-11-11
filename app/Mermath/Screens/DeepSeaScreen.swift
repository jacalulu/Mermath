import SwiftUI

/// The Deep Sea: skip counting, Math Blaster style. The mermaid wears her
/// number, and the answers are glowing current rings - tap one and she swims
/// through it. The right ring carries the next number in the count; her badge
/// updates as she passes through. Counting IS the swimming.
struct DeepSeaScreen: View {
    let dive: DiveSession
    var onOpenChest: () -> Void = {}
    var onMap: () -> Void = {}

    @Environment(\.stage) private var m
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let rest = CGPoint(x: 330, y: 420)
    @State private var mermaidPos = Self.rest
    @State private var mermaidLean: Double = 0
    @State private var pendingAnswer: DispatchWorkItem?

    /// The three ring centers, down the right side.
    private func ringCenter(_ i: Int) -> CGPoint {
        CGPoint(x: 648, y: 165 + CGFloat(i) * 155)
    }

    private func swim(to lane: Int, answer n: Int) {
        pendingAnswer?.cancel()
        let target = ringCenter(lane)
        withMotion(.easeInOut(duration: 0.7)) {
            mermaidLean = target.y < mermaidPos.y - 20 ? -14 : 10
            mermaidPos = CGPoint(x: target.x - 10, y: target.y + 6)
        }
        let work = DispatchWorkItem { [weak dive] in
            withMotion(.easeOut(duration: 0.3)) { mermaidLean = 0 }
            dive?.answer(n)
        }
        pendingAnswer = work
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.05 : 0.72), execute: work)
    }

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                // The deep (bleeds to the physical edges)
                Group {
                    ArtImage("scenes/deep-sea/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t, maxOpacity: 0.25)
                        .stage(x: 0, y: 0, w: 800, h: 340)
                    KelpLayer(t: t, path: "scenes/deep-sea/kelp-far.png",
                              from: -0.8, to: 0.9, duration: 7, pivot: UnitPoint(x: 0.5, y: 1))
                        .opacity(0.7)
                        .stage(x: 114, y: 0, w: 628, h: 600)
                    ArtImage("scenes/deep-sea/foreground.png")
                        .stage(x: 0, y: 292, w: 800, h: 308)
                    KelpLayer(t: t, path: "scenes/deep-sea/seagrass.png",
                              from: -7, to: 7, duration: 2.8, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 218, y: 540, w: 436, h: 60)
                    RisingBubble(t: t, duration: 11, scale: s)
                        .stage(x: 90, y: 580, w: 24, h: 24)
                    RisingBubble(t: t, duration: 14, delay: 4, scale: s)
                        .stage(x: 740, y: 590, w: 20, h: 20)
                }
                .bleed()

                // The crab guide on his rock
                Button(action: { dive.replay() }) {
                    CrabView(t: t, scale: s)
                }
                .buttonStyle(.plain)
                .stage(x: 15, y: 204, w: 250, h: 211)

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                MapButton(scale: s, action: onMap)
                    .stage(x: 22, y: 20, w: 66, h: 66)
                PearlCounter(filled: dive.pearls, scale: s)
                    .stageTopRight(right: 24, y: 26)
                SpeechBubbleTail()
                    .stage(x: 180, y: 176, w: 70, h: 54)
                SpeechBubbleView(
                    text: dive.writtenPrompt,
                    scale: s,
                    popTrigger: dive.popTrigger,
                    replay: { dive.replay() }
                )
                .stageTopLeft(x: 196, y: 96)

                // The counting rings
                ForEach(Array(dive.question.choices.enumerated()), id: \.offset) { i, n in
                    CountRing(
                        t: t,
                        number: n,
                        state: ringState(for: n),
                        scale: s,
                        tap: { swim(to: i, answer: n) }
                    )
                    .stage(x: ringCenter(i).x - 70, y: ringCenter(i).y - 70, w: 140, h: 140)
                }

                // The diver, wearing her number
                if case let .skip(_, current) = dive.question.presentation {
                    ZStack(alignment: .bottom) {
                        SisterView(spec: dive.child.puppet, t: t, scale: s)
                            .frame(width: 140 * s, height: 160 * s)
                        Text("\(dive.solved ? dive.question.target : current)")
                            .font(baloo(26, weight: 700, scale: s))
                            .foregroundStyle(Tokens.Palette.midnight)
                            .padding(.top, 5 * s)
                            .padding(.bottom, 1 * s)
                            .padding(.horizontal, 14 * s)
                            .background(Capsule().fill(Tokens.Palette.pearl))
                            .shadow(color: Tokens.Palette.midnight.opacity(0.35), radius: 5 * s, y: 4 * s)
                            .offset(y: 10 * s)
                    }
                    .rotationEffect(.degrees(mermaidLean))
                    .allowsHitTesting(false)
                    .stage(x: mermaidPos.x - 70, y: mermaidPos.y - 85, w: 140, h: 170)
                }

                // The won pearl arcs home
                let goldLane = dive.question.choices.firstIndex(of: dive.question.target) ?? 1
                PearlDelivery(
                    trigger: dive.pearls,
                    from: ringCenter(goldLane),
                    to: CGPoint(x: 486 + CGFloat(max(1, min(dive.pearls, 10)) - 1) * 28, y: 48),
                    scale: s
                )
                .stage(x: 0, y: 0, w: 800, h: 600)

                // The tollbooth payout in the deep
                BonusBubbleField(t: t, trigger: dive.partyTrigger, active: dive.partyActive,
                                 scale: s, onPop: { dive.bubblePopped($0) })
                .stage(x: 0, y: 0, w: 800, h: 600)

                if dive.diveComplete {
                    OpenChestButton(title: "Open the chest", t: t, scale: s, action: onOpenChest)
                        .stageBottomCenter(bottom: 36)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                } else if dive.showHint, case let .skip(step, _) = dive.question.presentation {
                    HStack(spacing: 10 * s) {
                        Text("Count with me:")
                            .font(baloo(24, weight: 600, scale: s))
                            .foregroundStyle(Tokens.Palette.pearl)
                        Text(stride(from: step, through: dive.question.target, by: step)
                            .map(String.init).joined(separator: ", "))
                            .font(baloo(24, weight: 700, scale: s))
                            .foregroundStyle(Color(hex: 0x8FE9DF))
                    }
                    .padding(.top, 15 * s)
                    .padding(.bottom, 12 * s)
                    .padding(.horizontal, 28 * s)
                    .background(Capsule().fill(Tokens.Palette.panel))
                    .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * s, y: 6 * s)
                    .stageBottomCenter(bottom: 24)
                    .transition(.opacity)
                }
            }
            .onChange(of: dive.solved) { _, isSolved in
                if isSolved {
                    // She darts on through the ring she just counted into
                    withMotion(.easeOut(duration: 0.5)) {
                        mermaidPos.x += 120
                    }
                }
            }
            .onChange(of: dive.question.target) {
                // A new wave of rings: glide back to the starting spot
                withMotion(.easeInOut(duration: 0.6)) {
                    mermaidPos = Self.rest
                    mermaidLean = 0
                }
            }
        }
    }

    private func ringState(for n: Int) -> AnswerBubbleState {
        if dive.solved && n == dive.question.target { return .gold }
        if dive.faded.contains(n) { return .faded }
        return .normal
    }
}

/// A glowing current ring holding a number. Gold when swum through correctly,
/// faded after a wrong try - and it never does anything punitive.
private struct CountRing: View {
    let t: Double
    let number: Int
    let state: AnswerBubbleState
    let scale: CGFloat
    let tap: () -> Void

    var body: some View {
        Button(action: tap) {
            ZStack {
                Circle()
                    .fill(Tokens.Palette.midnight.opacity(state == .gold ? 0 : 0.3))
                Circle()
                    .stroke(
                        state == .gold
                            ? AnyShapeStyle(Tokens.Gradients.button)
                            : AnyShapeStyle(Color(hex: 0x8FE9DF)),
                        lineWidth: 9 * scale
                    )
                    .shadow(color: state == .gold
                            ? Color(hex: 0xFFD27A, opacity: 0.95)
                            : Color(hex: 0x8FE9DF, opacity: 0.55),
                            radius: 12 * scale)
                Text("\(number)")
                    .font(baloo(56, weight: 700, scale: scale))
                    .foregroundStyle(Tokens.Palette.pearl)
                    .shadow(color: Tokens.Palette.midnight.opacity(0.8), radius: 4 * scale, y: 2 * scale)
            }
            .scaleEffect(Wave.alternate(t, from: 0.97, to: 1.03, duration: 1.8, delay: Double(number)))
            .opacity(state == .faded ? Tokens.Opacity.wrongAnswer : 1)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(state == .normal)
    }
}
