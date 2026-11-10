import SwiftUI

/// Ten pearl slots on a quiet Midnight pill. Filled slots show the painted
/// pearl; empty ones a 2px Pearl ring at 60%.
struct PearlCounter: View {
    let filled: Int
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 6 * scale) {
            ForEach(0..<10, id: \.self) { i in
                if i < filled {
                    ArtImage("ui/pearl.png")
                        .frame(width: 22 * scale, height: 22 * scale)
                } else {
                    Circle()
                        .strokeBorder(Tokens.Palette.emptyPearlRing, lineWidth: 2 * scale)
                        .frame(width: 22 * scale, height: 22 * scale)
                }
            }
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 11 * scale)
        .background(Capsule().fill(Tokens.Palette.counterPanel))
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * scale, y: 6 * scale)
    }
}
