# Mermath

## The app

The game is a native iPad app (SwiftUI, landscape, iOS 17+) in `app/`.

- `tools/sync-art.sh` regenerates `app/Art/` from `assets/` (WebP to PNG, pre-baked kelp blur). Run it after changing any art.
- Build: open `app/Mermath.xcodeproj` in Xcode, or `xcodebuild -project app/Mermath.xcodeproj -scheme Mermath -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'`.
- Needs Xcode 26 on macOS 26. To record the real voice later, drop `<prompt id>.m4a` files (ids in `app/Mermath/Audio/PromptScript.swift`) into a bundled `Voice` folder; synthesis is the stand-in.

# Design handoff

Everything Claude Code needs to build the game, from the design session.

## How to use it

1. Unzip this folder into a new project (or an empty repo).
2. Start Claude Code in that folder.
3. A good first message: "Read CLAUDE.md and everything in docs/, open the pages in reference/html/, then ask me the open questions before you plan the build."

## What is inside

| Folder | What it is |
|---|---|
| `CLAUDE.md` | The brief: who plays, what is locked, the hard rules |
| `docs/` | Game design, visual language, screens and motion, the art pipeline, open questions |
| `assets/` | The finished painted art: scenes, the sisters, the crab, props, icons, wordmark, app icon, fonts |
| `design/` | Colors, type and spacing as `tokens.json` and `tokens.css` |
| `reference/html/` | The two finished screens as web pages you can open in a browser and watch move |
| `reference/screens/` | A picture of every screen |
| `reference/storyboard/` | The original storyboard files |
| `art-pipeline/` | The scripts that drew and painted everything |

## Where the design stands

- Finished: the name, wordmark and app icon, the palette, the type, the painted look, the pick-your-mermaid screen and the Tide Pool question screen.
- Designed but in an older look: reef map, Coral Reef dive, treasure chest, grotto.
- Not designed: voice and sound, the parent screen, the Deep Sea questions.
- `docs/open-questions.md` lists 15 decisions that are still yours to make.
