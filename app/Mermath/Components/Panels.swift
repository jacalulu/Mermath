import SwiftUI

/// The gold "tap me" button: gradient capsule, Baloo 700.
struct GoldButton: View {
    let title: String
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(baloo(Tokens.Type.button, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.midnight)
                .padding(.top, 13 * scale)
                .padding(.bottom, 9 * scale)
                .padding(.horizontal, 24 * scale)
                .background(Capsule().fill(Tokens.Gradients.button))
        }
        .buttonStyle(.plain)
    }
}

/// "Count with me" plus one orange dot per unit of the target number.
struct HintPanel: View {
    let count: Int
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 14 * scale) {
            Text("Count with me")
                .font(baloo(Tokens.Type.panel, weight: 600, scale: scale))
                .foregroundStyle(Tokens.Palette.pearl)
                .padding(.top, 3 * scale)
            HStack(spacing: 8 * scale) {
                ForEach(0..<count, id: \.self) { _ in
                    Circle()
                        .fill(Tokens.Palette.goldfish)
                        .frame(width: 26 * scale, height: 26 * scale)
                }
            }
        }
        .padding(.vertical, 12 * scale)
        .padding(.horizontal, 26 * scale)
        .background(Capsule().fill(Tokens.Palette.panel))
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * scale, y: 6 * scale)
    }
}

/// The solved line plus the gold button to the chest.
struct SolvedPanel: View {
    let text: String
    let buttonTitle: String
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        HStack(spacing: 18 * scale) {
            Text(text)
                .font(baloo(Tokens.Type.solvedPanel, weight: 600, scale: scale))
                .foregroundStyle(Tokens.Palette.pearl)
                .padding(.top, 3 * scale)
            GoldButton(title: buttonTitle, scale: scale, action: action)
        }
        .padding(.top, 10 * scale)
        .padding(.bottom, 10 * scale)
        .padding(.leading, 28 * scale)
        .padding(.trailing, 10 * scale)
        .background(Capsule().fill(Tokens.Palette.panel))
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 7 * scale, y: 6 * scale)
    }
}

/// The painted rolled-map icon, back to the reef map.
struct MapButton: View {
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ArtImage("ui/icon-map.png")
                .frame(width: 66 * scale, height: 66 * scale)
                .shadow(color: Tokens.Palette.midnight.opacity(0.4), radius: 4 * scale, y: 5 * scale)
        }
        .buttonStyle(.plain)
    }
}
