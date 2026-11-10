import Foundation

enum GrottoItem: String, Codable, CaseIterable, Identifiable {
    case starfishLamp
    case kelpCurtain
    case shellBed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .starfishLamp: return "Starfish lamp"
        case .kelpCurtain: return "Kelp curtain"
        case .shellBed: return "Shell bed"
        }
    }
}

struct ChildProgress: Codable {
    var child: ChildID
    var tideLevel: TideLevel = .match
    var tideRangeMax: Int = 5
    var divesCompleted: Int = 0
    var pearlsInProgress: Int = 0
    var grottoItems: [GrottoItem] = []
    var newestItem: GrottoItem?
    var reefQuickStreak: Int = 0
    var cleanDives: Int = 0        // dives finished without hints, toward the Deep Sea unlock
    var lastPlayed: Date?

    var usualZone: Zone {
        child == .ophelia ? .coralReef : .tidePool
    }

    static func fresh(_ child: ChildID) -> ChildProgress {
        ChildProgress(child: child)
    }
}

struct SaveFile: Codable {
    var version = 1
    var children: [ChildProgress]
}
