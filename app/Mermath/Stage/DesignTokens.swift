import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// design/tokens.json transcribed. Values are design-space (800x600) and get
/// multiplied by the stage scale at the point of use.
enum Tokens {

    // MARK: Colors

    enum Palette {
        // The painted world (only inside paintings)
        static let surface = Color(hex: 0xD7F6F0)
        static let shallows = Color(hex: 0x95DFDA)
        static let lagoon = Color(hex: 0x4EB8BF)
        static let deepWater = Color(hex: 0x2494A2)
        static let kelp = Color(hex: 0x105563)
        static let sand = Color(hex: 0xEBD0A0)

        // Controls
        static let midnight = Color(hex: 0x061A33)
        static let pearl = Color(hex: 0xFFF4DC)
        static let bubble = Color(hex: 0xCFF5EE)
        static let goldfish = Color(hex: 0xFF9A3D)

        // Sisters (only ever on the sisters and their name-tag dots)
        static let ophelia = Color(hex: 0xFF7EB6)
        static let daphne = Color(hex: 0xFFE14D)
        static let violet = Color(hex: 0xA98BF5)

        // Panels
        static let panel = Color(hex: 0x061A33, opacity: 0.8)
        static let counterPanel = Color(hex: 0x061A33, opacity: 0.76)
        static let emptyPearlRing = Color(hex: 0xFFF4DC, opacity: 0.6)
    }

    // MARK: Gradients (stops; radii are computed from the drawn size)

    enum Gradients {
        /// radial at 32% 24%: #FFFFFF 0, #F2FFFB 22%, #CFF5EE 60%, #9FE8DE 100%
        static let answerBubbleStops: [Gradient.Stop] = [
            .init(color: Color(hex: 0xFFFFFF), location: 0),
            .init(color: Color(hex: 0xF2FFFB), location: 0.22),
            .init(color: Color(hex: 0xCFF5EE), location: 0.60),
            .init(color: Color(hex: 0x9FE8DE), location: 1),
        ]
        /// radial at 32% 24%: #FFF4DC 0, #FFD27A 42%, #FF9A3D 100%
        static let rightAnswerStops: [Gradient.Stop] = [
            .init(color: Color(hex: 0xFFF4DC), location: 0),
            .init(color: Color(hex: 0xFFD27A), location: 0.42),
            .init(color: Color(hex: 0xFF9A3D), location: 1),
        ]
        static let gradientCenter = UnitPoint(x: 0.32, y: 0.24)

        /// linear 180deg: #FFD27A -> #FF9A3D
        static let button = LinearGradient(
            colors: [Color(hex: 0xFFD27A), Color(hex: 0xFF9A3D)],
            startPoint: .top, endPoint: .bottom
        )
    }

    // MARK: Type (Baloo 2; PostScript names from the converted TTFs)

    enum TypeScale {
        static let answerNumeral: CGFloat = 96   // 700
        static let prompt: CGFloat = 29          // 700
        static let nameTag: CGFloat = 26         // 700
        static let panel: CGFloat = 24           // 600
        static let solvedPanel: CGFloat = 25     // 600 (solved text, from the reference page)
        static let button: CGFloat = 22          // 700
        static let pill: CGFloat = 22            // 600
    }

    // MARK: Spacing (800x600 design space)

    enum Space {
        static let edge: CGFloat = 24
        static let gap: CGFloat = 16
        static let answerGap: CGFloat = 26
        static let answerBubble: CGFloat = 140
    }

    enum Radius {
        static let pill: CGFloat = 999
        static let speechBubble: CGFloat = 30
    }

    enum Opacity {
        static let wrongAnswer: Double = 0.45
    }
}

/// Baloo 2 at a design-space size, scaled by the stage.
/// weight: 500, 600 or 700 (the three bundled weights).
func baloo(_ designSize: CGFloat, weight: Int, scale: CGFloat) -> Font {
    let name: String
    switch weight {
    case 700: name = "Baloo2-Bold"
    case 600: name = "Baloo2-SemiBold"
    default: name = "Baloo2-Medium"
    }
    return .custom(name, fixedSize: designSize * scale)
}
