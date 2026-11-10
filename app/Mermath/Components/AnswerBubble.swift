import SwiftUI

enum AnswerBubbleState {
    case normal
    case gold      // the right answer, tapped: gold gradient and glow
    case faded     // a wrong answer, tapped: 45% and stays there
}

/// A 140px answer circle: 3px white rim, bubble gradient highlight at the top
/// left, soft midnight shadow. Gold swaps the gradient and adds the glow.
struct AnswerBubble: View {
    let number: Int
    let state: AnswerBubbleState
    let scale: CGFloat
    let tap: () -> Void

    private var diameter: CGFloat { Tokens.Space.answerBubble * scale }

    var body: some View {
        Button(action: tap) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            stops: state == .gold
                                ? Tokens.Gradients.rightAnswerStops
                                : Tokens.Gradients.answerBubbleStops,
                            center: Tokens.Gradients.gradientCenter,
                            startRadius: 0,
                            endRadius: diameter * 1.02
                        )
                    )
                // inset 0 -10 18 rgba(23,135,156,0.25): a teal shade along the lower inside rim
                Circle()
                    .stroke(Color(hex: 0x17879C, opacity: 0.25), lineWidth: 14 * scale)
                    .blur(radius: 9 * scale)
                    .offset(y: -6 * scale)
                    .clipShape(Circle())
                    .opacity(state == .gold ? 0 : 1)
                Circle()
                    .stroke(Color.white, lineWidth: 3 * scale)
                Text("\(number)")
                    .font(baloo(Tokens.TypeScale.answerNumeral, weight: 700, scale: scale))
                    .foregroundStyle(Tokens.Palette.midnight)
                    .padding(.top, 10 * scale)
            }
            .frame(width: diameter, height: diameter)
            .shadow(color: Tokens.Palette.midnight.opacity(0.3), radius: 11 * scale, y: 10 * scale)
            .shadow(
                color: Color(hex: 0xFFD27A, opacity: state == .gold ? 0.95 : 0),
                radius: 22 * scale
            )
            .opacity(state == .faded ? Tokens.Opacity.wrongAnswer : 1)
        }
        .buttonStyle(.plain)
        .disabled(state != .normal)
    }
}
