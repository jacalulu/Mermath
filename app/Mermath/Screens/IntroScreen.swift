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

                        // Fish drift past outside the window while all is calm
                        if tl < 17.8 {
                            FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 26, delay: -6, scale: s)
                                .stage(x: dx + 830, y: 240, w: 40, h: 25)
                            FishSwim(t: t, travel: 920, bobDown: 6, bobUp: 7, duration: 31, delay: -19, scale: s)
                                .stage(x: dx + 850, y: 330, w: 30, h: 19)
                        }

                        // The whale LEANS INTO the window - it never crosses
                        // the plane, so the painted rim does all the
                        // occlusion and no layer ever has to split. Its face
                        // grows to fill the opening like a giant peering
                        // into a dollhouse, and the sneeze recoil throws it
                        // back into the open water.
                        if tl > 12.5 && tl < 21.6 {
                            let approach = easeOut(beat(tl, 12.5, 15.2))
                            let lean = smooth(beat(tl, 15.2, 16.8))
                            let inflate = beat(tl, 17.8, 20.0)
                            let lunge = beat(tl, 20.05, 20.3)
                            let recoil = easeOut(beat(tl, 20.3, 21.5))
                            let scaleW = 0.55 + lean * 0.3 + inflate * 0.1 + lunge * 0.08 - recoil * 0.3
                            let wx = dx + 860 - approach * 160 - lean * 150 - lunge * 30 + recoil * 900
                            let wy = 172 + Wave.alternate(t, from: -6, to: 6, duration: 3.1)
                            WhaleIntroView(
                                scale: s,
                                uhoh: tl > 16.6 && tl < 20.6,
                                breathe: inflate > 0 ? sin(inflate * 3.4 * .pi) * 0.05 : 0,
                                facingRight: false
                            )
                            .scaleEffect(scaleW)
                            .rotationEffect(.degrees(recoil * 10))
                            .stage(x: wx, y: wy, w: 568, h: 240)
                        }
                        // The tickling frond at the window's lower rim,
                        // in front of the whale, behind the wall
                        if tl > 16.2 && tl < 20.1 {
                            KelpLayer(t: t, path: "scenes/tide-pool/seagrass.png",
                                      from: -16, to: 16, duration: 0.5, pivot: UnitPoint(x: 0.5, y: 1))
                                .stage(x: dx + 580, y: 428, w: 120, h: 56)
                        }

                        ArtImage("scenes/intro/home-wall.png")
                            .stage(x: dx - 1, y: 0, w: 802, h: 600)

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

                        // The sisters themselves, asleep around their shell
                        // bed until the rattling wakes them with a start
                        Group {
                            SisterView(spec: .ophelia, t: t, scale: s, asleep: tl < 18.1)
                                .frame(width: 259 * s, height: 297 * s)
                                .stage(x: dx + 155 + rattle, y: 183, w: 259, h: 297)
                            SisterView(spec: .daphne, t: t, scale: s, asleep: tl < 18.3)
                                .frame(width: 224 * s, height: 256 * s)
                                .stage(x: dx + 56 + rattle, y: 264, w: 224, h: 256)
                            SisterView(spec: .violet, t: t, scale: s, asleep: tl < 18.2)
                                .frame(width: 224 * s, height: 256 * s)
                                .scaleEffect(x: -1)
                                .stage(x: dx + 294 + rattle, y: 259, w: 224, h: 256)
                        }
                        // Little sleep bubbles rising off each snoozing sister
                        if tl < 18.1 {
                            ForEach(0..<3, id: \.self) { i in
                                let bx: CGFloat = [284, 170, 400][i]
                                let by: CGFloat = [235, 308, 300][i]
                                let rise = (t * 26 + Double(i) * 53).truncatingRemainder(dividingBy: 120)
                                ArtImage("props/bubble.png")
                                    .opacity(max(0, 0.8 - rise / 120))
                                    .stage(x: dx + bx + sin(t * 2 + Double(i)) * 5,
                                           y: by - rise, w: 11 + CGFloat(i) * 2, h: 11 + CGFloat(i) * 2)
                            }
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

                        // The treasures themselves rain down: the lamp, the
                        // goblet pile, the mirror stack, the bed, the coin
                        // spill - each splashing into a different spot.
                        let lampFall = smooth(beat(tl, 21.9, 24.2))
                        ArtImage("scenes/grotto/starfish-lamp.png")
                            .rotationEffect(.degrees(lampFall * 340))
                            .opacity(lampFall < 1 ? 1 : 0.75)
                            .stage(x: 430 - camJ - lampFall * 60, y: -90 + lampFall * 520, w: 78, h: 75)
                        if lampFall > 0.9 {
                            TwinkleStar(t: t, duration: 1.2).stage(x: 350 - camJ, y: 420, w: 26, h: 26)
                        }
                        let gobFall = smooth(beat(tl, 22.8, 25.1))
                        ArtImage("props/hoard-right.png")
                            .rotationEffect(.degrees(gobFall * 260))
                            .opacity(gobFall < 1 ? 1 : 0.75)
                            .stage(x: 700 - camJ + gobFall * 40, y: -140 + gobFall * 560, w: 99, h: 84)
                        if gobFall > 0.9 {
                            TwinkleStar(t: t, duration: 1.2, delay: 0.3).stage(x: 760 - camJ, y: 410, w: 24, h: 24)
                        }
                        let mirFall = smooth(beat(tl, 24.0, 26.4))
                        ArtImage("props/hoard-left.png")
                            .rotationEffect(.degrees(-mirFall * 300))
                            .opacity(mirFall < 1 ? 1 : 0.75)
                            .stage(x: 1120 - camJ - mirFall * 50, y: -110 + mirFall * 540, w: 102, h: 52)
                        if mirFall > 0.9 {
                            TwinkleStar(t: t, duration: 1.2, delay: 0.2).stage(x: 1080 - camJ, y: 420, w: 24, h: 24)
                        }
                        let bedFall = smooth(beat(tl, 25.4, 27.9))
                        ArtImage("scenes/grotto/shell-bed.png")
                            .rotationEffect(.degrees(-bedFall * 200))
                            .opacity(bedFall < 1 ? 1 : 0.7)
                            .stage(x: 1500 - camJ - bedFall * 50, y: -120 + bedFall * 560, w: 120, h: 81)
                        if bedFall > 0.9 {
                            TwinkleStar(t: t, duration: 1.2, delay: 0.1).stage(x: 1470 - camJ, y: 430, w: 26, h: 26)
                        }
                        let coinFall = smooth(beat(tl, 26.8, 29.2))
                        ArtImage("props/hoard-floor.png")
                            .rotationEffect(.degrees(coinFall * 220))
                            .opacity(coinFall < 1 ? 1 : 0.7)
                            .stage(x: 1980 - camJ + coinFall * 30, y: -90 + coinFall * 540, w: 130, h: 39)
                        if coinFall > 0.9 {
                            TwinkleStar(t: t, duration: 1.2, delay: 0.4).stage(x: 2030 - camJ, y: 420, w: 24, h: 24)
                        }
                        // And just a few pearls drifting down among them
                        ForEach(0..<5, id: \.self) { i in
                            let px = CGFloat(260 + i * 420)
                            let pf = smooth(beat(tl, 22.2 + Double(i) * 0.9, 25.0 + Double(i) * 0.9))
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

                // ---- The mission briefing, staged like a scene, not a
                // diagram: the crab on his own rock, the chest grounded on
                // the sand, the map unfurling from it, and the sisters -
                // big, drifting, arriving one by one - gathered between.
                if tl >= 30.0 {
                    Group {
                        ArtImage("scenes/tide-pool/bg.jpg")
                            .stage(x: 0, y: 0, w: 800, h: 600)
                        LightShimmer(t: t)
                            .stage(x: 0, y: 0, w: 800, h: 340)
                        ArtImage("scenes/tide-pool/foreground.png")
                            .stage(x: 0, y: 350, w: 800, h: 250)
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                    }
                    .bleed()
                    // The culprit, peeking down sheepishly in the top-left
                    let peek = easeOut(beat(tl, 31.6, 32.7))
                    if peek > 0 {
                        WhaleIntroView(scale: s, uhoh: false, breathe: 0)
                            .rotationEffect(.degrees(-12))
                            .scaleEffect(0.55)
                            .opacity(peek)
                            .stage(x: -60, y: -100 - (1 - peek) * 90, w: 568, h: 240)
                    }
                    // The pearls' flight happens BEHIND the sisters (so they
                    // never cross a face); they land in front, on the sand row
                    ForEach(0..<10, id: \.self) { i in
                        BriefingPearl(i: i, t: t, tl: tl, s: s, front: false)
                    }
                    // The sisters SWIM in one by one - off screen to their
                    // marks on a dipping curve, tails sweeping hard, leaning
                    // into the motion, then settling into a drift. No fades.
                    let sistersIn: [(SisterSpec, CGFloat, CGFloat, CGFloat, Double, Double)] = [
                        (.ophelia, 260, 190, 225, 30.4, 0),
                        (.daphne, 410, 310, 185, 31.3, -2.1),
                        (.violet, 240, 340, 180, 32.2, -4.3),
                    ]
                    ForEach(0..<3, id: \.self) { i in
                        let (spec, px, py, w, at, ph) = sistersIn[i]
                        let travel = easeOut(beat(tl, at, at + 2.2))
                        let swim = min(1, (1 - travel) * 3)
                        SisterView(spec: spec, t: t, scale: s, swim: swim)
                            .frame(width: w * s, height: w * 1.147 * s)
                            .scaleEffect(x: i == 2 ? -1 : 1)
                            .rotationEffect(.degrees((1 - travel) * 24 + swim * Wave.alternate(t, from: -4, to: 4, duration: 0.75, delay: ph)))
                            .stage(x: px + (1 - travel) * -(px + 420) + Wave.alternate(t, from: -10, to: 10, duration: 5.2, delay: ph),
                                   y: py - sin(travel * .pi) * 70 + (1 - travel) * 46
                                      + Wave.alternate(t, from: -7, to: 7, duration: 4.1, delay: ph * 1.7),
                                   w: w, h: w * 1.147)
                    }
                    // Once landed, the pearls (their piles and puffs) live on
                    // the foreground sand, and roll from there into the chest.
                    ForEach(0..<10, id: \.self) { i in
                        BriefingPearl(i: i, t: t, tl: tl, s: s, front: true)
                    }
                    // The crab, small in the lower-left foreground, hopping as
                    // he talks and angled up toward the sisters
                    let pop = easeOut(beat(tl, 30.1, 30.8))
                    let hop = tl > 30.9 && tl < 50.6 ? abs(sin((tl - 30.9) * 2.6)) * 4.0 : 0.0
                    CrabView(t: t, scale: s)
                        .rotationEffect(.degrees(-6))
                        .opacity(pop)
                        .stage(x: 62, y: 392 + (1 - pop) * 60 - hop, w: 172, h: 145)
                    // The chest, closed and grounded lower-right, its magic
                    // leaking out of the seam as a warm pulsing glow
                    if tl > 38.2 {
                        let c = easeOut(beat(tl, 38.2, 38.8))
                        // It pulses softly, then flares as the pearls pour in
                        let feed = beat(tl, 39.0, 40.5)
                        let pulse = min(1, 0.45 + 0.35 * Wave.alternate(t, from: 0, to: 1, duration: 1.8) + 0.5 * feed)
                        Ellipse()
                            .fill(Tokens.Palette.midnight.opacity(0.3 * c))
                            .stage(x: 592, y: 528, w: 170, h: 26)
                        Ellipse()
                            .fill(RadialGradient(colors: [Color(red: 1, green: 0.93, blue: 0.68).opacity(0.85 * pulse * c),
                                                          Color(red: 1, green: 0.85, blue: 0.5).opacity(0)],
                                                 center: .center, startRadius: 0, endRadius: 60 * s))
                            .stage(x: 615, y: 400, w: 120, h: 90)
                        // ...and pops with a bounce as the last pearl rolls in
                        let unlock = sin(.pi * beat(tl, BriefingPearl.allIn, BriefingPearl.allIn + 0.5))
                        ArtImage("scenes/treasure-chest/chest-box.png")
                            .scaleEffect(0.6 + c * 0.4 + 0.14 * unlock, anchor: .bottom)
                            .rotationEffect(.degrees(unlock * 3), anchor: .bottom)
                            .opacity(c)
                            .stage(x: 600, y: 440, w: 150, h: 97)
                        TwinkleStar(t: t, duration: 1.6).stage(x: 592, y: 430, w: 24, h: 24)
                        TwinkleStar(t: t, duration: 2.0, delay: 0.7).stage(x: 748, y: 480, w: 20, h: 20)
                    }
                    // A foreground coral fan anchors the lower-right corner
                    ArtImage("props/coral-fan-a.png")
                        .stage(x: 665, y: 475, w: 230, h: 180)
                        .opacity(0.95)
                    // The treasure map - the real, open parchment - bursts out
                    // of the chest when he names it and hangs big in the sky
                    if tl > 40.9 {
                        let mp = easeOut(beat(tl, 40.9, 41.7))
                        ArtImage("props/big-map.png")
                            .scaleEffect(0.18 + mp * 0.82)
                            .opacity(min(1, mp * 2))
                            .rotationEffect(.degrees((1 - mp) * -14 + Wave.alternate(t, from: -1.4, to: 1.4, duration: 3.4)))
                            .offset(y: Wave.bob(t, from: 0, to: -7, duration: 2.6) * s)
                            .stage(x: 448 + (1 - mp) * 180, y: 54 + (1 - mp) * 358, w: 330, h: 258)
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
                                        (2, 12.45, PromptScript.intro2),
                                        (3, 22.4, PromptScript.intro3),
                                        (4, 30.4, PromptScript.rally1),
                                        (5, 33.9, PromptScript.rally2),
                                        (6, 45.3, PromptScript.rallyAsk)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    speak(prompt)
                }
                var sounds: [(Int, Double, SoundPlayer.Effect)] = [(10, 0.05, .introMusic),
                                                                   (11, 17.8, .rumble),
                                                                   (12, BriefingPearl.allIn, .chime)]
                for i in 0..<10 { sounds.append((20 + i, BriefingPearl.landTime(i), .thud)) }
                for (i, at, effect) in sounds where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    play(effect)
                }
                // "So, who is diving today?" waits for the pick screen itself
                if tl >= 48.6 && !finished {
                    finished = true
                    onDone(true)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !finished else { return }
            finished = true
            onDone(spoken.contains(6))
        }
    }
}

/// One pearl of the briefing's chain. It pops out of the crab's claw, arcs
/// over and DROPS into the sand with a thud - squashing for a beat, kicking
/// up a puff, and leaving a little sand pile it sits in. When the crab names
/// the chest, the pearls roll along the sand line one after another into the
/// chest's lock (nearest first) and are swallowed - the chest is drawn over
/// them - which pops it open.
private struct BriefingPearl: View {
    /// A straight, evenly spaced row across the open sand at the bottom.
    static let slots: [(x: CGFloat, y: CGFloat)] = (0..<10).map {
        (210 + CGFloat($0) * 48, 545)
    }
    static let claw = (x: CGFloat(206), y: CGFloat(426))
    static let lock = (x: CGFloat(668), y: CGFloat(516))
    /// When pearl `i` hits the sand (the thud sounds are scheduled off this).
    static func landTime(_ i: Int) -> Double { 34.6 + Double(i) * 0.36 + 0.6 }
    /// All ten are inside the chest by here; the lid pops right after.
    static let allIn = 40.7
    /// The roll toward the chest: nearest pearl first, farther ones longer.
    static func rollStart(_ j: Int) -> Double { 39.0 + Double(9 - j) * 0.1 }
    static func rollDur(_ j: Int) -> Double { 0.4 + Double(9 - j) * 0.045 }
    /// When the pile at slot `i` is smeared flat: the moment the pearl behind
    /// rolls through it (the last pearl smears its own pile as it leaves).
    static func pileFlattens(_ i: Int) -> Double {
        i == 0 ? rollStart(0) + 0.2
               : rollStart(i - 1) + rollDur(i - 1) / Double(11 - i) + 0.05
    }

    let i: Int
    let t: Double
    let tl: Double
    let s: CGFloat
    /// false = the flight pass, drawn behind the sisters; true = the grounded
    /// pass (pile, puff, landed pearl, roll), drawn in front of them.
    let front: Bool

    private func clamp01(_ v: Double) -> Double { min(max(v, 0), 1) }

    /// Where the pearl is after rolling fraction `f` of the way from its own
    /// slot along the remaining sand line into the lock.
    private func rolled(_ f: Double) -> (x: CGFloat, y: CGFloat) {
        var pts = Self.slots[i...].map { $0 }
        pts.append(Self.lock)
        let seg = f * Double(pts.count - 1)
        let k = min(pts.count - 2, Int(seg))
        let u = CGFloat(seg - Double(k))
        return (pts[k].x + (pts[k + 1].x - pts[k].x) * u,
                pts[k].y + (pts[k + 1].y - pts[k].y) * u)
    }

    var body: some View {
        let slot = Self.slots[i]
        let land = Self.landTime(i)
        let f1 = clamp01((tl - (34.6 + Double(i) * 0.36)) / 0.6)
        // nearest pearl rolls first; farther ones roll longer
        let f2raw = clamp01((tl - Self.rollStart(i)) / Self.rollDur(i))
        let f2 = f2raw * f2raw * (3 - 2 * f2raw)
        if !front {
            // The flight pass: airborne only, behind the sisters
            if f1 > 0 && tl < land {
                ArtImage("ui/pearl.png")
                    .shadow(color: Tokens.Palette.pearl.opacity(0.8), radius: 5 * s)
                    .scaleEffect(0.45 + 0.55 * f1)
                    .stage(x: Self.claw.x + (slot.x - Self.claw.x) * (1 - pow(1 - f1, 2)),
                           y: Self.claw.y + (slot.y - Self.claw.y) * f1 * f1 - sin(.pi * f1) * 64,
                           w: 26, h: 26)
            }
        } else if tl >= land {
            // The grounded pass: the little sand pile the thud makes stays -
            // until a rolling pearl ploughs through it and smears it flat
            let flat = clamp01((tl - Self.pileFlattens(i)) / 0.4)
            if flat < 1 {
                Ellipse().fill(Color(red: 0.84, green: 0.73, blue: 0.52))
                    .opacity(1 - flat)
                    .stage(x: slot.x - 8 - 12 * flat, y: slot.y + 15 + 4 * flat,
                           w: 42 + 24 * flat, h: 12 * (1 - 0.65 * flat))
                Ellipse().fill(Color(red: 0.95, green: 0.88, blue: 0.70))
                    .opacity(1 - flat)
                    .stage(x: slot.x - 5 - 10 * flat, y: slot.y + 14 + 4 * flat,
                           w: 36 + 20 * flat, h: 9 * (1 - 0.65 * flat))
            }
            // the puff of sand kicked up at the thud
            let pt = clamp01((tl - land) / 0.45)
            if pt < 1 {
                Ellipse()
                    .fill(Color(red: 0.93, green: 0.85, blue: 0.65).opacity(0.75 * (1 - pt)))
                    .stage(x: slot.x - 10 - 26 * pt, y: slot.y + 8 - 10 * pt,
                           w: 46 + 52 * pt, h: 14 + 12 * pt)
            }
            if f2raw < 1 {
                // sitting in its pile (squashing for a beat), then rolling
                let pos = f2raw > 0 ? rolled(f2) : (x: slot.x, y: slot.y)
                let sq = f2raw == 0 ? max(0, 1 - (tl - land) / 0.18) : 0
                ArtImage("ui/pearl.png")
                    .shadow(color: Tokens.Palette.pearl.opacity(0.8), radius: 5 * s)
                    .scaleEffect(x: 1 + 0.22 * sq, y: 1 - 0.3 * sq)
                    .opacity(1 - max(0, (f2 - 0.82) / 0.18))
                    .stage(x: pos.x, y: pos.y, w: 26, h: 26)
            }
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
