import SwiftUI

/// The Tide Pool's answer lanes: where each fish patrols and how fast.
/// Lanes are ~104px apart so the fish never come near each other, clear of
/// the crab's face on the left and the hint panel at the bottom.
enum FishLanes {
    /// Display size of an answer fish (design px). Art: props/answer-fish.png,
    /// 166x102 in the manifest, belly patch centered at 41% of the width.
    static let fishW: CGFloat = 150
    static let fishH: CGFloat = 150 * 102 / 166
    static let bellyX: CGFloat = (392 - 324) / 166   // patch center, fraction of width
    static let bellyY: CGFloat = (298 - 232) / 102
    /// Face crop (332,264,44x48) relative to the fish crop (324,232,166x102),
    /// as fractions of the fish frame. (Keep the divisions floating point:
    /// integer literals would pick CGRect's Int initializer and truncate to 0.)
    static let faceFrame = CGRect(x: 8.0 / 166, y: 32.0 / 102, width: 44.0 / 166, height: 48.0 / 102)

    static let centerY: [CGFloat] = [238, 342, 446]
    static let period: [Double] = [15, 18, 21]       // one crossing
    static let phase: [Double] = [-3, -13, -24]
    static let xRange: (from: Double, to: Double) = (300, 690)

    /// Where lane `i`'s fish center is at clock time `t`.
    static func x(_ i: Int, _ t: Double) -> CGFloat {
        Wave.alternate(t, from: xRange.from, to: xRange.to, duration: period[i], delay: phase[i])
    }

    /// True while lane `i`'s fish is swimming to the right.
    static func movingRight(_ i: Int, _ t: Double) -> Bool {
        let p = (t - phase[i]) / period[i]
        return p - floor(p / 2) * 2 < 1
    }
}

/// A painted goldfish wearing its numeral on its belly and carrying its pearl
/// at its nose: the fish never turns into anything, it delivers what it holds.
/// The body (and face, and pearl) flip with the swim direction; the numeral
/// never mirrors.
struct FishBody: View {
    let number: Int
    let facingRight: Bool
    let scale: CGFloat
    /// Hidden once this fish has handed its pearl to the counter.
    var carriesPearl = true

    var body: some View {
        let w = FishLanes.fishW * scale
        let h = FishLanes.fishH * scale
        ZStack {
            Group {
                ArtImage("props/answer-fish.png")
                    .frame(width: w, height: h)
                ArtImage("props/answer-fish-face.png")
                    .frame(width: FishLanes.faceFrame.width * w, height: FishLanes.faceFrame.height * h)
                    .offset(
                        x: (FishLanes.faceFrame.midX - 0.5) * w,
                        y: (FishLanes.faceFrame.midY - 0.5) * h
                    )
                if carriesPearl {
                    ArtImage("ui/pearl.png")
                        .frame(width: 24 * scale, height: 24 * scale)
                        .shadow(color: Tokens.Palette.pearl.opacity(0.8), radius: 4 * scale)
                        .offset(x: -0.5 * w - 2 * scale, y: 0.1 * h)
                }
            }
            .scaleEffect(x: facingRight ? -1 : 1)
            Text("\(number)")
                .font(baloo(46, weight: 700, scale: scale))
                .minimumScaleFactor(0.7)
                .foregroundStyle(Tokens.Palette.midnight)
                .offset(
                    x: ((facingRight ? 1 - FishLanes.bellyX : FishLanes.bellyX) - 0.5) * w,
                    y: (FishLanes.bellyY - 0.5) * h + 3 * scale
                )
        }
        .frame(width: w, height: h)
    }
}

/// One answer fish on patrol. Catching the right one is the game: it swims up
/// and delivers its pearl to the counter. A wrong fish just shakes its head,
/// fades, and keeps swimming - never a penalty.
struct AnswerFish: View {
    let t: Double
    let lane: Int
    let number: Int
    let state: AnswerBubbleState
    let scale: CGFloat
    /// Changes when this fish was wrong-tapped: it wiggles "nope" once.
    let shakeTrigger: Int
    let tap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let right = FishLanes.movingRight(lane, t)
        let bob = Wave.alternate(t, from: -4, to: 4, duration: 1.6, delay: FishLanes.phase[lane])
        Button(action: tap) {
            FishBody(number: number, facingRight: right, scale: scale)
                .opacity(state == .faded ? Tokens.Opacity.wrongAnswer : 1)
                .keyframeAnimator(initialValue: 0.0, trigger: reduceMotion ? 0 : shakeTrigger) { content, angle in
                    content.rotationEffect(.degrees(shakeTrigger > 0 && !reduceMotion ? angle : 0))
                } keyframes: { _ in
                    KeyframeTrack {
                        LinearKeyframe(-7, duration: 0.09, timingCurve: .easeOut)
                        LinearKeyframe(7, duration: 0.12, timingCurve: .easeInOut)
                        LinearKeyframe(-5, duration: 0.12, timingCurve: .easeInOut)
                        LinearKeyframe(0, duration: 0.1, timingCurve: .easeIn)
                    }
                }
                .offset(y: bob * scale)
                .contentShape(Rectangle().inset(by: -12 * scale))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(state == .normal)
        .opacity(state == .gold ? 0 : 1)   // the caught fish continues as CatchFlight
    }
}

/// The catch: a splash ring where the fish was caught, then the fish itself -
/// squashing, stretching, tilting into its arc - swims up to the pearl
/// counter with a bubble trail and shrinks into the slot. One shot per pearl.
/// Draws in a full-stage (800x600 design) container.
struct CatchFlight: View {
    /// Fires each time this changes (the pearl count).
    let trigger: Int
    let number: Int
    let from: CGPoint
    /// The counter slot the pearl lands in.
    let to: CGPoint
    let scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Color.clear
            .keyframeAnimator(initialValue: 1.0, trigger: reduceMotion ? 0 : trigger) { _, v in
                ZStack {
                    if v < 1 {
                        // Fish reaches the counter at `arrive`, drops its pearl
                        // there, and keeps swimming off the top of the stage.
                        let arrive = 0.72
                        let u = min(v / arrive, 1)
                        // Splash ring at the catch point
                        if v < 0.28 {
                            let r = v / 0.28
                            Circle()
                                .stroke(Tokens.Palette.pearl, lineWidth: 5 * scale * (1 - r))
                                .frame(width: (70 + 120 * r) * scale, height: (70 + 120 * r) * scale)
                                .opacity(1 - r)
                                .position(x: from.x * scale, y: from.y * scale)
                        }
                        // Bubble trail behind the fish
                        ForEach(0..<5, id: \.self) { i in
                            let tv = u - 0.09 * Double(i + 1)
                            if tv > 0 {
                                let p = Self.path(from: from, to: to, tv)
                                ArtImage("props/bubble.png")
                                    .frame(width: (16 - CGFloat(i) * 2) * scale, height: (16 - CGFloat(i) * 2) * scale)
                                    .opacity(max(0, 0.9 - tv))
                                    .position(x: p.x * scale, y: p.y * scale)
                            }
                        }
                        // The fish, carrying its pearl up to the counter
                        let right = to.x > from.x
                        let exit = CGPoint(x: to.x + (right ? 180 : -180), y: to.y - 150)
                        let p = v <= arrive
                            ? Self.path(from: from, to: to, u)
                            : CGPoint(
                                x: to.x + (exit.x - to.x) * (v - arrive) / (1 - arrive),
                                y: to.y + (exit.y - to.y) * (v - arrive) / (1 - arrive)
                            )
                        let fishScale = 1 - 0.66 * min(1, v / arrive)
                        // Squash on the catch, stretch into the launch
                        let squash = Wave.keyframes(v, [(0, 1), (0.05, 0.82), (0.13, 1.14), (0.22, 1)])
                        FishBody(number: number, facingRight: right, scale: scale, carriesPearl: v <= arrive)
                            .scaleEffect(x: fishScale * (2 - squash), y: fishScale * squash)
                            .rotationEffect(.degrees(Wave.keyframes(u, [(0, 0), (0.25, right ? -32 : 32), (0.9, right ? -14 : 14), (1, 0)])))
                            .opacity(v > 0.88 ? max(0, (1 - v) / 0.12) : 1)
                            .position(x: p.x * scale, y: p.y * scale)
                        // The delivered pearl settles into its slot
                        if v > arrive {
                            let settle = (v - arrive) / (1 - arrive)
                            ArtImage("ui/pearl.png")
                                .frame(width: 22 * scale, height: 22 * scale)
                                .scaleEffect(Wave.keyframes(settle, [(0, 1.5), (0.5, 0.95), (1, 1)]))
                                .opacity(1 - settle * settle)
                                .position(x: to.x * scale, y: to.y * scale)
                        }
                    }
                }
            } keyframes: { _ in
                KeyframeTrack {
                    LinearKeyframe(0.0, duration: 0.0001)
                    LinearKeyframe(1.0, duration: 1.0, timingCurve: .easeInOut)
                }
            }
            .allowsHitTesting(false)
    }

    /// The flight path: an arc that rises above the straight line, like a fish
    /// darting up, never a straight elevator.
    static func path(from: CGPoint, to: CGPoint, _ v: Double) -> CGPoint {
        let ease = v * v * (3 - 2 * v)   // smoothstep
        return CGPoint(
            x: from.x + (to.x - from.x) * ease,
            y: from.y + (to.y - from.y) * ease - sin(.pi * v) * 110
        )
    }
}

/// The Coral Reef's reward: the popped bubble's pearl arcs up to the counter
/// behind a splash ring and a short bubble trail. One shot per pearl.
/// Draws in a full-stage (800x600 design) container.
struct PearlDelivery: View {
    let trigger: Int
    let from: CGPoint
    let to: CGPoint
    let scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Color.clear
            .keyframeAnimator(initialValue: 1.0, trigger: reduceMotion ? 0 : trigger) { _, v in
                ZStack {
                    if v < 1 {
                        if v < 0.3 {
                            let r = v / 0.3
                            Circle()
                                .stroke(Tokens.Palette.pearl, lineWidth: 5 * scale * (1 - r))
                                .frame(width: (120 + 120 * r) * scale, height: (120 + 120 * r) * scale)
                                .opacity(1 - r)
                                .position(x: from.x * scale, y: from.y * scale)
                        }
                        ForEach(0..<4, id: \.self) { i in
                            let tv = v - 0.09 * Double(i + 1)
                            if tv > 0 {
                                let p = CatchFlight.path(from: from, to: to, tv)
                                ArtImage("props/bubble.png")
                                    .frame(width: (15 - CGFloat(i) * 2) * scale, height: (15 - CGFloat(i) * 2) * scale)
                                    .opacity(max(0, 0.9 - tv))
                                    .position(x: p.x * scale, y: p.y * scale)
                            }
                        }
                        let p = CatchFlight.path(from: from, to: to, v)
                        ArtImage("ui/pearl.png")
                            .frame(width: 26 * scale, height: 26 * scale)
                            .shadow(color: Tokens.Palette.pearl.opacity(0.9), radius: 6 * scale)
                            .scaleEffect(Wave.keyframes(v, [(0, 1.4), (0.3, 1), (1, 0.85)]))
                            .opacity(v > 0.92 ? (1 - v) / 0.08 : 1)
                            .position(x: p.x * scale, y: p.y * scale)
                    }
                }
            } keyframes: { _ in
                KeyframeTrack {
                    LinearKeyframe(0.0, duration: 0.0001)
                    LinearKeyframe(1.0, duration: 0.8, timingCurve: .easeInOut)
                }
            }
            .allowsHitTesting(false)
    }
}
