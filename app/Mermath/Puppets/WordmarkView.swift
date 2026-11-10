import SwiftUI

/// The animated wordmark: letters, the breathing orange plus, and the mermaid
/// tail that sways with its fin. Full-frame layers in a 304x102 frame.
/// `onNavy: false` swaps in the pearl letters/tail for Midnight backgrounds.
struct WordmarkView: View {
    let t: Double
    var onPainted = true

    private var letters: String { onPainted ? "letters-navy" : "letters-pearl" }
    private var tailBody: String { onPainted ? "tail-body-navy" : "tail-body-pearl" }

    var body: some View {
        ZStack {
            ArtImage("brand/layers/\(letters).png")
            ArtImage("brand/layers/plus.png")
                .scaleEffect(
                    Wave.bob(t, from: 1, to: 1.08, duration: 2.4),
                    anchor: UnitPoint(x: 0.799, y: 0.8)
                )
            ZStack {
                ArtImage("brand/layers/tail-fin.png")
                    .rotationEffect(
                        .degrees(Wave.alternate(t, from: -8, to: 5, duration: 1.3)),
                        anchor: UnitPoint(x: 0.94, y: 0.277)
                    )
                ArtImage("brand/layers/\(tailBody).png")
            }
            .rotationEffect(
                .degrees(Wave.alternate(t, from: -1.6, to: 2, duration: 2.6)),
                anchor: UnitPoint(x: 0.897, y: 0.644)
            )
        }
        .shadow(color: Color.white.opacity(onPainted ? 0.55 : 0), radius: 6)
    }
}
