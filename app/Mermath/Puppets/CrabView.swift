import SwiftUI

/// The Tide Pool guide. Frame 250x211 (sources 500x422), all parts full-frame.
/// Legs stay planted; everything else bobs together. Blinks on a 4.4s cycle.
struct CrabView: View {
    let t: Double
    /// Stage scale, for the bob offset.
    let scale: CGFloat

    var body: some View {
        ZStack {
            ArtImage("characters/crab/legs.png")
            ZStack {
                ArtImage("characters/crab/arm-left.png")
                    .rotationEffect(
                        .degrees(Wave.alternate(t, from: 4, to: -5, duration: 2.6)),
                        anchor: UnitPoint(x: 0.316, y: 0.611)
                    )
                ArtImage("characters/crab/arm-right.png")
                    .rotationEffect(
                        .degrees(Wave.alternate(t, from: -9, to: 10, duration: 1.5)),
                        anchor: UnitPoint(x: 0.684, y: 0.611)
                    )
                ArtImage("characters/crab/body.png")
                ArtImage("characters/crab/eyes-open.png")
                    .opacity(1 - Wave.blink(t, cycle: 4.4))
                ArtImage("characters/crab/eyes-shut.png")
                    .opacity(Wave.blink(t, cycle: 4.4))
            }
            .offset(y: Wave.bob(t, from: 0, to: -5, duration: 3.2) * scale)
        }
    }
}
