import Foundation

/// A spoken line with a stable id, so recordings of the parent's voice can
/// replace synthesis later: drop `<id>.m4a` files in and they are preferred.
struct Prompt {
    let id: String
    let text: String
}

/// The single source of every spoken and written line in the game.
enum PromptScript {

    static let numberWords: [Int: String] = [
        1: "one", 2: "two", 3: "three", 4: "four", 5: "five",
        6: "six", 7: "seven", 8: "eight", 9: "nine", 10: "ten",
    ]

    static func word(_ n: Int) -> String { numberWords[n] ?? "\(n)" }

    // MARK: Tide Pool

    /// The written prompt never shows the digit; it spells the word.
    static func tideWritten(_ q: Question) -> String {
        switch q.presentation {
        case .listen: return "Find the number \(word(q.target))!"
        case .count: return "Count the bubbles!"
        default: return ""
        }
    }

    static func tideSpoken(_ q: Question) -> Prompt {
        switch q.presentation {
        case .listen:
            return Prompt(id: "tide-listen-\(q.target)", text: "Find the number \(word(q.target))!")
        case .count:
            return Prompt(id: "tide-count-\(q.target)", text: "Count the bubbles! How many are there?")
        default:
            return Prompt(id: "none", text: "")
        }
    }

    // MARK: Coral Reef

    static func reefWritten(a: Int, b: Int) -> String { "\(a) + \(b) = " }

    static func reefSpoken(a: Int, b: Int) -> Prompt {
        Prompt(id: "reef-\(a)-plus-\(b)", text: "What is \(word(a)) and \(word(b))?")
    }

    // MARK: Feedback

    static func hint(_ target: Int) -> Prompt {
        let counting = (1...target).map { word($0) }.joined(separator: ", ")
        return Prompt(id: "hint-count-\(target)", text: "Count with me: \(counting)!")
    }

    static func reefHint(a: Int, b: Int) -> Prompt {
        let first = (1...a).map { word($0) }.joined(separator: ", ")
        let rest = ((a + 1)...(a + b)).map { word($0) }.joined(separator: ", ")
        return Prompt(id: "reef-hint-\(a)-\(b)", text: "Count all the shells: \(first), and then \(rest)!")
    }

    static func praise(_ target: Int) -> Prompt {
        Prompt(id: "praise-\(target)", text: "You found \(word(target))!")
    }

    static func reefPraise(a: Int, b: Int) -> Prompt {
        Prompt(id: "reef-praise-\(a)-\(b)", text: "\(word(a)) and \(word(b)) make \(word(a + b))!")
    }

    static func tenthPearl(_ target: Int) -> Prompt {
        Prompt(id: "tenth-pearl-\(target)", text: "You found \(word(target))! That makes ten pearls! Open the chest!")
    }

    static func solvedWritten(_ target: Int) -> String {
        "You found \(word(target))! That makes 10 pearls."
    }

    static func reefSolvedWritten(a: Int, b: Int) -> String {
        "\(a) and \(b) make \(a + b)! That is 10 pearls."
    }

    // MARK: Screens

    static let whoIsDiving = Prompt(id: "who-is-diving", text: "Who is diving today?")
    static func hello(_ child: ChildID) -> Prompt {
        Prompt(id: "hello-\(child.rawValue)", text: "Hello \(child.displayName)! Where shall we dive?")
    }
    static let chestOpen = Prompt(id: "chest-open", text: "Ten pearls! The chest is open!")
    static func earned(_ item: GrottoItem) -> Prompt {
        Prompt(id: "earned-\(item.rawValue)", text: "You earned a \(item.displayName.lowercased())! Put it in your grotto!")
    }
    static let myGrotto = Prompt(id: "my-grotto", text: "Look at your grotto! Dive again to earn more treasures!")
}
