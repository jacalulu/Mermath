import SwiftUI
import Observation

/// One dive: about ten questions, one pearl per right answer, never a penalty.
@MainActor
@Observable
final class DiveSession {
    let child: ChildID
    let zone: Zone

    private(set) var question: Question
    private(set) var pearls: Int
    private(set) var faded: Set<Int> = []
    private(set) var solved = false        // current question answered; gold showing
    private(set) var diveComplete = false  // tenth pearl: solved panel with the chest button
    private(set) var showHint = false
    private(set) var popTrigger = 0
    /// Rises when three right answers in a row break into the bubble party.
    private(set) var partyTrigger = 0
    /// True while the party is on: the prompt bubble steps aside for it.
    private(set) var partyActive = false

    private var progress: ChildProgress
    private let store: ProgressStore
    private let speaker: PromptSpeaker
    private let sounds: SoundPlayer
    private var hintsThisDive = 0
    private var hintThisQuestion = false
    private var streak = 0
    private var askedAt = Date()
    private var advanceTask: Task<Void, Never>?

    init(child: ChildID, zone: Zone, store: ProgressStore, speaker: PromptSpeaker, sounds: SoundPlayer) {
        self.child = child
        self.zone = zone
        self.store = store
        self.speaker = speaker
        self.sounds = sounds
        var p = store.progress(for: child)
        p.lastPlayed = Date()
        progress = p
        pearls = min(9, p.pearlsInProgress)
        question = Self.generate(zone: zone, progress: p, avoiding: nil)
        store.update(p)
    }

    private static func generate(zone: Zone, progress: ChildProgress, avoiding last: Int?) -> Question {
        switch zone {
        case .coralReef:
            return CoralReefGenerator().next(avoiding: last, quickStreak: progress.reefQuickStreak)
        case .deepSea:
            // Alternate dives between counting by 2s and by 5s
            return DeepSeaGenerator(step: progress.divesCompleted % 2 == 0 ? 2 : 5).next(after: last)
        default:
            return TidePoolGenerator(level: progress.tideLevel, rangeMax: progress.tideRangeMax)
                .next(avoiding: last)
        }
    }

    // MARK: Spoken lines

    var writtenPrompt: String {
        switch question.presentation {
        case let .addition(a, b, _): return PromptScript.reefWritten(a: a, b: b)
        case let .skip(step, current): return PromptScript.deepWritten(step: step, after: current)
        default: return PromptScript.tideWritten(question)
        }
    }

    private var spokenPrompt: Prompt {
        switch question.presentation {
        case let .addition(a, b, _): return PromptScript.reefSpoken(a: a, b: b)
        case let .skip(step, current): return PromptScript.deepSpoken(step: step, after: current)
        default: return PromptScript.tideSpoken(question)
        }
    }

    var solvedText: String {
        switch question.presentation {
        case let .addition(a, b, _): return PromptScript.reefSolvedWritten(a: a, b: b)
        case .skip: return "\(PromptScript.word(question.target).capitalized)! That makes 10 pearls."
        default: return PromptScript.solvedWritten(question.target)
        }
    }

    // MARK: Actions

    func begin() {
        speaker.speak(spokenPrompt)
        askedAt = Date()
    }

    func replay() {
        popTrigger += 1
        speaker.speak(spokenPrompt)
    }

    func answer(_ n: Int) {
        guard !solved, !diveComplete, !faded.contains(n) else { return }
        if n == question.target {
            answeredRight()
        } else {
            answeredWrong(n)
        }
    }

    private func answeredRight() {
        withMotion(.easeOut(duration: 0.35)) {
            solved = true
            showHint = false
            pearls += 1
        }
        // The catch: pop right away, chime as the pearl lands in the counter
        sounds.play(.pop)
        let sounds = self.sounds
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            sounds.play(.chime)
        }

        // Coral Reef shell fading: quick, unhinted answers grow the streak
        if case .addition = question.presentation {
            let quick = Date().timeIntervalSince(askedAt) < 7 && !hintThisQuestion
            progress.reefQuickStreak = quick ? progress.reefQuickStreak + 1 : 0
        }
        progress.pearlsInProgress = pearls
        store.update(progress)

        if pearls >= 10 {
            diveComplete = true
            speaker.speak(tenthPearlPrompt())
            return
        }
        speaker.speak(praisePrompt())

        // Three right answers IN A ROW break into the bubble party: the music
        // starts, the crab sets the goal, and the prompt bubble steps aside.
        // Otherwise just a short praise beat before the next question.
        streak += 1
        var pause: UInt64 = 3_500_000_000
        if streak >= 3 {
            streak = 0
            partyTrigger += 1
            withMotion(.easeOut(duration: 0.3)) { partyActive = true }
            pause = 11_000_000_000
            sounds.play(.bubbleMusic)
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                self?.speaker.speak(PromptScript.popAll)
                try? await Task.sleep(nanoseconds: 8_600_000_000)
                guard let self else { return }
                self.sounds.stop(.bubbleMusic)
                withMotion(.easeOut(duration: 0.4)) { self.partyActive = false }
            }
        }
        advanceTask?.cancel()
        advanceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: pause)
            guard let self, !Task.isCancelled else { return }
            self.nextQuestion()
        }
    }

    private func answeredWrong(_ n: Int) {
        withMotion(.easeOut(duration: 0.35)) {
            _ = faded.insert(n)
            showHint = true
        }
        hintsThisDive += 1
        hintThisQuestion = true
        streak = 0
        switch question.presentation {
        case let .addition(a, b, _):
            progress.reefQuickStreak = 0
            speaker.speak(PromptScript.reefHint(a: a, b: b))
        case let .skip(step, _):
            speaker.speak(PromptScript.deepHint(step: step, target: question.target))
        default:
            speaker.speak(PromptScript.hint(question.target))
        }
    }

    private func praisePrompt() -> Prompt {
        switch question.presentation {
        case let .addition(a, b, _): return PromptScript.reefPraise(a: a, b: b)
        case .skip: return PromptScript.deepPraise(question.target)
        default: return PromptScript.praise(question.target)
        }
    }

    private func tenthPearlPrompt() -> Prompt {
        switch question.presentation {
        case let .addition(a, b, _):
            return Prompt(id: "reef-tenth-\(a)-\(b)",
                          text: PromptScript.reefPraise(a: a, b: b).text + " That makes ten pearls! Open the chest!")
        case .skip:
            return PromptScript.deepTenth(question.target)
        default:
            return PromptScript.tenthPearl(question.target)
        }
    }

    private func nextQuestion() {
        withMotion(.easeOut(duration: 0.3)) {
            faded = []
            solved = false
            showHint = false
            partyActive = false
            hintThisQuestion = false
            question = Self.generate(zone: zone, progress: progress, avoiding: question.target)
        }
        begin()
    }

    /// A party bubble popped: the next rising note plays and the running
    /// count is said out loud - popping IS counting practice. Clearing all
    /// twelve earns a fanfare and a cheer.
    func bubblePopped(_ n: Int) {
        sounds.play(SoundPlayer.Effect.notes[n % SoundPlayer.Effect.notes.count])
        if n + 1 == 12 {
            sounds.play(.fanfare)
            speaker.speak(PromptScript.popAllDone)
        } else if n < 10 {
            speaker.speak(PromptScript.countWord(n + 1))
        }
    }

    /// Tapping the reef's shells counts them aloud, one by one.
    func speakCount(_ n: Int) {
        speaker.speak(PromptScript.countWord(n))
    }

    #if DEBUG
    func debugAnswerWrong() {
        if let wrong = question.choices.first(where: { $0 != question.target }) {
            answer(wrong)
        }
    }

    func debugAnswerRight() {
        answer(question.target)
    }
    #endif

    /// Tapping "Open the chest": settle progress and hand back the earned item.
    func completeDive() -> GrottoItem? {
        advanceTask?.cancel()
        progress.divesCompleted += 1
        progress.pearlsInProgress = 0
        if hintsThisDive == 0 {
            progress.cleanDives += 1
            // Widen the number range first, then climb the ladder
            if zone == .tidePool {
                if progress.tideRangeMax < 10 {
                    progress.tideRangeMax = 10
                } else if let higher = TideLevel(rawValue: progress.tideLevel.rawValue + 1) {
                    progress.tideLevel = higher
                    progress.tideRangeMax = 5
                }
            }
        }
        let earned = GrottoItem.allCases.first { !progress.grottoItems.contains($0) }
        if let earned {
            progress.grottoItems.append(earned)
            progress.newestItem = earned
        }
        store.update(progress)
        return earned
    }
}
