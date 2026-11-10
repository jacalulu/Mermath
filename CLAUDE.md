# Mermath

A mermaid-themed math game for three sisters, built by their parent as a side project. This folder is the design handoff: the design work is done for two screens and specified for the rest. Your job is to build the game.

## Who plays

| Child | Age | Color | Where she is in math | Starts in |
|---|---|---|---|---|
| Ophelia | big sister | pink | Counts by 2s and 5s. Learning basic addition, still slow at it. | Coral Reef |
| Daphne | 3½ (twin) | lemon yellow | Number recognition | Tide Pool |
| Violet | 3½ (twin) | purple | Number recognition | Tide Pool |

None of them is expected to read. Every instruction is spoken, and every control is a picture or a big shape.

## Read these first

1. `docs/game-design.md`: the loop, the zones, what happens on right and wrong answers.
2. `docs/visual-language.md`: palette, type, spacing, icons, wordmark. These are rules, not suggestions.
3. `docs/screens-and-motion.md`: layer stacks, coordinates, pivots and timings for the two locked screens.
4. `docs/open-questions.md`: decisions the parent has not made yet. Ask before building anything that depends on one.
5. `reference/html/*.html`: the two locked screens as plain HTML and CSS. Open them in a browser. They are the source of truth for layout and motion.
6. `reference/screens/`: a picture of every screen. Files marked `LOCKED` are final. Files marked `old-style` show the right content in a look that has been replaced.

## What is locked and what is not

Locked (do not redesign): the name Mermath, the wordmark and app icon, the palette, Baloo 2 for all text and numerals, the painted look, the Tide Pool question screen, the pick-your-mermaid screen, the spacing rules, and the no-timers, no-lives rule.

Not done yet (yours to build, in the locked look): the reef map, Coral Reef dive, treasure chest and grotto screens, the game logic, voice and sound, saved progress, and a parent screen.

## Hard rules

- No timers, no lives, no penalties, no "wrong" sounds or red crosses. A wrong tap fades that bubble and brings up a counting hint.
- Only the right answer ever glows.
- Orange (`#FF9A3D`) means "tap me" or "you got it" and nothing else. Sister colors appear only on the sisters.
- Nothing that moves crosses a face, a label or an answer bubble.
- Controls stay 24px from every edge of the 800x600 design space. Neighbours sit at least 16px apart, answer bubbles at least 26px.
- The prompt never shows the digit. It says and spells the word ("Find the number four!"), so the child has to recognise the numeral herself.
- Wrap all motion in `@media (prefers-reduced-motion: no-preference)`.
- New scenery and characters must go through the brush-stroke pass in `art-pipeline/` (or match it closely). Do not mix in flat vector art, stock icons or emoji.

## Suggested build (confirm with the parent first)

The design space is 800x600 (4:3, landscape), which scales cleanly to a tablet. The reference screens are DOM and CSS, so a plain web app is the shortest path: Vite and TypeScript, one scaled stage element, CSS animations, per-child progress in `localStorage`, installable as a PWA. No game engine is needed. The target device has not been confirmed; see `docs/open-questions.md`.

## Folder map

- `assets/`: final painted art, organised by scene, character, prop, UI and brand. `assets/legacy/` holds the older-style art still used by the screens that have not been repainted.
- `design/tokens.json` and `design/tokens.css`: palette, type, spacing and motion values.
- `reference/storyboard/`: the original storyboard source files, with `blob-map.json` mapping their image ids to files in `assets/`.
- `art-pipeline/`: the Python scripts that drew and painted everything, plus the vector sources.
