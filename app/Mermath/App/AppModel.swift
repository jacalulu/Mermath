import SwiftUI
import Observation

/// Root game state: who is playing, which screen is up, the running dive.
@MainActor
@Observable
final class AppModel {
    enum Route: Equatable {
        case pick
        case map
        case dive
        case chest(GrottoItem?)
        case grotto
        case parent
    }

    private(set) var route: Route = .pick
    private(set) var activeChild: ChildID?
    private(set) var session: DiveSession?

    let store = ProgressStore()
    let speaker: PromptSpeaker = SynthSpeaker()
    let sounds = SoundPlayer()

    private func go(_ newRoute: Route) {
        withMotion(.easeInOut(duration: 0.45)) {
            route = newRoute
        }
    }

    func appeared() {
        speaker.speak(PromptScript.whoIsDiving)
    }

    func pick(_ child: ChildID) {
        activeChild = child
        speaker.speak(PromptScript.hello(child))
        go(.map)
    }

    func switchMermaid() {
        activeChild = nil
        session = nil
        speaker.speak(PromptScript.whoIsDiving)
        go(.pick)
    }

    func startDive(_ zone: Zone) {
        guard let child = activeChild else { return }
        let dive = DiveSession(child: child, zone: zone, store: store, speaker: speaker, sounds: sounds)
        session = dive
        go(.dive)
        dive.begin()
    }

    func leaveDive() {
        session = nil
        go(.map)
    }

    func openChest() {
        guard let dive = session else { return }
        let earned = dive.completeDive()
        session = nil
        sounds.play(.fanfare)
        speaker.speak(PromptScript.chestOpen)
        go(.chest(earned))
    }

    func placeInGrotto(_ item: GrottoItem?) {
        if let item {
            speaker.speak(PromptScript.earned(item))
        }
        go(.grotto)
    }

    func diveAgain() {
        go(.map)
    }

    func openParent() {
        go(.parent)
    }

    func closeParent() {
        go(.pick)
    }

    #if DEBUG
    /// Plays a whole dive through the real DiveSession: mostly right answers,
    /// a wrong one every fourth tick, then chest and grotto.
    func debugAutoplay() {
        store.reset(.daphne)
        pick(.daphne)
        startDive(.tidePool)
        var ticks = 0
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else {
                    timer.invalidate()
                    return
                }
                ticks += 1
                if let dive = self.session {
                    if dive.diveComplete {
                        self.openChest()
                    } else if ticks % 4 == 0 && !dive.solved {
                        dive.debugAnswerWrong()
                    } else if !dive.solved {
                        dive.debugAnswerRight()
                    }
                } else if case let .chest(item) = self.route {
                    self.placeInGrotto(item)
                } else {
                    timer.invalidate()
                }
            }
        }
    }

    func debugTideHint() {
        pick(.daphne)
        startDive(.tidePool)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.session?.debugAnswerWrong()
        }
    }

    func debugTideSolved() {
        var p = store.progress(for: .daphne)
        p.pearlsInProgress = 9
        store.update(p)
        pick(.daphne)
        startDive(.tidePool)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.session?.debugAnswerRight()
        }
    }

    func debugShowChest() {
        go(.chest(.starfishLamp))
    }

    func debugShowGrotto() {
        var p = store.progress(for: .violet)
        if p.grottoItems.isEmpty {
            p.grottoItems = [.starfishLamp]
            p.newestItem = .starfishLamp
            store.update(p)
        }
        go(.grotto)
    }
    #endif

    // MARK: Tide Pool view state

    func tideState(_ dive: DiveSession) -> TidePoolViewState {
        var v = TidePoolViewState(
            prompt: dive.writtenPrompt,
            choices: dive.question.choices,
            target: dive.question.target,
            pearls: dive.pearls
        )
        v.faded = dive.faded
        v.solved = dive.solved
        v.diveComplete = dive.diveComplete
        v.showHint = dive.showHint
        v.solvedText = dive.solvedText
        v.popTrigger = dive.popTrigger
        if case .count = dive.question.presentation { v.countIcons = dive.question.target }
        return v
    }
}
