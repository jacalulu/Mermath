import SwiftUI
import Observation
import UIKit

/// Root game state: who is playing, which screen is up, the running dive.
@MainActor
@Observable
final class AppModel {
    enum Route: Equatable {
        case intro
        case pick
        case map
        case dive
        case chest(GrottoItem?)
        case journey(GrottoItem?, home: Bool)
        case hunt(GrottoItem?)
        case grotto
        case parent
        #if DEBUG
        case debugLab
        case debugCompA
        case debugCompB
        #endif
    }

    /// The story plays on launch; with Reduce Motion it is skipped entirely.
    private(set) var route: Route = UIAccessibility.isReduceMotionEnabled ? .pick : .intro
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
        if route == .pick {
            speaker.speak(PromptScript.whoIsDiving)
        }
    }

    /// The little whale on the pick screen plays the story again.
    func replayIntro() {
        speaker.stop()
        go(.intro)
    }

    /// The intro ended (or was tapped away). The story's closing ask - "So,
    /// who is diving today?" - is spoken HERE, over the three named sisters;
    /// a skipped story gets the plain question instead.
    func finishIntro(finishedStory: Bool) {
        sounds.stop(.introMusic)
        go(.pick)
        speaker.speak(finishedStory ? PromptScript.rally3 : PromptScript.whoIsDiving)
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
        // The map reveal lands right after the pearls drain into the lock
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard let self, case .chest = self.route else { return }
            self.speaker.speak(PromptScript.chestMap)
        }
    }

    /// The chest held a map: swim out after it (the travelling shot), dig the
    /// treasure free, then swim it home. With nothing left to earn, go home.
    func followMap(_ earned: GrottoItem?) {
        guard earned != nil else {
            go(.grotto)
            return
        }
        go(.journey(earned, home: false))
    }

    /// The travelling shot ended: out lands at the dig, home at the grotto.
    func journeyDone(_ earned: GrottoItem?, home: Bool) {
        if home {
            placeInGrotto(earned)
        } else {
            go(.hunt(earned))
        }
    }

    /// The treasure is dug free: swim it home.
    func carryHome(_ earned: GrottoItem?) {
        go(.journey(earned, home: true))
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
                    } else if ticks % 7 == 0 && !dive.solved {
                        dive.debugAnswerWrong()
                    } else if !dive.solved {
                        dive.debugAnswerRight()
                    }
                } else if case let .chest(item) = self.route {
                    self.followMap(item)
                } else if case let .hunt(item) = self.route {
                    self.carryHome(item)
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

    func debugShowLab() {
        go(.debugLab)
    }

    func debugShowComp(_ b: Bool) {
        go(b ? .debugCompB : .debugCompA)
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
        v.partyTrigger = dive.partyTrigger
        v.partyActive = dive.partyActive
        if case .count = dive.question.presentation { v.countIcons = dive.question.target }
        return v
    }
}
