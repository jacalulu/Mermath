import SwiftUI

/// Enum-driven root switch: no navigation chrome, nothing a three year old
/// can swipe to escape. Cross-dissolves between screens.
struct RootView: View {
    @State private var model = AppModel()
    #if DEBUG
    /// Hot reload (InjectionLite): bumping this id rebuilds the whole view
    /// tree with the freshly injected implementations.
    @State private var injectionTick = 0
    #endif

    var body: some View {
        stage
            #if DEBUG
            .id(injectionTick)
            .onReceive(NotificationCenter.default.publisher(
                for: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))) { _ in
                injectionTick += 1
            }
            #endif
    }

    private var stage: some View {
        StageView {
            switch model.route {
            case .intro:
                IntroScreen(
                    speak: { model.speaker.speak($0) },
                    play: { model.sounds.play($0) },
                    onDone: { model.finishIntro(finishedStory: $0) }
                )
                .transition(.opacity)

            case .pick:
                PickMermaidScreen(
                    onPick: { model.pick($0) },
                    onParentGate: { model.openParent() },
                    onStory: { model.replayIntro() }
                )
                .transition(.opacity)

            case .map:
                if let child = model.activeChild {
                    ReefMapScreen(
                        child: child,
                        deepSeaUnlocked: model.store.progress(for: child).cleanDives >= 2,
                        onDive: { model.startDive($0) },
                        onHome: { model.switchMermaid() },
                        speak: { model.speaker.speak($0) }
                    )
                    .transition(.opacity)
                }

            case .dive:
                if let dive = model.session {
                    if dive.zone == .coralReef {
                        CoralReefScreen(
                            dive: dive,
                            onOpenChest: { model.openChest() },
                            onMap: { model.leaveDive() }
                        )
                        .transition(.opacity)
                    } else if dive.zone == .deepSea {
                        DeepSeaScreen(
                            dive: dive,
                            onOpenChest: { model.openChest() },
                            onMap: { model.leaveDive() }
                        )
                        .transition(.opacity)
                    } else {
                        TidePoolScreen(
                            state: model.tideState(dive),
                            onAnswer: { dive.answer($0) },
                            onReplay: { dive.replay() },
                            onMap: { model.leaveDive() },
                            onOpenChest: { model.openChest() },
                            onBonusPop: { dive.bubblePopped($0) }
                        )
                        .transition(.opacity)
                    }
                }

            case let .chest(earned):
                ChestScreen(
                    child: model.activeChild,
                    earned: earned,
                    onPlace: { model.followMap(earned) },
                    onMap: { model.diveAgain() }
                )
                .transition(.opacity)

            case let .journey(earned, home):
                JourneyScreen(
                    child: model.activeChild,
                    earned: earned,
                    home: home,
                    speak: { model.speaker.speak($0) },
                    onDone: { model.journeyDone(earned, home: home) }
                )
                .transition(.opacity)

            case let .hunt(earned):
                HuntScreen(
                    earned: earned,
                    onDone: { model.carryHome(earned) },
                    speak: { model.speaker.speak($0) },
                    play: { model.sounds.play($0) }
                )
                .transition(.opacity)

            case .grotto:
                if let child = model.activeChild {
                    GrottoScreen(
                        child: child,
                        progress: model.store.progress(for: child),
                        onDiveAgain: { model.diveAgain() }
                    )
                    .transition(.opacity)
                }

            case .parent:
                ParentScreen(store: model.store, onClose: { model.closeParent() })
                    .transition(.opacity)

            #if DEBUG
            case .debugLab:
                DesignLabScreen()
                    .transition(.opacity)
            case .debugCompA:
                MapConceptA()
                    .transition(.opacity)
            case .debugCompB:
                MapConceptB()
                    .transition(.opacity)
            #endif
            }
        }
        .onAppear {
            #if DEBUG
            // Headless verification: `simctl launch ... -screen tidePool|coralReef|map|chest|grotto`
            let args = ProcessInfo.processInfo.arguments
            if let i = args.firstIndex(of: "-screen"), i + 1 < args.count {
                switch args[i + 1] {
                case "autoplay": model.debugAutoplay()
                case "tidePool": model.pick(.daphne); model.startDive(.tidePool)
                case "tideHint": model.debugTideHint()
                case "tideSolved": model.debugTideSolved()
                case "coralReef": model.pick(.ophelia); model.startDive(.coralReef)
                case "deepSea": model.pick(.ophelia); model.startDive(.deepSea)
                case "map": model.pick(.daphne)
                case "chest": model.pick(.violet); model.debugShowChest()
                case "designLab": model.debugShowLab()
                case "compA": model.debugShowComp(false)
                case "compB": model.debugShowComp(true)
                case "grotto": model.pick(.violet); model.debugShowGrotto()
                case "hunt": model.pick(.daphne); model.debugShowHunt()
                default: break
                }
                return
            }
            #endif
            model.appeared()
        }
    }
}
