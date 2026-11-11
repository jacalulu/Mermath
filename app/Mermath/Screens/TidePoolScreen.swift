import SwiftUI

/// Everything the Tide Pool screen shows; owned by the game layer.
struct TidePoolViewState {
    var prompt: String
    var choices: [Int]
    var target: Int
    var pearls: Int
    var faded: Set<Int> = []
    var solved = false        // gold glow on the right answer
    var diveComplete = false  // tenth pearl: solved panel appears
    var showHint = false
    var solvedText = ""
    var popTrigger = 0
    var partyTrigger = 0
    var partyActive = false
    /// Count level: how many little bubbles to count in the speech bubble.
    var countIcons: Int?
}

/// The locked Tide Pool screen, ported from reference/html/tide-pool-*.html.
/// All coordinates are the 800x600 design space.
struct TidePoolScreen: View {
    let state: TidePoolViewState
    var onAnswer: (Int) -> Void = { _ in }
    var onReplay: () -> Void = {}
    var onMap: () -> Void = {}
    var onOpenChest: () -> Void = {}
    var onBonusPop: (Int) -> Void = { _ in }

    @Environment(\.stage) private var m
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The clock time when the right fish was caught, so it freezes to pop.
    @State private var caughtAt: Double?
    /// Off-stage shift for the fish: after a catch the others swim away,
    /// and a fresh school swims in with the next question. The middle lane
    /// uses the left edge, the others the right, so the school arrives from
    /// both sides - always nose first.
    @State private var fishSlide: CGFloat = 0
    /// 0 none, 1 swimming on, 2 swimming off: forces travel-direction facing.
    @State private var slidePhase = 0

    var body: some View {
        MotionClock { t in
            let s = m.scale
            let depth = Double(state.pearls) / 10   // the dive gets deeper as pearls fill
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

                    // The treasure chest comes into view in the distance
                    // once the dive is seven pearls deep.
                    if state.pearls >= 7 {
                        let w = 44 + 8 * CGFloat(state.pearls - 7)
                        ArtImage("scenes/treasure-chest/chest-box.png")
                            .saturation(0.8)
                            .opacity(0.5 + 0.16 * Double(state.pearls - 7))
                            .stage(x: 618 - w / 2, y: 505 - w * 0.64, w: w, h: w * 0.64)
                            .transition(.opacity)
                    }
                }
                .bleed()
                .scaleEffect(1 + depth * 0.06)   // swimming deeper: the scene drifts closer

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
                    // Deeper water is darker water
                    Rectangle()
                        .fill(Tokens.Palette.midnight)
                        .opacity(depth * 0.22)
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    Vignette()
                        .stage(x: 0, y: 0, w: 800, h: 600)
                }
                .bleed()
                .allowsHitTesting(false)

                // Controls (inside the guaranteed 800x600)
                MapButton(scale: s, action: onMap)
                    .stage(x: 22, y: 20, w: 66, h: 66)
                // The counter gives a little bounce as each pearl arrives
                PearlCounter(filled: state.pearls, scale: s)
                    .keyframeAnimator(initialValue: 1.0, trigger: reduceMotion ? 0 : state.pearls) { content, v in
                        content.scaleEffect(v, anchor: .top)
                    } keyframes: { _ in
                        KeyframeTrack {
                            LinearKeyframe(1.0, duration: 0.72)
                            LinearKeyframe(1.12, duration: 0.1, timingCurve: .easeOut)
                            LinearKeyframe(1.0, duration: 0.2, timingCurve: .easeIn)
                        }
                    }
                    .stageTopRight(right: 24, y: 26)
                // The crab's bubble steps aside for the party and the finale
                if !state.partyActive && !state.diveComplete {
                    SpeechBubbleTail()
                        .stage(x: 180, y: 176, w: 70, h: 54)
                    SpeechBubbleView(
                        text: state.prompt,
                        scale: s,
                        popTrigger: state.popTrigger,
                        countIcons: state.countIcons,
                        replay: onReplay
                    )
                    .stageTopLeft(x: 196, y: 96)
                }

                // The answers swim on the fish themselves; catching the right
                // one is the game. The caught fish hands off to CatchFlight,
                // which carries its numeral up to the pearl counter.
                ForEach(Array(state.choices.enumerated()), id: \.offset) { i, n in
                    let xc = FishLanes.x(i, t)
                    AnswerFish(
                        t: t,
                        lane: i,
                        number: n,
                        state: bubbleState(for: n),
                        scale: s,
                        shakeTrigger: state.faded.contains(n) ? 1 : 0,
                        facingOverride: slidePhase == 1 ? (i == 1) : slidePhase == 2 ? (i != 1) : nil,
                        tap: { onAnswer(n) }
                    )
                    .stage(x: xc - FishLanes.fishW / 2, y: FishLanes.centerY[i] - FishLanes.fishH / 2,
                           w: FishLanes.fishW, h: FishLanes.fishH)
                    .offset(x: fishSlide * (i == 1 ? -1 : 1) * s)
                }

                // The catch: splash, arc to the counter, bubble trail
                let goldLane = state.choices.firstIndex(of: state.target) ?? 1
                CatchFlight(
                    trigger: state.pearls,
                    number: state.target,
                    from: CGPoint(
                        x: FishLanes.x(goldLane, caughtAt ?? t),
                        y: FishLanes.centerY[goldLane]
                    ),
                    to: CGPoint(x: 486 + CGFloat(max(1, min(state.pearls, 10)) - 1) * 28, y: 48),
                    scale: s
                )
                .stage(x: 0, y: 0, w: 800, h: 600)

                // Three in a row: the surprise bubble party rises from below
                BonusBubbleField(t: t, trigger: state.partyTrigger, active: state.partyActive,
                                 scale: s, onPop: onBonusPop)
                .stage(x: 0, y: 0, w: 800, h: 600)

                if state.diveComplete {
                    OpenChestButton(title: "Open the chest", t: t, scale: s, action: onOpenChest)
                        .stageBottomCenter(bottom: 36)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                } else if state.showHint {
                    HintPanel(count: state.target, scale: s)
                        .stageBottomCenter(bottom: 24)
                        .transition(.opacity)
                }
            }
            .onChange(of: state.solved) { _, isSolved in
                caughtAt = isSolved ? t : nil
                if isSolved && !reduceMotion {
                    // The other fish swim off, nose first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        slidePhase = 2
                        withMotion(.easeIn(duration: 0.8)) { fishSlide = 720 }
                    }
                }
            }
            .onChange(of: state.target) {
                // A fresh school swims in with the new question, from both
                // sides of the screen, each fish facing its way in
                guard !reduceMotion else { return }
                var snap = Transaction()
                snap.disablesAnimations = true
                withTransaction(snap) { fishSlide = 720 }
                slidePhase = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withMotion(.easeOut(duration: 1.0)) { fishSlide = 0 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
                    slidePhase = 0
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
