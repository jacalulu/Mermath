import SwiftUI

enum ChildID: String, Codable, CaseIterable, Identifiable {
    case ophelia
    case daphne
    case violet

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ophelia: return "Ophelia"
        case .daphne: return "Daphne"
        case .violet: return "Violet"
        }
    }

    /// Sister color: only ever on the sister and her name-tag dot.
    var color: Color {
        switch self {
        case .ophelia: return Tokens.Palette.ophelia
        case .daphne: return Tokens.Palette.daphne
        case .violet: return Tokens.Palette.violet
        }
    }

    var puppet: SisterSpec {
        switch self {
        case .ophelia: return .ophelia
        case .daphne: return .daphne
        case .violet: return .violet
        }
    }
}
