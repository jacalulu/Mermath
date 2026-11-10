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
                // ---- The continuous shot: swim, arrive, sneeze
                if tl < 22.0 {
                    let cam = smooth(beat(tl, 0.3, 12.0)) * 2400
                    let dx = 2400 - cam                        // entrance offset
                    let bob = Wave.alternate(t, from: -7, to: 7, duration: 3.4)
                        * (1 - beat(tl, 11.2, 12.4))           // bob fades on arrival
                    let rattle = tl > 17.8 && tl < 20.0
                        ? sin(tl * 34) * 3 * beat(tl, 17.8, 20.0) : 0
                    let sc = easeOut(beat(tl, 20.1, 21.9))     // the scatter
                    Group {
                        // The gallery segments slide past
                        ForEach(0..<3, id: \.self) { i in
                            ArtImage("scenes/intro/wall-\(["a", "b", "c"][i]).jpg")
                                .stage(x: CGFloat(i) * 800 - cam - 1, y: 0, w: 802, h: 600)
                        }

                        // The entrance: open water, the whale, then the wall
                        ArtImage("scenes/intro/home-bg.jpg")
                            .stage(x: dx - 1, y: 0, w: 802, h: 600)

                        // The whale: approaches outside, squeezes IN through
                        // the window, sniffs the shelves, inflates - and the
                        // sneeze recoil rockets it backward out again.
                        // Drawn twice: once behind the wall (seen through the
                        // hole), once in front, clipped at the window's rim,
                        // so it truly comes through.
                        let whaleOn = tl > 12.5 && tl < 21.6
                        let approach = easeOut(beat(tl, 12.5, 15.2))
                        let through = smooth(beat(tl, 15.2, 16.8))
                        let inflate = beat(tl, 17.8, 20.0)
                        let lunge = beat(tl, 20.05, 20.3)
                        let recoil = easeOut(beat(tl, 20.3, 21.5))
                        // Through the hole it shrinks a touch so its body fits
                        // the opening - squeezing, cartoon style, not clipping.
                        let scaleW = 0.62 + through * 0.12 + inflate * 0.08 + lunge * 0.05 - recoil * 0.28
                        let wx = dx + 900 - approach * 340 - through * 270 - lunge * 60 + recoil * 980
                        let wy = 172 + through * 8 + Wave.alternate(t, from: -6, to: 6, duration: 3.1)
                        let whaleBody = WhaleIntroView(
                            scale: s,
                            uhoh: tl > 16.6 && tl < 20.6,
                            breathe: inflate > 0 ? sin(inflate * 3.4 * .pi) * 0.05 : 0,
                            facingRight: false
                        )
                        if whaleOn {
                            whaleBody
                                .scaleEffect(scaleW)
                                .rotationEffect(.degrees(recoil * 10))
                                .stage(x: wx, y: wy, w: 568, h: 240)
                        }

                        ArtImage("scenes/intro/home-wall.png")
                            .stage(x: dx - 1, y: 0, w: 802, h: 600)

                        // The front half of the whale, inside the room - only
                        // once it has actually crossed the window plane, so
                        // the approach stays properly behind the rim
                        if whaleOn && tl > 15.35 && tl < 20.95 {
                            ZStack {
                                whaleBody
                                    .scaleEffect(scaleW)
                                    .rotationEffect(.degrees(recoil * 10))
                                    .stage(x: wx, y: wy, w: 568, h: 240)
                            }
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .clipShape(InsideRoom(dx: dx, scale: s))
                        }
                        // The tickling frond, by the shelves it sniffs
                        if tl > 16.2 && tl < 20.1 {
                            KelpLayer(t: t, path: "scenes/tide-pool/seagrass.png",
                                      from: -16, to: 16, duration: 0.5, pivot: UnitPoint(x: 0.5, y: 1))
                                .stage(x: dx + 120, y: 420, w: 120, h: 56)
                        }

                        // The shelf treasures (gone once the sneeze hits)
                        ArtImage("scenes/intro/home-items.png")
                            .opacity(1 - min(1, sc * 3))
                            .stage(x: dx + 46 + rattle, y: 106, w: 310, h: 494)

                        // The hero treasures: they rattle, then the blast
                        // throws them - the bed bounces once, the lamp arcs
                        // high, the curtain flutters like a ribbon.
                        Group {
                            Rectangle()
                                .fill(Color(hex: 0x0A3444))
                                .opacity(1 - sc)
                                .stage(x: dx + 399, y: 0, w: 2.5, h: 118)
                            GlowPulse(t: t, color: Color(hex: 0xFFE9A8), fromOpacity: 0.4, toOpacity: 0.9, duration: 1.8)
                                .opacity(1 - min(1, sc * 2))
                                .stage(x: dx + 330, y: 100, w: 140, h: 140)
                            ArtImage("scenes/grotto/starfish-lamp.png")
                                .rotationEffect(.degrees(-sc * 320))
                                .stage(x: dx + 348 + rattle - sc * 620,
                                       y: 118 + Wave.keyframes(sc, [(0, 0), (0.45, -310), (0.7, -180), (1, -540)]),
                                       w: 104, h: 100)
                            ArtImage("scenes/grotto/kelp-curtain.png")
                                .rotationEffect(.degrees(-sc * 120 + sin(sc * 4 * .pi) * 35 * (sc > 0 ? 1 : 0)))
                                .stage(x: dx + 424 + rattle - sc * 440, y: 0 - sc * 420, w: 118, h: 277)
                            ArtImage("scenes/grotto/shell-bed.png")
                                .rotationEffect(.degrees(-sc * 140))
                                .stage(x: dx + 212 + rattle - sc * 800,
                                       y: 442 + Wave.keyframes(sc, [(0, 0), (0.35, 230), (0.52, 150), (1, 480)]),
                                       w: 220, h: 148)
                        }

                        // THE BLAST: shock rings, debris waves, pearls on
                        // gravity arcs, spinning gold stars
                        if sc > 0 && sc < 1 {
                            ForEach(0..<2, id: \.self) { ring in
                                let rp = max(0, min(1, (beat(tl, 20.05, 20.75) - Double(ring) * 0.18) / 0.82))
                                if rp > 0 {
                                    Circle()
                                        .stroke(Tokens.Palette.pearl, lineWidth: 7 * s * (1 - rp))
                                        .opacity((1 - rp) * 0.9)
                                        .stage(x: dx + 150 - 330 * rp, y: 320 - 330 * rp,
                                               w: 660 * rp + 30, h: 660 * rp + 30)
                                }
                            }
                            // Shelf debris, launched across the room
                            ArtImage("props/hoard-strings.png")
                                .rotationEffect(.degrees(-sc * 60))
                                .opacity(1 - sc * sc)
                                .stage(x: dx + 50 - sc * 330, y: 120 - sc * 380, w: 264, h: 57)
                            ArtImage("props/hoard-left.png")
                                .rotationEffect(.degrees(-sc * 280))
                                .stage(x: dx + 90 - sc * 540, y: 205 + Wave.keyframes(sc, [(0, 0), (0.4, 200), (0.56, 130), (1, 390)]), w: 110, h: 56)
                            ArtImage("props/hoard-right.png")
                                .rotationEffect(.degrees(sc * 260))
                                .stage(x: dx + 120 - sc * 480, y: 345 - sc * 300, w: 111, h: 95)
                            ArtImage("props/hoard-floor.png")
                                .rotationEffect(.degrees(sc * 180))
                                .stage(x: dx + 110 - sc * 580, y: 478 + sc * 250, w: 140, h: 42)
                            // Pearls on gravity arcs
                            ForEach(0..<12, id: \.self) { i in
                                let a = Double(i) / 12 * 2 * .pi + 0.3
                                let sp = 1 + Double(i % 3) * 0.35
                                ArtImage("ui/pearl.png")
                                    .opacity(min(1, (1 - sc) * 1.6))
                                    .stage(x: dx + 160 + cos(a) * 420 * sc * sp - 9,
                                           y: 310 + sin(a) * 260 * sc * sp + 200 * sc * sc - 9,
                                           w: 18, h: 18)
                            }
                            // Spinning gold stars
                            ForEach(0..<6, id: \.self) { i in
                                let a = Double(i) / 6 * 2 * .pi + 1.1
                                FourPointStar()
                                    .fill(Color(hex: 0xFFD27A))
                                    .rotationEffect(.degrees(sc * 540 + Double(i) * 60))
                                    .opacity(min(1, (1 - sc) * 1.4))
                                    .stage(x: dx + 170 + cos(a) * 470 * sc - 12,
                                           y: 300 + sin(a) * 320 * sc - 12, w: 24, h: 24)
                            }
                        }
                        if tl > 20.1 {
                            TwinkleStar(t: t, duration: 1.4).stage(x: 200, y: 180, w: 24, h: 24)
                            TwinkleStar(t: t, duration: 1.7, delay: 0.4).stage(x: 540, y: 140, w: 20, h: 20)
                            TwinkleStar(t: t, duration: 1.5, delay: 0.8).stage(x: 380, y: 340, w: 22, h: 22)
                        }

                        // Foreground pillars sweep past during the swim only
                        ForEach(0..<6, id: \.self) { i in
                            ArtImage(i % 2 == 0 ? "props/pillar-a.png" : "props/pillar-b.png")
                                .stage(x: CGFloat(i) * 560 + 60 - cam * 1.45,
                                       y: 0, w: i % 2 == 0 ? 234 : 168, h: 600)
                        }
                        // Drifting motes, closest of all - floating upward
                        if tl < 12.5 {
                            ForEach(0..<7, id: \.self) { i in
                                let rise = (t * 34 + Double(i) * 131).truncatingRemainder(dividingBy: 560)
                                ArtImage("props/bubble.png")
                                    .opacity(0.5)
                                    .stage(x: CGFloat(i) * 560 - cam * 1.8 + 110 + sin(t * 1.6 + Double(i)) * 10,
                                           y: 620 - rise,
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
                    // The camera itself flinches with the sneeze
                    .scaleEffect(1 + 0.07 * sin(.pi * beat(tl, 20.05, 20.5)))
                    .offset(x: tl > 20.05 && tl < 20.8 ? sin(t * 56) * 9 * s * (1 - beat(tl, 20.05, 20.8)) : 0,
                            y: bob * s)
                    .opacity(1 - beat(tl, 21.3, 21.9))
                    .transition(.opacity)
                }

                // ---- The journey: the camera chases the treasures across
                // the ocean, zone by zone, watching each one splash down
                if tl >= 21.4 && tl < 30.4 {
                    let camJ = smooth(beat(tl, 21.7, 29.8)) * 1600
                    Group {
                        // A different part of the ocean: a bright open reef
                        Group {
                            ArtImage("scenes/journey/strip-a.jpg")
                                .stage(x: 0 - camJ - 1, y: 0, w: 802, h: 600)
                            ArtImage("scenes/journey/strip-b.jpg")
                                .stage(x: 800 - camJ - 1, y: 0, w: 802, h: 600)
                            ArtImage("scenes/journey/strip-c.jpg")
                                .stage(x: 1600 - camJ - 1, y: 0, w: 802, h: 600)
                        }

                        // Each hero treasure splashes down in its own water
                        let lampFall = smooth(beat(tl, 21.9, 24.2))
                        ArtImage("scenes/grotto/starfish-lamp.png")
                            .rotationEffect(.degrees(lampFall * 340))
                            .opacity(lampFall < 1 ? 1 : 0.75)
                            .stage(x: 430 - camJ - lampFall * 60, y: -90 + lampFall * 520, w: 78, h: 75)
                        if lampFall > 0.9 {
                            TwinkleStar(t: t, duration: 1.2).stage(x: 350 - camJ, y: 420, w: 26, h: 26)
                        }
                        let curtFall = smooth(beat(tl, 24.2, 26.6))
                        ArtImage("scenes/grotto/kelp-curtain.png")
                            .rotationEffect(.degrees(sin(curtFall * 3 * .pi) * 30))
                            .opacity(curtFall < 1 ? 1 : 0.75)
                            .stage(x: 1210 - camJ + curtFall * 40, y: -170 + curtFall * 560, w: 70, h: 164)
                        if curtFall > 0.9 {
                            TwinkleStar(t: t, duration: 1.2, delay: 0.3).stage(x: 1260 - camJ, y: 400, w: 24, h: 24)
                        }
                        let bedFall = smooth(beat(tl, 26.6, 29.2))
                        ArtImage("scenes/grotto/shell-bed.png")
                            .rotationEffect(.degrees(-bedFall * 200))
                            .opacity(bedFall < 1 ? 1 : 0.7)
                            .stage(x: 2010 - camJ - bedFall * 50, y: -120 + bedFall * 560, w: 120, h: 81)
                        if bedFall > 0.9 {
                            TwinkleStar(t: t, duration: 1.2, delay: 0.1).stage(x: 1990 - camJ, y: 430, w: 26, h: 26)
                        }
                        // And a drizzle of pearls raining down everywhere
                        ForEach(0..<9, id: \.self) { i in
                            let px = CGFloat(140 + i * 250)
                            let pf = smooth(beat(tl, 21.8 + Double(i) * 0.55, 24.2 + Double(i) * 0.55))
                            if pf > 0 && pf < 1 {
                                ArtImage("ui/pearl.png")
                                    .stage(x: px - camJ, y: -40 + pf * 560, w: 16, h: 16)
                            }
                        }

                        // Big coral fans sweep by in the foreground for depth
                        ForEach(0..<4, id: \.self) { i in
                            ArtImage(i % 2 == 0 ? "props/coral-fan-a.png" : "props/coral-fan-b.png")
                                .stage(x: CGFloat(i) * 740 + 240 - camJ * 1.4,
                                       y: i % 2 == 0 ? 180 : 260,
                                       w: i % 2 == 0 ? 430 : 536,
                                       h: i % 2 == 0 ? 576 : 514)
                        }
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()
                    }
                    .offset(y: Wave.alternate(t, from: -5, to: 5, duration: 3.6) * s)
                    .opacity(min(beat(tl, 21.4, 22.0), 1 - beat(tl, 29.8, 30.4)))
                }

                // ---- The quiet: back home, bare shelves, one lone pearl
                if tl >= 29.9 && tl < 33.4 {
                    Group {
                        ArtImage("scenes/intro/home-bg.jpg")
                            .stage(x: -1, y: 0, w: 802, h: 600)
                        ArtImage("scenes/intro/home-wall.png")
                            .stage(x: -1, y: 0, w: 802, h: 600)
                        Rectangle()
                            .fill(Tokens.Palette.midnight)
                            .opacity(0.32)
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()
                        let roll = easeOut(beat(tl, 30.4, 32.6))
                        ArtImage("ui/pearl.png")
                            .rotationEffect(.degrees(roll * 720))
                            .stage(x: 140 + roll * 420, y: 568, w: 22, h: 22)
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()
                    }
                    .opacity(beat(tl, 29.9, 30.5))
                }

                // ---- The crab rallies; the whale peeks in, sheepish
                if tl >= 33.4 {
                    Group {
                        ArtImage("scenes/home/bg.jpg")
                            .stage(x: 0, y: 0, w: 800, h: 600)
                        ArtImage("scenes/home/foreground.png")
                            .stage(x: 0, y: 440, w: 800, h: 160)
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                    }
                    .bleed()
                    let pop = easeOut(beat(tl, 33.4, 34.1))
                    CrabView(t: t, scale: s)
                        .stage(x: 275, y: 620 - pop * 310, w: 250, h: 211)
                    let peek = easeOut(beat(tl, 34.9, 36.0))
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
                                        (3, 22.4, PromptScript.intro3),
                                        (4, 33.6, PromptScript.intro4)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    speak(prompt)
                }
                for (i, at, effect) in [(10, 0.2, SoundPlayer.Effect.musicbox),
                                        (11, 17.8, SoundPlayer.Effect.rumble)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    play(effect)
                }
                if tl >= 38.8 && !finished {
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

/// Clips to the inside of the room: everything left of the window, plus the
/// window opening itself (an ellipse matching the painted hole), so the
/// whale's front half renders through the hole with the cut hidden along the
/// rim instead of a straight line across its body.
struct InsideRoom: Shape {
    /// The entrance segment's x offset and the stage scale, in points.
    var dx: CGFloat
    var scale: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addRect(CGRect(x: rect.minX - 400, y: rect.minY - 200,
                         width: (dx + 452) * scale + 400, height: rect.height + 400))
        // The painted hole spans roughly (452..796, 102..486) in design space
        p.addEllipse(in: CGRect(x: (dx + 448) * scale, y: 98 * scale,
                                width: 352 * scale, height: 392 * scale))
        return p
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
