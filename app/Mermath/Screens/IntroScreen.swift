import SwiftUI

/// The opening story, directed in shots (~32s, tap to skip):
///   1. The hoard - the grotto glitters with treasures, a music box plays.
///   2. The whale cruises by, happy.
///   3. The tickle - a kelp frond brushes its nose. Uh oh.
///   4. The inflate - the whale swells; every treasure starts to rattle.
///   5. ACHOO - whiteout, shake.
///   6. The scatter - treasures comet off in sparkling arcs.
///   7. The quiet - lights dim, one lone pearl rolls to a stop. A beat.
///   8. The map - the treasures sink toward the three zones.
///   9. The rally - the crab calls for help; the whale peeks in, sheepish.
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

    var body: some View {
        let s = m.scale
        MotionClock { t in
            let tl = t - (start ?? t)
            ZStack {
                // ---- Shots 1-7: the grotto, the whale, the sneeze, the quiet
                if tl < 22.3 {
                    let rattle = tl > 13.3 && tl < 15.5
                        ? sin(tl * 34) * 3 * beat(tl, 13.3, 15.5) : 0
                    let sc = easeOut(beat(tl, 15.6, 17.4))      // the scatter
                    let quiet = beat(tl, 16.5, 18.5)            // lights dim after
                    Group {
                        Group {
                            ArtImage("scenes/grotto/bg.jpg")
                                .stage(x: 0, y: 0, w: 800, h: 600)
                            ArtImage("scenes/grotto/floor.png")
                                .stage(x: 0, y: 466, w: 800, h: 134)
                            ArtImage("scenes/grotto/walls.png")
                                .stage(x: 0, y: 0, w: 800, h: 600)
                            ArtImage("scenes/grotto/string-lights.png")
                                .opacity(tl > 13.3 && tl < 15.5
                                         ? (sin(tl * 26) > 0 ? 1 : 0.45)   // flicker
                                         : Wave.alternate(t, from: 0.72, to: 1, duration: 1.7) * (1 - quiet * 0.75))
                                .stage(x: 142, y: 52, w: 516, h: 100)
                            Rectangle()
                                .fill(Tokens.Palette.midnight)
                                .opacity(quiet * 0.3)
                                .stage(x: 0, y: 0, w: 800, h: 600)
                        }
                        .bleed()

                        // The hoard: shelves of treasure, until the sneeze
                        Group {
                            ArtImage("props/hoard-strings.png")
                                .opacity(1 - sc)
                                .rotationEffect(.degrees(sc * -30))
                                .stage(x: 136 + rattle - sc * 160, y: 116 - sc * 420, w: 528, h: 114)
                            ArtImage("props/hoard-left.png")
                                .rotationEffect(.degrees(-sc * 200))
                                .stage(x: 130 - rattle - sc * 500, y: 412 + sc * 300, w: 146, h: 74)
                            ArtImage("props/hoard-right.png")
                                .rotationEffect(.degrees(sc * 220))
                                .stage(x: 566 + rattle + sc * 500, y: 366 + sc * 260, w: 148, h: 126)
                            ArtImage("props/hoard-floor.png")
                                .rotationEffect(.degrees(sc * 90))
                                .stage(x: 310 - rattle + sc * 220, y: 514 + sc * 400, w: 186, h: 56)
                            // The three hero treasures
                            ArtImage("scenes/grotto/kelp-curtain.png")
                                .rotationEffect(.degrees(sc * 160))
                                .stage(x: 570 + rattle + sc * 420, y: 54 + sc * 160, w: 166, h: 390)
                            GlowPulse(t: t, color: Color(hex: 0xFFE9A8), fromOpacity: 0.4, toOpacity: 0.9, duration: 1.8)
                                .opacity(1 - sc * 2)
                                .stage(x: 330, y: 100, w: 140, h: 140)
                            ArtImage("scenes/grotto/starfish-lamp.png")
                                .rotationEffect(.degrees(-sc * 240))
                                .stage(x: 348 - rattle - sc * 640, y: 124 - sc * 460, w: 104, h: 100)
                            ArtImage("scenes/grotto/shell-bed.png")
                                .rotationEffect(.degrees(-sc * 120))
                                .stage(x: 394 + rattle - sc * 820, y: 378 + sc * 420, w: 252, h: 170)
                        }

                        // Pearls and sparkles spray with the sneeze
                        if sc > 0 && sc < 1 {
                            ForEach(0..<10, id: \.self) { i in
                                let a = Double(i) / 10 * 2 * .pi + 0.4
                                ArtImage("ui/pearl.png")
                                    .opacity(1 - sc)
                                    .stage(x: 400 + cos(a) * 430 * sc - 9,
                                           y: 300 + sin(a) * 330 * sc - 9, w: 18, h: 18)
                            }
                        }
                        if tl > 15.6 && tl < 19 {
                            TwinkleStar(t: t, duration: 1.4).stage(x: 220, y: 200, w: 24, h: 24)
                            TwinkleStar(t: t, duration: 1.7, delay: 0.4).stage(x: 560, y: 160, w: 20, h: 20)
                            TwinkleStar(t: t, duration: 1.5, delay: 0.8).stage(x: 420, y: 360, w: 22, h: 22)
                        }

                        // The lone pearl that rolls to a stop in the quiet
                        if tl > 18.8 {
                            let roll = easeOut(beat(tl, 19.0, 21.2))
                            ArtImage("ui/pearl.png")
                                .rotationEffect(.degrees(roll * 720))
                                .stage(x: 160 + roll * 400, y: 536, w: 22, h: 22)
                        }

                        // The whale: cruise, tickle, inflate, ACHOO
                        if tl > 8 && tl < 17.2 {
                            let cruise = easeOut(beat(tl, 8.0, 11.5))
                            let approach = beat(tl, 11.5, 13.3)
                            let inflate = beat(tl, 13.3, 15.5)
                            let lunge = beat(tl, 15.55, 15.8)
                            let exitP = beat(tl, 16.3, 17.2)
                            let scaleW = 0.78 + approach * 0.37 + inflate * 0.5 + lunge * 0.1
                            let wx = -620 + cruise * 520 + approach * 60 - inflate * 90 + lunge * 240 + exitP * 1000
                            WhaleIntroView(scale: s, uhoh: tl > 11.9 && tl < 16.2,
                                           breathe: inflate > 0 ? sin(inflate * 3.4 * .pi) * 0.05 : 0)
                                .scaleEffect(scaleW)
                                .rotationEffect(.degrees(-7 * lunge))
                                .stage(x: wx, y: 120 + Wave.alternate(t, from: -8, to: 8, duration: 3.1), w: 568, h: 240)
                                .transition(.opacity)
                        }
                        // The tickling frond, right where the nose arrives
                        if tl > 11.0 && tl < 15.6 {
                            KelpLayer(t: t, path: "scenes/tide-pool/seagrass.png",
                                      from: -16, to: 16, duration: 0.5, pivot: UnitPoint(x: 0.5, y: 1))
                                .stage(x: 110, y: 330, w: 130, h: 60)
                        }
                        // The sneeze: whiteout
                        if tl > 15.55 && tl < 16.4 {
                            Color.white
                                .opacity(0.75 * (1 - beat(tl, 15.6, 16.4)))
                                .stage(x: 0, y: 0, w: 800, h: 600)
                                .bleed()
                        }
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()
                    }
                    .offset(x: tl > 15.55 && tl < 16.3 ? sin(t * 56) * 8 * s * (1 - beat(tl, 15.55, 16.3)) : 0)
                    .transition(.opacity)
                }

                // ---- Shot 8: the treasures sink toward the zones
                if tl >= 22.3 && tl < 26.8 {
                    let fall = beat(tl, 22.5, 26.3)
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

                // ---- Shot 9: the crab rallies; the whale peeks in, sheepish
                if tl >= 26.8 {
                    Group {
                        ArtImage("scenes/home/bg.jpg")
                            .stage(x: 0, y: 0, w: 800, h: 600)
                        ArtImage("scenes/home/foreground.png")
                            .stage(x: 0, y: 440, w: 800, h: 160)
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                    }
                    .bleed()
                    let pop = easeOut(beat(tl, 26.8, 27.5))
                    CrabView(t: t, scale: s)
                        .stage(x: 275, y: 620 - pop * 310, w: 250, h: 211)
                    // The culprit, peeking in from the edge
                    let peek = easeOut(beat(tl, 28.3, 29.4))
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
                for (i, at, prompt) in [(1, 0.5, PromptScript.intro1),
                                        (2, 8.0, PromptScript.intro2),
                                        (3, 18.6, PromptScript.intro3),
                                        (4, 27.0, PromptScript.intro4)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    speak(prompt)
                }
                for (i, at, effect) in [(10, 0.2, SoundPlayer.Effect.musicbox),
                                        (11, 13.3, SoundPlayer.Effect.rumble)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    play(effect)
                }
                if tl >= 32.0 && !finished {
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
/// breathing offset while it winds up. Faces the direction it swims (right).
struct WhaleIntroView: View {
    let scale: CGFloat
    let uhoh: Bool
    let breathe: Double

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
        .scaleEffect(x: -1, y: 1 + breathe)
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
