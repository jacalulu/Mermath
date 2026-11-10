import Foundation

enum Zone: String, Codable, CaseIterable {
    case tidePool
    case coralReef
    case deepSea

    var displayName: String {
        switch self {
        case .tidePool: return "Tide Pool"
        case .coralReef: return "Coral Reef"
        case .deepSea: return "Deep Sea"
        }
    }
}

/// The Tide Pool ladder: listen -> count. The prompt never shows the digit,
/// so there is no "match the numeral" level; she always has to recognise it.
enum TideLevel: Int, Codable, CaseIterable {
    case listen
    case count
}

/// How the question presents itself in the speech bubble.
enum QuestionPresentation: Equatable {
    /// She hears the number and finds the numeral (the locked style frame).
    case listen
    /// She counts objects and finds the numeral.
    case count
    /// Coral Reef: a + b with countable shells over each addend.
    case addition(a: Int, b: Int, showShells: Bool)
    /// Deep Sea: skip counting. She wears `current` and swims through the
    /// ring that comes next when counting by `step`.
    case skip(step: Int, current: Int)
}

struct Question: Equatable {
    let target: Int
    let choices: [Int]
    let presentation: QuestionPresentation
}
