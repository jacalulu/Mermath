# Mermath: design handoff

Everything Claude Code needs to build the game, from the design session.

## How to use it

1. Unzip this folder into a new project (or an empty repo).
2. Start Claude Code in that folder.
3. A good first message: "Read CLAUDE.md and everything in docs/, open the pages in reference/html/, then ask me the open questions before you plan the build."

## What is inside

| Folder | What it is |
|---|---|
| `CLAUDE.md` | The brief: who plays, what is locked, the hard rules |
| `docs/` | Game design, visual language, screens and motion, the art recipe, open questions |
| `assets/` | The finished painted art: six scenes in layers, the sisters, the crab, props, icons, wordmark, app icon, fonts |
| `design/` | Colors, type and spacing as `tokens.json` and `tokens.css` |
| `reference/html/` | All six screens as web pages you can open in a browser and watch move |
| `reference/screens/` | A picture of every screen |
| `reference/storyboard/` | The original storyboard files |
| `art-pipeline/` | The scripts that draw and paint everything, runnable as they are |

## Where the design stands

- Finished and painted: all six screens (pick your mermaid, reef map, Tide Pool dive, Coral Reef dive, treasure chest, grotto), the wordmark and app icon, the palette and the type.
- A tested recipe for making more art in the same look: `docs/art-recipe.md`.
- Not designed: voice and sound, the parent screen, the Deep Sea questions.
- `docs/open-questions.md` lists 17 decisions that are still yours to make.
