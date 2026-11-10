import SwiftUI

/// For the parent only (behind the two-second hold on the wordmark):
/// per-child progress and a reset. Quiet Midnight styling, no child affordances.
struct ParentScreen: View {
    let store: ProgressStore
    var onClose: () -> Void = {}

    @Environment(\.stage) private var m
    @State private var refresh = 0

    var body: some View {
        let s = m.scale
        ZStack {
            Tokens.Palette.midnight
                .stage(x: 0, y: 0, w: 800, h: 600)
                .bleed()

            VStack(spacing: 18 * s) {
                ArtImage("brand/wordmark-pearl.png")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200 * s)
                    .padding(.top, 10 * s)

                ForEach(ChildID.allCases) { child in
                    let p = store.progress(for: child)
                    HStack(spacing: 14 * s) {
                        Circle()
                            .fill(child.color)
                            .frame(width: 18 * s, height: 18 * s)
                        VStack(alignment: .leading, spacing: 2 * s) {
                            Text(child.displayName)
                                .font(baloo(24, weight: 700, scale: s))
                                .foregroundStyle(Tokens.Palette.pearl)
                            Text(summary(p))
                                .font(baloo(16, weight: 600, scale: s))
                                .foregroundStyle(Tokens.Palette.pearl.opacity(0.75))
                        }
                        Spacer()
                        Button("Reset") {
                            store.reset(child)
                            refresh += 1
                        }
                        .font(baloo(16, weight: 700, scale: s))
                        .foregroundStyle(Tokens.Palette.pearl)
                        .padding(.vertical, 8 * s)
                        .padding(.horizontal, 16 * s)
                        .background(Capsule().strokeBorder(Tokens.Palette.pearl.opacity(0.5), lineWidth: 1.5 * s))
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24 * s)
                    .padding(.vertical, 12 * s)
                    .background(
                        RoundedRectangle(cornerRadius: 20 * s)
                            .fill(Color.white.opacity(0.06))
                    )
                }

                GoldButton(title: "Back to the game", scale: s, action: onClose)
                    .padding(.top, 4 * s)
            }
            .frame(width: 600 * s)
            .id(refresh)
        }
    }

    private func summary(_ p: ChildProgress) -> String {
        let level: String
        switch p.tideLevel {
        case .match: level = "matching numerals"
        case .listen: level = "finding heard numbers"
        case .count: level = "counting objects"
        }
        let zone = p.usualZone == .coralReef ? "Coral Reef (addition)" : "Tide Pool, \(level)"
        return "\(zone) · numbers to \(p.tideRangeMax) · \(p.divesCompleted) dives · \(p.grottoItems.count) treasures"
    }
}
