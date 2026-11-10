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
        .padding(.top, 9 * scale)
        .padding(.bottom, 9 * scale)
        .padding(.leading, 12 * scale)
        .padding(.trailing, 26 * scale)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.speechBubble * scale)
                .fill(Tokens.Palette.pearl)
        )
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

/// The small Pearl triangle pointing from the bubble to the crab.
/// Frame 70x54, path M34 0 L66 0 L4 52 Z.
struct SpeechBubbleTail: View {
    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 70
            let sy = geo.size.height / 54
            Path { p in
                p.move(to: CGPoint(x: 34 * sx, y: 0))
                p.addLine(to: CGPoint(x: 66 * sx, y: 0))
                p.addLine(to: CGPoint(x: 4 * sx, y: 52 * sy))
                p.closeSubpath()
            }
            .fill(Tokens.Palette.pearl)
        }
    }
}
