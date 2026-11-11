import SwiftUI

/// The big friendly call to action at the end of a dive: one orange capsule,
/// gently swelling, no panel behind it - the crab says the celebration line
/// out loud instead of a bar of text.
struct OpenChestButton: View {
    let title: String
    let t: Double
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(baloo(30, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.midnight)
                .padding(.top, 14 * scale)
                .padding(.bottom, 10 * scale)
                .padding(.horizontal, 42 * scale)
                .background(
                    Capsule().fill(Color(hex: 0xFF9A3D))
                )
                .overlay(
                    Capsule().strokeBorder(Color.white.opacity(0.55), lineWidth: 3 * scale)
                )
                .shadow(color: Color(hex: 0xFF9A3D, opacity: 0.55), radius: 16 * scale, y: 4 * scale)
                .shadow(color: Tokens.Palette.midnight.opacity(0.3), radius: 8 * scale, y: 6 * scale)
                .scaleEffect(Wave.alternate(t, from: 0.97, to: 1.05, duration: 1.1))
        }
        .buttonStyle(.plain)
    }
}
