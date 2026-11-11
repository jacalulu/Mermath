import SwiftUI

/// Ten painted shell cups on a kelp strand; each earned pearl settles into
/// its cup. All paint, no panel - the strand floats over the scene.
struct PearlCounter: View {
    let filled: Int
    let scale: CGFloat

    /// Design-space size of the painted strand (asset crop 328x40).
    private static let w: CGFloat = 280
    private static let h: CGFloat = 280 * 40 / 328

    var body: some View {
        ZStack(alignment: .topLeading) {
            ArtImage("ui/pearl-strand.png")
                .frame(width: Self.w * scale, height: Self.h * scale)
            // Cup centers in the painted strand: scene x 228 + 31.5i, y 286;
            // crop origin (206, 266) -> relative (22 + 31.5i, 20) of 328x40.
            ForEach(0..<min(filled, 10), id: \.self) { i in
                ArtImage("ui/pearl.png")
                    .frame(width: 24 * scale, height: 24 * scale)
                    .position(x: Self.w * (22 + 31.5 * CGFloat(i)) / 328 * scale,
                              y: Self.h * 18 / 40 * scale)
            }
        }
        .frame(width: Self.w * scale, height: Self.h * scale)
        .shadow(color: Tokens.Palette.midnight.opacity(0.4), radius: 5 * scale, y: 4 * scale)
    }
}
