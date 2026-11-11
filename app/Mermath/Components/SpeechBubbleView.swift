import SwiftUI

/// The crab's Pearl speech bubble: shell replay button plus the written prompt.
/// Pops (scale 1 -> 1.06 -> 1, 0.5s) whenever `popTrigger` changes.
struct SpeechBubbleView: View {
    let text: String
    let scale: CGFloat
    let popTrigger: Int
    var countIcons: Int?
    let replay: () -> Void

    var body: some View {
        HStack(spacing: 12 * scale) {
            Button(action: replay) {
                ArtImage("ui/icon-shell.png")
                    .frame(width: 82 * scale, height: 70 * scale)
            }
            .buttonStyle(.plain)
            Text(text)
                .font(baloo(Tokens.TypeScale.prompt, weight: 700, scale: scale))
                .foregroundStyle(Tokens.Palette.midnight)
                .padding(.top, 4 * scale)
            if let countIcons {
                // Count level: little bubbles to count, five per row
                let rows = stride(from: 0, to: countIcons, by: 5).map { start in
                    min(5, countIcons - start)
                }
                VStack(alignment: .leading, spacing: 4 * scale) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, n in
                        HStack(spacing: 4 * scale) {
                            ForEach(0..<n, id: \.self) { _ in
                                ArtImage("props/bubble.png")
                                    .frame(width: 26 * scale, height: 26 * scale)
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 10 * scale)
        .padding(.bottom, 12 * scale)
        .padding(.leading, 16 * scale)
        .padding(.trailing, 34 * scale)
        .background(ArtImage("ui/bubble-panel.png"))
        .shadow(color: Tokens.Palette.midnight.opacity(0.28), radius: 11 * scale, y: 10 * scale)
        .keyframeAnimator(initialValue: 1.0, trigger: popTrigger) { content, value in
            content.scaleEffect(value)
        } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(1.06, duration: 0.2, timingCurve: .easeOut)
                LinearKeyframe(1.0, duration: 0.3, timingCurve: .easeOut)
            }
        }
    }
}

/// The painted swoop from the bubble down toward the crab.
struct SpeechBubbleTail: View {
    var body: some View {
        ArtImage("ui/bubble-tail.png")
    }
}
