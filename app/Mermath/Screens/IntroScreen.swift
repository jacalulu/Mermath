import SwiftUI

/// The opening story, told in four beats over ~23 seconds (tap to skip):
/// the cozy grotto full of treasures - a great big whale swims by and
/// SNEEZES - the treasures scatter across the sea - the crab calls for help.
/// Every dive after this is a rescue.
struct IntroScreen: View {
    let speak: (Prompt) -> Void
    /// Called when the intro ends; `true` when the crab already asked
    /// "Who is diving today?" so the pick screen should not ask again.
    let onDone: (Bool) -> Void

    @Environment(\.stage) private var m
    @State private var spoken: Set<Int> = []
    /// Clock time at first frame, so the story also plays on replays.
    @State private var start: Double?
    @State private var finished = false

    private func beat(_ t: Double, _ from: Double, _ to: Double) -> Double {
        min(1, max(0, (t - from) / (to - from)))
    }

    var body: some View {
        let s = m.scale
        MotionClock { t in
            let tl = t - (start ?? t)
            ZStack {
                // ---- Beat 1 and 2: the grotto, then the whale and the sneeze
                if tl < 13.5 {
                    let sneeze = beat(tl, 12.0, 12.15)       // the lunge
                    let scatter = beat(tl, 12.1, 13.4)       // treasures fly out
                    Group {
                        Group {
                            ArtImage("scenes/grotto/bg.jpg")
                                .stage(x: 0, y: 0, w: 800, h: 600)
                            ArtImage("scenes/grotto/floor.png")
                                .stage(x: 0, y: 466, w: 800, h: 134)
                            ArtImage("scenes/grotto/walls.png")
                                .stage(x: 0, y: 0, w: 800, h: 600)
                            ArtImage("scenes/grotto/string-lights.png")
                                .opacity(Wave.alternate(t, from: 0.72, to: 1, duration: 1.7))
                                .stage(x: 142, y: 52, w: 516, h: 100)
                        }
                        .bleed()

                        // The three treasures, snug at home until the sneeze
                        ArtImage("scenes/grotto/kelp-curtain.png")
                            .rotationEffect(.degrees(scatter * 160))
                            .stage(x: 570 + scatter * 420, y: 54 + scatter * 120, w: 166, h: 390)
                        ArtImage("scenes/grotto/starfish-lamp.png")
                            .rotationEffect(.degrees(-scatter * 240))
                            .stage(x: 348 - scatter * 640, y: 124 - scatter * 420, w: 104, h: 100)
                        ArtImage("scenes/grotto/shell-bed.png")
                            .rotationEffect(.degrees(-scatter * 120))
                            .stage(x: 394 - scatter * 780, y: 378 + scatter * 420, w: 252, h: 170)

                        // The whale: swims in, winds up, sneezes
                        let enter = beat(tl, 6.5, 10.0)
                        let windup = tl > 10.2 && tl < 12.0
                            ? 1 + 0.05 * sin((tl - 10.2) * 3.5 * .pi) * beat(tl, 10.2, 11.6)
                            : 1.0
                        if tl > 6.5 {
                            WhaleView(scale: s)
                                .scaleEffect(windup + sneeze * 0.08)
                                .rotationEffect(.degrees(-6 * sneeze + 3 * beat(tl, 12.15, 12.6)))
                                .stage(x: -620 + enter * 560 + sneeze * 110, y: 110 + Wave.alternate(t, from: -8, to: 8, duration: 3.1), w: 568, h: 240)
                                .transition(.opacity)
                        }
                        // The sneeze itself: a white flash and a burst of bubbles
                        if tl > 12.0 && tl < 13.2 {
                            let burst = beat(tl, 12.0, 13.2)
                            Color.white
                                .opacity(0.65 * (1 - burst))
                                .stage(x: 0, y: 0, w: 800, h: 600)
                                .bleed()
                            ForEach(0..<9, id: \.self) { i in
                                let a = Double(i) / 9 * 2 * .pi
                                ArtImage("props/bubble.png")
                                    .opacity(1 - burst)
                                    .stage(x: 320 + cos(a) * 320 * burst, y: 250 + sin(a) * 240 * burst, w: 26, h: 26)
                            }
                        }
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                            .bleed()
                    }
                    // The whole room shudders with the sneeze
                    .offset(x: tl > 12.0 && tl < 12.7 ? sin(t * 56) * 7 * s * (1 - beat(tl, 12.0, 12.7)) : 0)
                    .transition(.opacity)
                }

                // ---- Beat 3: the treasures scatter across the map
                if tl >= 13.5 && tl < 19 {
                    let fall = beat(tl, 13.7, 17.5)
                    Group {
                        ArtImage("scenes/reef-map/bg.jpg")
                            .stage(x: 0, y: 0, w: 800, h: 600)
                        ArtImage("scenes/reef-map/seabed.png")
                            .stage(x: 0, y: 206, w: 800, h: 394)
                    }
                    .bleed()
                    // Each treasure sinks toward the zone it will be won back from
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

                // ---- Beat 4: the crab calls for help
                if tl >= 19 {
                    Group {
                        ArtImage("scenes/home/bg.jpg")
                            .stage(x: 0, y: 0, w: 800, h: 600)
                        ArtImage("scenes/home/foreground.png")
                            .stage(x: 0, y: 440, w: 800, h: 160)
                        Vignette()
                            .stage(x: 0, y: 0, w: 800, h: 600)
                    }
                    .bleed()
                    let pop = beat(tl, 19.0, 19.6)
                    CrabView(t: t, scale: s)
                        .stage(x: 275, y: 620 - pop * 310 + (1 - pop) * 0, w: 250, h: 211)
                        .transition(.opacity)
                }

                // Skip hint, quietly in the corner
                Text("Tap to skip")
                    .font(baloo(15, weight: 600, scale: s))
                    .foregroundStyle(Tokens.Palette.pearl.opacity(0.65))
                    .stageTopRight(right: 28, y: 28)
            }
            .onChange(of: Int(t * 10)) {
                if start == nil { start = t }
                // Narration beats, each spoken once
                for (i, at, prompt) in [(1, 0.3, PromptScript.intro1),
                                        (2, 6.8, PromptScript.intro2),
                                        (3, 13.7, PromptScript.intro3),
                                        (4, 19.2, PromptScript.intro4)] where tl >= at && !spoken.contains(i) {
                    spoken.insert(i)
                    speak(prompt)
                }
                if tl >= 24.0 && !finished {
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

/// The great big whale (painted body, crisp face), composed from the manifest
/// crops: whale (144,210,568x240), face (170,278,130x86).
struct WhaleView: View {
    let scale: CGFloat
    /// The art faces left; the intro whale swims in from the left, so flip it.
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
