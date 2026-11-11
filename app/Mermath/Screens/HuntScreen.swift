import SwiftUI

/// X MARKS THE SPOT. The map led here: three sandy mounds on the seabed, and
/// one of them wears the X. Dig it open - four taps, each with a burst of
/// sand - and the ONE treasure the whale sneezed away rises sparkling, ready
/// to be carried home. Tapping a plain mound just puffs and the crab
/// redirects; never a penalty. Pure reward play.
struct HuntScreen: View {
    let earned: GrottoItem?
    var onDone: () -> Void = {}
    var speak: (Prompt) -> Void = { _ in }
    var play: (SoundPlayer.Effect) -> Void = { _ in }

    @Environment(\.stage) private var m

    private struct Puff: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let at: Double
    }

    /// Mound centers (x, base y, width) on the open sand.
    private static let mounds: [(x: CGFloat, y: CGFloat, w: CGFloat)] = [
        (152, 474, 198), (408, 500, 230), (654, 466, 194),
    ]
    private static let digsNeeded = 4

    @State private var xMound = Int.random(in: 0..<3)
    @State private var digs = 0
    @State private var revealed = false
    @State private var puffs: [Puff] = []
    @State private var puffId = 0
    @State private var saidIntro = false
    @State private var lastNope = -10.0

    var body: some View {
        let s = m.scale
        MotionClock { t in
            ZStack {
                // The treasure garden
                Group {
                    ArtImage("scenes/hunt/bg.jpg")
                        .stage(x: 0, y: 0, w: 800, h: 600)
                    LightShimmer(t: t)
                        .stage(x: 0, y: 0, w: 800, h: 340)
                    ArtImage("scenes/hunt/foreground.png")
                        .stage(x: 0, y: 266, w: 800, h: 334)
                    KelpLayer(t: t, path: "scenes/hunt/seagrass.png",
                              from: -7, to: 7, duration: 2.8, pivot: UnitPoint(x: 0.5, y: 1))
                        .stage(x: 128, y: 528, w: 598, h: 72)
                }
                .bleed()

                // The three mounds; the treasure hides behind the X one and
                // peeks out a little more with every dig
                ForEach(0..<3, id: \.self) { i in
                    let mound = Self.mounds[i]
                    let mh = mound.w * 114 / 224
                    let isX = i == xMound
                    let dug = isX ? CGFloat(min(digs, Self.digsNeeded)) / CGFloat(Self.digsNeeded) : 0

                    if isX, let earned, digs > 0, !revealed {
                        let a = earned.spriteAspect
                        let rw: CGFloat = a > 1.4 ? 64 : 92
                        ArtImage(earned.sprite)
                            .stage(x: mound.x - rw / 2,
                                   y: mound.y - mh * 0.4 - rw * a * dug * 0.55,
                                   w: rw, h: rw * a)
                    }
                    if !(isX && revealed) {
                        Button {
                            dig(i, at: t)
                        } label: {
                            ZStack {
                                ArtImage("props/dig-mound.png")
                                if isX {
                                    ArtImage("props/dig-x.png")
                                        .frame(width: mound.w * 0.4 * s, height: mound.w * 0.4 * 78 / 94 * s)
                                        .opacity(1 - Double(dug) * 0.85)
                                        .offset(y: -mh * 0.12 * s)
                                }
                            }
                            .frame(width: mound.w * s, height: mh * s)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle().inset(by: -10 * s))
                        .scaleEffect(y: 1 - dug * 0.5, anchor: .bottom)
                        .scaleEffect(x: 1 + dug * 0.12, anchor: .bottom)
                        .stage(x: mound.x - mound.w / 2, y: mound.y - mh, w: mound.w, h: mh)
                    }
                }

                // Sand puffs where small hands dig
                ForEach(puffs) { puff in
                    let age = t - puff.at
                    if age >= 0 && age < 0.55 {
                        let p = age / 0.55
                        Ellipse()
                            .fill(Color(red: 0.93, green: 0.85, blue: 0.65).opacity(0.8 * (1 - p)))
                            .stage(x: puff.x - 28 - 34 * p, y: puff.y - 10 - 26 * p,
                                   w: 56 + 68 * p, h: 22 + 20 * p)
                            .allowsHitTesting(false)
                    }
                }

                Vignette()
                    .stage(x: 0, y: 0, w: 800, h: 600)
                    .bleed()

                // Painted title lockup (art-pipeline/lettering.py), drifting
                // gently like the map's place names
                ArtImage("ui/names/hunt.png")
                    .frame(width: 380 * s, height: 380 * 420 / 1600 * s)
                    .offset(y: Wave.alternate(t, from: -2.2, to: 2.2, duration: 3.6) * s)
                    .allowsHitTesting(false)
                    .stageTopCenter(y: 2)

                // Dug free: the lost treasure rises sparkling over its hole
                if revealed, let earned {
                    let mound = Self.mounds[xMound]
                    let a = earned.spriteAspect
                    let rw: CGFloat = a > 1.4 ? 96 : 136
                    GlowPulse(t: t, color: Color(hex: 0xFFE9A8), fromOpacity: 0.45, toOpacity: 1, duration: 1.8)
                        .stage(x: mound.x - 110, y: mound.y - 320, w: 220, h: 220)
                    ArtImage(earned.sprite)
                        .shadow(color: Color(hex: 0xFFD27A, opacity: 0.8), radius: 20 * s)
                        .offset(y: Wave.bob(t, from: 0, to: -8, duration: 3) * s)
                        .stage(x: mound.x - rw / 2, y: mound.y - 210 - rw * a / 2, w: rw, h: rw * a)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                    TwinkleStar(t: t, duration: 2.2).stage(x: mound.x - 100, y: mound.y - 290, w: 22, h: 22)
                    TwinkleStar(t: t, duration: 2.6, delay: 0.7).stage(x: mound.x + 80, y: mound.y - 250, w: 18, h: 18)
                    TwinkleStar(t: t, duration: 2, delay: 1.2).stage(x: mound.x + 20, y: mound.y - 330, w: 20, h: 20)
                }
            }
            .onChange(of: Int(t * 10)) {
                if !saidIntro && t > 0.5 {
                    saidIntro = true
                    speak(PromptScript.digIntro)
                }
            }
        }
    }

    private func dig(_ i: Int, at t: Double) {
        let mound = Self.mounds[i]
        puffId += 1
        puffs.append(Puff(id: puffId, x: mound.x, y: mound.y - mound.w * 114 / 224 / 2, at: t))
        if i == xMound {
            play(.pop)
            withMotion(.easeOut(duration: 0.25)) { digs += 1 }
            if digs >= Self.digsNeeded && !revealed {
                withMotion(.easeOut(duration: 0.4)) { revealed = true }
                play(.fanfare)
                speak(PromptScript.digFound)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                    onDone()
                }
            }
        } else if t - lastNope > 2.5 {
            lastNope = t
            speak(PromptScript.digNotHere)
        }
    }
}
