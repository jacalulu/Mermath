import SwiftUI

/// Enum-driven root switch: no navigation chrome, nothing a three year old
/// can swipe to escape. Cross-dissolves between screens.
struct RootView: View {
    @State private var model = AppModel()

    var body: some View {
        StageView {
            switch model.route {
            case .intro:
                IntroScreen(
                    speak: { model.speaker.speak($0) },
                    onDone: { model.finishIntro(saidWho: $0) }
                )
                .transition(.opacity)

            case .pick:
                PickMermaidScreen(
                    onPick: { model.pick($0) },
                    onParentGate: { model.openParent() }
                )
                .transition(.opacity)

            case .map:
                if let child = model.activeChild {
                    ReefMapScreen(
                        child: child,
                        onDive: { model.startDive($0) },
                        onSwitchMermaid: { model.switchMermaid() }
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
                    } else {
                        TidePoolScreen(
                            state: model.tideState(dive),
                            onAnswer: { dive.answer($0) },
                            onReplay: { dive.replay() },
                            onMap: { model.leaveDive() },
                            onOpenChest: { model.openChest() },
                            onBonusPop: { dive.playBonusNote($0) }
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

            case let .hunt(earned):
                HuntScreen(
                    earned: earned,
                    onDone: { model.placeInGrotto(earned) },
                    onFind: { model.sounds.play(SoundPlayer.Effect.notes[$0 % SoundPlayer.Effect.notes.count]) },
                    speakFound: { model.speaker.speak(PromptScript.huntFound) }
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
                case "map": model.pick(.daphne)
                case "chest": model.pick(.violet); model.debugShowChest()
                case "grotto": model.pick(.violet); model.debugShowGrotto()
                default: break
                }
                return
            }
            #endif
            model.appeared()
        }
    }
}
