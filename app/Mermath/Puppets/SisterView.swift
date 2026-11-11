import SwiftUI

/// Everything that differs between the three sister puppets: art folder plus
/// the per-instance durations and CSS phase offsets from the reference page.
struct SisterSpec {
    let folder: String
    let hairFrom: Double
    let hairTo: Double
    let hairDuration: Double
    let hasPigtails: Bool
    let tailDuration: Double
    let tailDelay: Double
    let flukeDuration: Double
    let flukeDelay: Double
    let armDuration: Double
    let armDelay: Double
    let blinkCycle: Double
    let blinkDelay: Double
    let floatDuration: Double
    let floatDelay: Double

    static let ophelia = SisterSpec(
        folder: "ophelia",
        hairFrom: -1.6, hairTo: 1.8, hairDuration: 3, hasPigtails: false,
        tailDuration: 2.4, tailDelay: 0,
        flukeDuration: 1.2, flukeDelay: 0,
        armDuration: 1.6, armDelay: 0,
        blinkCycle: 4.4, blinkDelay: 0,
        floatDuration: 3.6, floatDelay: 0
    )

    static let daphne = SisterSpec(
        folder: "daphne",
        hairFrom: -1, hairTo: 1, hairDuration: 2.6, hasPigtails: true,
        tailDuration: 2.8, tailDelay: -0.8,
        flukeDuration: 1.4, flukeDelay: -0.4,
        armDuration: 1.9, armDelay: -0.5,
        blinkCycle: 5.3, blinkDelay: -2,
        floatDuration: 4.2, floatDelay: -1.2
    )

    static let violet = SisterSpec(
        folder: "violet",
        hairFrom: -1, hairTo: 1, hairDuration: 2.6, hasPigtails: false,
        tailDuration: 2.2, tailDelay: -0.3,
        flukeDuration: 1.1, flukeDelay: -0.7,
        armDuration: 1.5, armDelay: -1,
        blinkCycle: 3.9, blinkDelay: -1,
        floatDuration: 3.3, floatDelay: -0.6
    )
}

/// A sister puppet: full-frame layer stack (242x278 frame), bobbing as a whole.
/// Pivots are shared across sisters; ranges come from the reference keyframes.
struct SisterView: View {
    let spec: SisterSpec
    let t: Double
    /// Stage scale, for the float offset.
    let scale: CGFloat
    /// The treasure chest page waves faster (1.1s); nil keeps the spec's pace.
    var armDuration: Double?
    /// The intro's sisters sleep by the shell bed until the sneeze.
    var asleep = false

    private func art(_ piece: String) -> ArtImage {
        ArtImage("characters/\(spec.folder)/\(piece).png")
    }

    var body: some View {
        ZStack {
            art("hair")
                .rotationEffect(
                    .degrees(Wave.alternate(t, from: spec.hairFrom, to: spec.hairTo, duration: spec.hairDuration)),
                    anchor: UnitPoint(x: 0.485, y: 0.359)
                )
            if spec.hasPigtails {
                art("pigtail-left")
                    .rotationEffect(
                        .degrees(Wave.alternate(t, from: 5, to: -6, duration: 2.1)),
                        anchor: UnitPoint(x: 0.343, y: 0.286)
                    )
                art("pigtail-right")
                    .rotationEffect(
                        .degrees(Wave.alternate(t, from: 6, to: -5, duration: 2.3, delay: -0.9)),
                        anchor: UnitPoint(x: 0.628, y: 0.286)
                    )
            }
            ZStack {
                art("fluke")
                    .rotationEffect(
                        .degrees(Wave.alternate(t, from: -10, to: 9, duration: spec.flukeDuration, delay: spec.flukeDelay)),
                        anchor: UnitPoint(x: 0.725, y: 0.846)
                    )
                art("tail")
            }
            .rotationEffect(
                .degrees(Wave.alternate(t, from: -2.5, to: 2.5, duration: spec.tailDuration, delay: spec.tailDelay)),
                anchor: UnitPoint(x: 0.485, y: 0.615)
            )
            art("arm")
                .rotationEffect(
                    .degrees(Wave.alternate(t, from: -7, to: 11, duration: armDuration ?? spec.armDuration, delay: spec.armDelay)),
                    anchor: UnitPoint(x: 0.421, y: 0.518)
                )
            art("body")
            art("eyes-open")
                .opacity(asleep ? 0 : 1 - Wave.blink(t, cycle: spec.blinkCycle, delay: spec.blinkDelay))
            art("eyes-shut")
                .opacity(asleep ? 1 : Wave.blink(t, cycle: spec.blinkCycle, delay: spec.blinkDelay))
        }
        .offset(y: Wave.bob(t, from: 0, to: -7, duration: spec.floatDuration, delay: spec.floatDelay) * scale)
    }
}
