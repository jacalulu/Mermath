import SwiftUI

/// The opening story, directed in shots (~36s, tap to skip):
///   1. THE SWIM - a multiplane pan through the treasure gallery: three
///      painted wall segments glide by while dark rock pillars sweep past in
///      the foreground and motes drift closer still. Music box plays.
///   2. Arrive at the home corner, stuffed with treasure.
///   3. The whale cruises in, happy. A frond tickles its nose. Uh oh.
///   4. The inflate - the whale swells; every treasure rattles.
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
    private func smooth(_ v: Double) -> Double { v * v * (3 - 2 * v) }

    var body: some View {
        let s = m.scale
        MotionClock { t in
            let tl = t - (start ?? t)
            ZStack {
                // ---- Shot 1: the swim through the treasure gallery
                if tl < 11.0 {
                    let cam = smooth(beat(tl, 0.3, 10.2)) * 1600   // camera x
                    let bobY = Wave.alternate(t, from: -7, to: 7, duration: 3.4)
                    Group {
                        ForEach(0..<3, id: \.self) { i in
                            ArtImage("scenes/intro/wall-\(["a", "b", "c"][i]).jpg")
                                .stage(x: CGFloat(i) * 800 - cam, y: 0, w: 800, h: 600)
                        }
                        // Foreground rock pillars sweep past faster (multiplane);
                        // oversized so their cut edges stay off screen
                        ForEach(0..<3, id: \.self) { i in
                            ArtImage("scenes/grotto/walls.png")
                                .stage(x: CGFloat(i) * 1380 - cam * 1.45 - 280, y: -170, w: 1340, h: 1000)
                        }
                        // Drifting motes, closest of all
                        ForEach(0..<7, id: \.self) { i in
                            ArtImage("props/bubble.png")
                                .opacity(0.5)
                                .stage(x: CGFloat(i) * 420 - cam * 1.8 + 110,
                                       y: 80 + CGFloat((i * 137) % 400) + bobY * 2,
                                       w: 15 + CGFloat(i % 3) * 7, h: 15 + CGFloat(i % 3) * 7)
                        }
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()
                    }
                    .offset(y: bobY * s)
                    .opacity(1 - beat(tl, 10.2, 11.0))
                }

                // ---- Shots 2-7: the home corner, the whale, the sneeze
                if tl >= 10.2 && tl < 26.8 {
                    let rattle = tl > 17.8 && tl < 20.0
                        ? sin(tl * 34) * 3 * beat(tl, 17.8, 20.0) : 0
                    let sc = easeOut(beat(tl, 20.1, 21.9))      // the scatter
                    let quiet = beat(tl, 21.0, 23.0)            // lights dim after
                    Group {
                        Group {
                            ArtImage("scenes/grotto/bg.jpg")
                                .stage(x: 0, y: 0, w: 800, h: 600)
                            ArtImage("scenes/grotto/floor.png")
                                .stage(x: 0, y: 466, w: 800, h: 134)
                            ArtImage("scenes/grotto/walls.png")
                                .stage(x: 0, y: 0, w: 800, h: 600)
                            ArtImage("scenes/grotto/string-lights.png")
                                .opacity(tl > 17.8 && tl < 20.0
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
                            // More of the hoard, borrowed and mirrored
                            ArtImage("props/hoard-floor.png")
                                .scaleEffect(x: -1)
                                .rotationEffect(.degrees(-sc * 140))
                                .stage(x: 92 - rattle - sc * 420, y: 530 + sc * 360, w: 150, h: 45)
                            ArtImage("props/hoard-left.png")
                                .scaleEffect(x: -1)
                                .rotationEffect(.degrees(sc * 180))
                                .stage(x: 470 + rattle + sc * 560, y: 492 + sc * 320, w: 120, h: 61)
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
                        if tl > 20.1 && tl < 23.5 {
                            TwinkleStar(t: t, duration: 1.4).stage(x: 220, y: 200, w: 24, h: 24)
                            TwinkleStar(t: t, duration: 1.7, delay: 0.4).stage(x: 560, y: 160, w: 20, h: 20)
                            TwinkleStar(t: t, duration: 1.5, delay: 0.8).stage(x: 420, y: 360, w: 22, h: 22)
                        }

                        // The lone pearl that rolls to a stop in the quiet
                        if tl > 23.3 {
                            let roll = easeOut(beat(tl, 23.5, 25.7))
                            ArtImage("ui/pearl.png")
                                .rotationEffect(.degrees(roll * 720))
                                .stage(x: 160 + roll * 400, y: 536, w: 22, h: 22)
                        }

                        // The whale: cruise, tickle, inflate, ACHOO
                        if tl > 12.5 && tl < 21.7 {
                            let cruise = easeOut(beat(tl, 12.5, 16.0))
                            let approach = beat(tl, 16.0, 17.8)
                            let inflate = beat(tl, 17.8, 20.0)
                            let lunge = beat(tl, 20.05, 20.3)
                            let exitP = beat(tl, 20.8, 21.7)
                            let scaleW = 0.78 + approach * 0.37 + inflate * 0.5 + lunge * 0.1
                            let wx = -620 + cruise * 520 + approach * 60 - inflate * 90 + lunge * 240 + exitP * 1000
                            WhaleIntroView(scale: s, uhoh: tl > 16.4 && tl < 20.6,
                                           breathe: inflate > 0 ? sin(inflate * 3.4 * .pi) * 0.05 : 0)
                                .scaleEffect(scaleW)
                                .rotationEffect(.degrees(-7 * lunge))
                                .stage(x: wx, y: 120 + Wave.alternate(t, from: -8, to: 8, duration: 3.1), w: 568, h: 240)
                                .transition(.opacity)
                        }
                        // The tickling frond, right where the nose arrives
                        if tl > 15.5 && tl < 20.1 {
                            KelpLayer(t: t, path: "scenes/tide-pool/seagrass.png",
                                      from: -16, to: 16, duration: 0.5, pivot: UnitPoint(x: 0.5, y: 1))
                                .stage(x: 110, y: 330, w: 130, h: 60)
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
                    .offset(x: tl > 20.05 && tl < 20.8 ? sin(t * 56) * 8 * s * (1 - beat(tl, 20.05, 20.8)) : 0)
                    .opacity(beat(tl, 10.2, 11.0))
                }

                // ---- Shot 8: the treasures sink toward the zones
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

                // ---- Shot 9: the crab rallies; the whale peeks in, sheepish
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
                    // The culprit, peeking in from the edge
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
