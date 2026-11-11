# Mermath

A mermaid-themed math game for three sisters, built by their parent as a side project. This folder is the design handoff. All six screens are designed and painted. Your job is to build the game around them.

## The one thing to get right: the art

Every screen is a stack of **painted layers**: scenery repainted with visible brush strokes, characters built from separately painted pieces, crisp faces on top, and gentle motion. That look is the product.

- Use the finished art in `assets/`. All six screens are there, with a `layers.json` beside each scene saying exactly where every layer goes.
- When you need anything new (a scene, an item, a character, an icon), follow `docs/art-recipe.md` step by step. It is three commands and takes under a minute.
- Never substitute flat vector art, CSS-drawn scenery, emoji, stock icons, generated images, or a "painterly" filter. Never place a layer by eye.
- A screen is not done until it passes the checklist at the end of `docs/art-recipe.md`.

## Who plays

| Child | Age | Color | Where she is in math | Starts in |
|---|---|---|---|---|
| Ophelia | big sister | pink | Counts by 2s and 5s. Learning basic addition, still slow at it. | Coral Reef |
| Daphne | 3½ (twin) | lemon yellow | Number recognition | Tide Pool |
| Violet | 3½ (twin) | purple | Number recognition | Tide Pool |

None of them is expected to read. Every instruction is spoken, and every control is a picture or a big shape.

## Read these first

1. `reference/html/*.html`: all six screens as plain HTML and CSS. Open them in a browser and watch them move. They are the source of truth for layout and motion.
2. `reference/screens/`: a picture of every screen and state.
3. `docs/game-design.md`: the loop, the zones, what happens on right and wrong answers.
4. `docs/visual-language.md`: palette, type, spacing, icons, wordmark. These are rules, not suggestions.
5. `docs/screens-and-motion.md`: layer stacks, pivots and timings.
6. `docs/art-recipe.md`: how to make new art that matches.
7. `docs/open-questions.md`: decisions the parent has not made yet. Ask before building anything that depends on one.

## What is locked and what is yours

Locked (do not redesign): the name Mermath, the wordmark and app icon, the palette, Baloo 2 for all text and numerals, the painted look, the six screens, the spacing rules, and the no-timers, no-lives rule.

Yours to build: the game logic, voice and sound, saved progress, a parent screen, the Deep Sea questions, and any further screens or items (using the art recipe).

## Hard rules

- No timers, no lives, no penalties, no "wrong" sounds or red crosses. A wrong tap fades that bubble and brings up a counting hint.
- Only the right answer ever glows.
- Orange (`#FF9A3D`) means "tap me" or "you got it" and nothing else. Sister colors appear only on the sisters.
- Nothing that moves crosses a face, a label or an answer bubble. (One parent-approved amendment: in the Tide Pool the answer bubbles themselves swim — fish carry them, and catching the right one is the game.)
- Controls stay 24px from every edge of the 800x600 design space. Neighbours sit at least 16px apart, answer bubbles at least 26px.
- In number recognition the prompt never shows the digit. It says and spells the word ("Find the number four!"), so the child has to recognise the numeral herself.
- Wrap all motion in `@media (prefers-reduced-motion: no-preference)`.

## Suggested build (confirm with the parent first)

The design space is 800x600 (4:3, landscape), which scales cleanly to a tablet. The reference screens are DOM and CSS, so a plain web app is the shortest path: Vite and TypeScript, one scaled stage element, CSS animations, per-child progress in `localStorage`, installable as a PWA. No game engine is needed. The target device has not been confirmed; see `docs/open-questions.md`.

## Folder map

- `assets/scenes/<scene>/`: painted layers and `layers.json` for home, reef-map, tide-pool, coral-reef, treasure-chest and grotto.
- `assets/characters/`: the three sisters and the crab, as stackable pieces.
- `assets/props/`, `assets/ui/`, `assets/brand/`, `assets/fonts/`: small painted objects, icons, the wordmark and app icon, Baloo 2.
- `design/tokens.json` and `design/tokens.css`: palette, type, spacing and motion values.
- `app/`: the shipped native iPad app (SwiftUI), built from this handoff. `tools/sync-art.sh` copies `assets/` into its bundle; `tools/make-voice.py` generates the spoken prompts. Debug builds hot-reload Swift edits into the running simulator (InjectionLite: save a file, ~1s, watch the app console for 🔥) — rebuild only for new files, assets, or stored-property changes.
- `reference/storyboard/`: the original storyboard source files, with `blob-map.json` mapping their image ids to files in `assets/`.
- `art-pipeline/`: the scripts that draw and paint everything.
