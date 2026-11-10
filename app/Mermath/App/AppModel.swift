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
        if case .match = dive.question.presentation { v.promptNumeral = dive.question.target }
        if case .count = dive.question.presentation { v.countIcons = dive.question.target }
        return v
    }
}
