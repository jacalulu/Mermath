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
                                .frame(width: 120 * s, height: 137 * s)
                                .stage(x: dx + 224 + rattle, y: 296, w: 120, h: 137)
                            SisterView(spec: .daphne, t: t, scale: s, asleep: tl < 18.3)
                                .frame(width: 104 * s, height: 119 * s)
                                .stage(x: dx + 116 + rattle, y: 386, w: 104, h: 119)
                            SisterView(spec: .violet, t: t, scale: s, asleep: tl < 18.2)
                                .frame(width: 104 * s, height: 119 * s)
                                .scaleEffect(x: -1)
                                .stage(x: dx + 354 + rattle, y: 376, w: 104, h: 119)
                        }
                        // Little sleep bubbles rising off each snoozing sister
                        if tl < 18.1 {
                            ForEach(0..<3, id: \.self) { i in
                                let bx: CGFloat = [300, 190, 416][i]
                                let by: CGFloat = [330, 410, 400][i]
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
                    // The crab pops onto his rock and hops as he talks
                    let pop = easeOut(beat(tl, 30.1, 30.8))
                    let hop = tl > 30.9 && tl < 50.6 ? abs(sin((tl - 30.9) * 2.6)) * 6.0 : 0.0
                    CrabView(t: t, scale: s)
                        .opacity(pop)
                        .stage(x: 15, y: 204 + (1 - pop) * 60 - hop, w: 250, h: 211)
                    // The culprit, peeking in sheepishly from the top corner
                    let peek = easeOut(beat(tl, 31.6, 32.7))
                    if peek > 0 {
                        WhaleIntroView(scale: s, uhoh: false, breathe: 0)
                            .rotationEffect(.degrees(14))
                            .scaleEffect(0.62)
                            .stage(x: 350 + (1 - peek) * 320, y: -150, w: 568, h: 240)
                    }
                    // The chest, grounded on the sand with its own shadow
                    if tl > 38.2 {
                        let c = easeOut(beat(tl, 38.2, 38.8))
                        Ellipse()
                            .fill(Tokens.Palette.midnight.opacity(0.3 * c))
                            .stage(x: 592, y: 528, w: 170, h: 26)
                        ArtImage("scenes/treasure-chest/chest-box.png")
                            .scaleEffect(0.6 + c * 0.4, anchor: .bottom)
                            .opacity(c)
                            .stage(x: 600, y: 440, w: 150, h: 97)
                        TwinkleStar(t: t, duration: 1.6).stage(x: 592, y: 430, w: 24, h: 24)
                        TwinkleStar(t: t, duration: 2.0, delay: 0.7).stage(x: 748, y: 480, w: 20, h: 20)
                    }
                    // Ten pearls arc from the crab's claw down into the chest
                    ForEach(0..<10, id: \.self) { i in
                        let at = 34.6 + Double(i) * 0.36
                        if tl > at {
                            let a = easeOut(beat(tl, at, at + 0.3))
                            let f = Double(i) / 9
                            ArtImage("ui/pearl.png")
                                .shadow(color: Tokens.Palette.pearl.opacity(0.8), radius: 5 * s)
                                .scaleEffect(0.5 + a * 0.5)
                                .opacity(a)
                                .stage(x: 215 + CGFloat(f) * 445,
                                       y: 290 - sin(.pi * f) * 130 + CGFloat(f) * 160, w: 26, h: 26)
                        }
                    }
                    // The map unfurls up out of the chest when he names it
                    if tl > 40.2 {
                        let mp = easeOut(beat(tl, 40.2, 40.8))
                        ArtImage("ui/icon-map.png")
                            .scaleEffect(0.4 + mp * 0.6, anchor: .bottom)
                            .opacity(mp)
                            .offset(y: Wave.bob(t, from: 0, to: -6, duration: 2.6) * s)
                            .stage(x: 630, y: 340 + (1 - mp) * 70, w: 92, h: 92)
                    }
                    // The sisters swim in one by one and drift while they listen
                    let sistersIn: [(SisterSpec, CGFloat, CGFloat, CGFloat, Double, Double)] = [
                        (.ophelia, 330, 220, 172, 30.6, 0),
                        (.daphne, 470, 330, 152, 31.2, -2.1),
                        (.violet, 282, 360, 152, 31.8, -4.3),
                    ]
                    ForEach(0..<3, id: \.self) { i in
                        let (spec, px, py, w, at, ph) = sistersIn[i]
                        let arrive = easeOut(beat(tl, at, at + 1.1))
                        SisterView(spec: spec, t: t, scale: s)
                            .frame(width: w * s, height: w * 1.147 * s)
                            .scaleEffect(x: i == 2 ? -1 : 1)
                            .opacity(arrive)
                            .stage(x: px + (1 - arrive) * -240 + Wave.alternate(t, from: -14, to: 14, duration: 5.2, delay: ph),
                                   y: py + Wave.alternate(t, from: -8, to: 8, duration: 4.1, delay: ph * 1.7),
                                   w: w, h: w * 1.147)
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
                                        (2, 12.9, PromptScript.intro2),
                                        (3, 22.4, PromptScript.intro3),
                                        (4, 30.4, PromptScript.rally1),
                                        (5, 33.9, PromptScript.rally2),
                                        (6, 45.3, PromptScript.rallyAsk),
                                        (7, 48.6, PromptScript.rally3)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    speak(prompt)
                }
                for (i, at, effect) in [(10, 0.05, SoundPlayer.Effect.introMusic),
                                        (11, 17.8, SoundPlayer.Effect.rumble)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    play(effect)
                }
                if tl >= 51.6 && !finished {
                    finished = true
                    onDone(true)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !finished else { return }
            finished = true
            onDone(spoken.contains(7))
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
