import SwiftUI

/// The gold "tap me" button: gradient capsule, Baloo 700.
struct GoldButton: View {
    let title: String
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(baloo(Tokens.TypeScale.button, weight: 700, scale: scale))
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
                .font(baloo(Tokens.TypeScale.panel, weight: 600, scale: scale))
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
                .font(baloo(Tokens.TypeScale.solvedPanel, weight: 600, scale: scale))
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

/// The sea-glass material, the game's one language for floating UI: frosted
/// water with a wet cyan cast, a crescent of light hugging the top-left
/// curve, and a refraction rim. Locked UI gets dark glass.
struct SeaGlass: View {
    let scale: CGFloat
    var locked = false

    var body: some View {
        ZStack {
            Capsule().fill(.ultraThinMaterial)
            Capsule().fill(Color(hex: 0x99E5FF, opacity: locked ? 0.08 : 0.18))
            if locked {
                Capsule().fill(Color(hex: 0x0A2238, opacity: 0.45))
            }
            Capsule().strokeBorder(Color.white.opacity(0.9), lineWidth: 3 * scale)
                .mask(LinearGradient(colors: [.white, .clear],
                                     startPoint: .topLeading, endPoint: .center))
        }
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(
                LinearGradient(
                    colors: [.white.opacity(0.85), .white.opacity(locked ? 0.12 : 0.25)],
                    startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: 2 * scale)
        )
    }
}

/// A tiny bubble of the same glass, attached to a pill's silhouette.
struct SeaGlassDot: View {
    let d: CGFloat
    let scale: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(.ultraThinMaterial)
            Circle().fill(Color(hex: 0x99E5FF, opacity: 0.18))
        }
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.7), lineWidth: 1.5 * scale))
        .frame(width: d * scale, height: d * scale)
    }
}

/// The corner home button in the sea-glass material, the house glyph in the
/// same deep-sea ink as the labels.
struct HomeButton: View {
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "house.fill")
                .font(.system(size: 29 * scale, weight: .bold))
                .foregroundStyle(Color(hex: 0x1A3B5C))
                .offset(y: -1 * scale)
                .frame(width: 70 * scale, height: 70 * scale)
                .background(SeaGlass(scale: scale))
                .overlay(alignment: .topTrailing) {
                    SeaGlassDot(d: 12, scale: scale)
                        .offset(x: -1 * scale, y: 1 * scale)
                }
                .shadow(color: Tokens.Palette.midnight.opacity(0.22), radius: 8 * scale, y: 5 * scale)
        }
        .buttonStyle(.plain)
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
