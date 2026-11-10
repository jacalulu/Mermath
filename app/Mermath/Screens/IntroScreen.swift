import SwiftUI

/// The opening story: ONE continuous camera move (~36s, tap to skip).
/// The camera swims through the treasure gallery - three painted wall
/// segments glide by behind organic rock pillars and drifting motes - and
/// arrives, without a cut, at the grotto's entrance: treasure ledges beside
/// a big cave-mouth window onto open water. The whale cruises past OUTSIDE
/// the window, a frond tickles its nose, it inflates while everything
/// rattles - ACHOO - the shelves blast bare, the lights dim, one lone pearl
/// rolls to a stop. Then the map, and the crab's rally while the sheepish
/// whale peeks in.
struct IntroScreen: View {
    let speak: (Prompt) -> Void
    let play: (SoundPlayer.Effect) -> Void
    /// Called when the intro ends; `true` when the crab already asked
    /// "Who is diving today?" so the pick screen should not ask again.
    let onDone: (Bool) -> Void

    @Environment(\.stage) private var m
    @State private var spoken: Set<Int> = []
    @State private var start: Double?
    @State private var finished = false

    private func beat(_ t: Double, _ from: Double, _ to: Double) -> Double {
        min(1, max(0, (t - from) / (to - from)))
    }

    private func easeOut(_ v: Double) -> Double { 1 - pow(1 - v, 3) }
    private func smooth(_ v: Double) -> Double { v * v * (3 - 2 * v) }

    var body: some View {
        let s = m.scale
        MotionClock { t in
            let tl = t - (start ?? t)
            ZStack {
                // ---- The continuous shot: swim, arrive, sneeze, quiet
                if tl < 26.8 {
                    let cam = smooth(beat(tl, 0.3, 12.0)) * 2400
                    let dx = 2400 - cam                        // entrance offset
                    let bob = Wave.alternate(t, from: -7, to: 7, duration: 3.4)
                        * (1 - beat(tl, 11.2, 12.4))           // bob fades on arrival
                    let rattle = tl > 17.8 && tl < 20.0
                        ? sin(tl * 34) * 3 * beat(tl, 17.8, 20.0) : 0
                    let sc = easeOut(beat(tl, 20.1, 21.9))     // the scatter
                    let quiet = beat(tl, 21.0, 23.0)           // dim afterwards
                    Group {
                        // The gallery segments slide past
                        ForEach(0..<3, id: \.self) { i in
                            ArtImage("scenes/intro/wall-\(["a", "b", "c"][i]).jpg")
                                .stage(x: CGFloat(i) * 800 - cam - 1, y: 0, w: 802, h: 600)
                        }

                        // The entrance: open water, the whale, then the wall
                        ArtImage("scenes/intro/home-bg.jpg")
                            .stage(x: dx - 1, y: 0, w: 802, h: 600)

                        // The whale, outside the window (the wall occludes it)
                        if tl > 12.5 && tl < 21.7 {
                            let cruise = easeOut(beat(tl, 12.5, 16.0))
                            let inflate = beat(tl, 17.8, 20.0)
                            let lunge = beat(tl, 20.05, 20.3)
                            let exitP = beat(tl, 20.8, 21.7)
                            let scaleW = 0.62 + inflate * 0.14 + lunge * 0.06
                            let wx = dx + 880 - cruise * 540 - lunge * 70 - exitP * 900
                            WhaleIntroView(scale: s, uhoh: tl > 16.4 && tl < 20.6,
                                           breathe: inflate > 0 ? sin(inflate * 3.4 * .pi) * 0.05 : 0,
                                           facingRight: false)
                                .scaleEffect(scaleW)
                                .stage(x: wx, y: 150 + Wave.alternate(t, from: -7, to: 7, duration: 3.1), w: 568, h: 240)
                        }
                        // The tickling frond at the window's lower rim
                        if tl > 15.5 && tl < 20.1 {
                            KelpLayer(t: t, path: "scenes/tide-pool/seagrass.png",
                                      from: -16, to: 16, duration: 0.5, pivot: UnitPoint(x: 0.5, y: 1))
                                .stage(x: dx + 500, y: 420, w: 120, h: 56)
                        }

                        ArtImage("scenes/intro/home-wall.png")
                            .stage(x: dx - 1, y: 0, w: 802, h: 600)

                        // The shelf treasures (gone once the sneeze hits)
                        ArtImage("scenes/intro/home-items.png")
                            .opacity(1 - min(1, sc * 3))
                            .stage(x: dx + 46 + rattle, y: 106, w: 310, h: 494)

                        // The hero treasures, live so they rattle and fly
                        Group {
                            Rectangle()
                                .fill(Color(hex: 0x0A3444))
                                .opacity(1 - sc)
                                .stage(x: dx + 399, y: 0, w: 2.5, h: 118)
                            GlowPulse(t: t, color: Color(hex: 0xFFE9A8), fromOpacity: 0.4, toOpacity: 0.9, duration: 1.8)
                                .opacity(1 - min(1, sc * 2))
                                .stage(x: dx + 330, y: 100, w: 140, h: 140)
                            ArtImage("scenes/grotto/starfish-lamp.png")
                                .rotationEffect(.degrees(-sc * 240))
                                .stage(x: dx + 348 + rattle - sc * 620, y: 118 - sc * 380, w: 104, h: 100)
                            ArtImage("scenes/grotto/kelp-curtain.png")
                                .rotationEffect(.degrees(-sc * 160))
                                .stage(x: dx + 424 + rattle - sc * 420, y: 0 - sc * 400, w: 118, h: 277)
                            ArtImage("scenes/grotto/shell-bed.png")
                                .rotationEffect(.degrees(-sc * 120))
                                .stage(x: dx + 212 + rattle - sc * 760, y: 442 + sc * 320, w: 220, h: 148)
                        }

                        // Pearls and sparkles spray with the sneeze
                        if sc > 0 && sc < 1 {
                            ForEach(0..<10, id: \.self) { i in
                                let a = Double(i) / 10 * 2 * .pi + 0.4
                                ArtImage("ui/pearl.png")
                                    .opacity(1 - sc)
                                    .stage(x: dx + 420 + cos(a) * 430 * sc - 9,
                                           y: 300 + sin(a) * 330 * sc - 9, w: 18, h: 18)
                            }
                        }
                        if tl > 20.1 && tl < 23.5 {
                            TwinkleStar(t: t, duration: 1.4).stage(x: 200, y: 180, w: 24, h: 24)
                            TwinkleStar(t: t, duration: 1.7, delay: 0.4).stage(x: 540, y: 140, w: 20, h: 20)
                            TwinkleStar(t: t, duration: 1.5, delay: 0.8).stage(x: 380, y: 340, w: 22, h: 22)
                        }

                        // The lone pearl that rolls to a stop in the quiet
                        if tl > 23.3 {
                            let roll = easeOut(beat(tl, 23.5, 25.7))
                            ArtImage("ui/pearl.png")
                                .rotationEffect(.degrees(roll * 720))
                                .stage(x: 140 + roll * 420, y: 568, w: 22, h: 22)
                        }

                        // Dimming after the loss
                        Rectangle()
                            .fill(Tokens.Palette.midnight)
                            .opacity(quiet * 0.32)
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()

                        // Foreground pillars sweep past during the swim only
                        ForEach(0..<6, id: \.self) { i in
                            ArtImage(i % 2 == 0 ? "props/pillar-a.png" : "props/pillar-b.png")
                                .stage(x: CGFloat(i) * 560 + 60 - cam * 1.45,
                                       y: 0, w: i % 2 == 0 ? 234 : 168, h: 600)
                        }
                        // Drifting motes, closest of all
                        if tl < 12.5 {
                            ForEach(0..<7, id: \.self) { i in
                                ArtImage("props/bubble.png")
                                    .opacity(0.5)
                                    .stage(x: CGFloat(i) * 560 - cam * 1.8 + 110,
                                           y: 80 + CGFloat((i * 137) % 400) + bob * 2,
                                           w: 15 + CGFloat(i % 3) * 7, h: 15 + CGFloat(i % 3) * 7)
                            }
                        }

                        // The sneeze: whiteout
                        if tl > 20.05 && tl < 20.9 {
                            Color.white
                                .opacity(0.75 * (1 - beat(tl, 20.1, 20.9)))
                                .stage(x: 0, y: 0, w: 800, h: 600)
                                .bleed()
                        }
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()
                    }
                    .offset(x: tl > 20.05 && tl < 20.8 ? sin(t * 56) * 8 * s * (1 - beat(tl, 20.05, 20.8)) : 0,
                            y: bob * s)
                    .transition(.opacity)
                }

                // ---- The treasures sink toward the zones
                if tl >= 26.8 && tl < 31.3 {
                    let fall = beat(tl, 27.0, 30.8)
                    Group {
                        ArtImage("scenes/reef-map/bg.jpg")
                            .stage(x: 0, y: 0, w: 800, h: 600)
                        ArtImage("scenes/reef-map/seabed.png")
                            .stage(x: 0, y: 206, w: 800, h: 394)
                    }
                    .bleed()
                    ArtImage("scenes/grotto/starfish-lamp.png")
                        .opacity(1 - fall * 0.6)
                        .stage(x: 120 + fall * 20, y: -80 + fall * 400, w: 70, h: 67)
                    ArtImage("scenes/grotto/kelp-curtain.png")
                        .opacity(1 - fall * 0.6)
                        .stage(x: 420, y: -160 + fall * 420, w: 60, h: 141)
                    ArtImage("scenes/grotto/shell-bed.png")
                        .opacity(1 - fall * 0.6)
                        .stage(x: 640 - fall * 10, y: -60 + fall * 500, w: 90, h: 61)
                    TwinkleStar(t: t, duration: 1.6).stage(x: 150, y: 300 + fall * 40, w: 26, h: 26)
                    TwinkleStar(t: t, duration: 2.0, delay: 0.5).stage(x: 440, y: 240 + fall * 60, w: 22, h: 22)
                    TwinkleStar(t: t, duration: 1.8, delay: 1.0).stage(x: 680, y: 380 + fall * 60, w: 24, h: 24)
                    Vignette()
                        .stage(x: 0, y: 0, w: 800, h: 600)
                        .bleed()
                }

                // ---- The crab rallies; the whale peeks in, sheepish
                if tl >= 31.3 {
                    Group {
                        ArtImage("scenes/home/bg.jpg")
                            .stage(x: 0, y: 0, w: 800, h: 600)
                        ArtImage("scenes/home/foreground.png")
                            .stage(x: 0, y: 440, w: 800, h: 160)
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                    }
                    .bleed()
                    let pop = easeOut(beat(tl, 31.3, 32.0))
                    CrabView(t: t, scale: s)
                        .stage(x: 275, y: 620 - pop * 310, w: 250, h: 211)
                    let peek = easeOut(beat(tl, 32.8, 33.9))
                    if peek > 0 {
                        WhaleIntroView(scale: s, uhoh: false, breathe: 0)
                            .rotationEffect(.degrees(10))
                            .stage(x: -560 + peek * 220, y: 60, w: 568, h: 240)
                    }
                }

                // Skip hint, quietly in the corner
                Text("Tap to skip")
                    .font(baloo(15, weight: 600, scale: s))
                    .foregroundStyle(Tokens.Palette.pearl.opacity(0.65))
                    .stageTopRight(right: 28, y: 28)
            }
            .onChange(of: Int(t * 10)) {
                if start == nil { start = t }
                for (i, at, prompt) in [(1, 0.6, PromptScript.intro1),
                                        (2, 12.5, PromptScript.intro2),
                                        (3, 23.2, PromptScript.intro3),
                                        (4, 31.5, PromptScript.intro4)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    speak(prompt)
                }
                for (i, at, effect) in [(10, 0.2, SoundPlayer.Effect.musicbox),
                                        (11, 17.8, SoundPlayer.Effect.rumble)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    play(effect)
                }
                if tl >= 36.5 && !finished {
                    finished = true
                    onDone(true)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !finished else { return }
            finished = true
            onDone(spoken.contains(4))
        }
    }
}

/// The whale with either its happy face or its pre-sneeze uh-oh face, plus a
/// breathing offset while it winds up.
struct WhaleIntroView: View {
    let scale: CGFloat
    let uhoh: Bool
    let breathe: Double
    var facingRight = true

    var body: some View {
        let w = 568 * scale
        let h = 240 * scale
        ZStack {
            ArtImage("props/whale.png")
                .frame(width: w, height: h)
            ArtImage(uhoh ? "props/whale-face-uhoh.png" : "props/whale-face.png")
                .frame(width: (uhoh ? 106.0 : 130.0) / 568 * w, height: (uhoh ? 88.0 : 86.0) / 240 * h)
                .offset(x: ((uhoh ? (194.0 - 144 + 53) : (170.0 - 144 + 65)) / 568 - 0.5) * w,
                        y: ((uhoh ? (282.0 - 210 + 44) : (278.0 - 210 + 43)) / 240 - 0.5) * h)
        }
        .scaleEffect(x: facingRight ? -1 : 1, y: 1 + breathe)
        .frame(width: w, height: h)
    }
}

/// The little whale on the pick screen (story replay button).
struct WhaleView: View {
    let scale: CGFloat
    var facingRight = true

    var body: some View {
        let w = 568 * scale
        let h = 240 * scale
        ZStack {
            ArtImage("props/whale.png")
                .frame(width: w, height: h)
            ArtImage("props/whale-face.png")
                .frame(width: 130.0 / 568 * w, height: 86.0 / 240 * h)
                .offset(x: ((170.0 - 144 + 65) / 568 - 0.5) * w,
                        y: ((278.0 - 210 + 43) / 240 - 0.5) * h)
        }
        .scaleEffect(x: facingRight ? -1 : 1)
        .frame(width: w, height: h)
    }
}
