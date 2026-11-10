# Screens and motion

All coordinates are in the 800x600 design space, measured from the top left. The working examples are in `reference/html/`. If this document and those pages ever disagree, the pages win.

Every character and the wordmark are **stacks of same-sized images**. Each piece is a full-frame transparent image, so you place every piece at the same position and size and only set a pivot (`transform-origin`, given as a percentage of that frame). No per-piece offsets are needed.

All motion sits inside `@media (prefers-reduced-motion: no-preference)`. With reduced motion on, everything simply holds still.

## Screen 1: Pick your mermaid (locked)

Reference: `reference/html/pick-your-mermaid.html`, `reference/screens/01-pick-your-mermaid-LOCKED.jpg`.

### Layer order, back to front

| # | Layer | File (under `assets/`) | Position and size | Motion |
|---|---|---|---|---|
| 1 | Background | `scenes/home/bg.jpg` | 0, 0, 800x600 | none |
| 2 | Light shimmer | CSS radial gradient | 0, 0, 800x340 | opacity .05 to .45, 4.5s, alternate |
| 3 | Far kelp | `scenes/home/kelp-far.webp` | left 100, 650x600, opacity .75, blur 1px | skewX -0.8 to 0.9deg, 7s, pivot 50% 100% |
| 4 | Mid kelp | `scenes/home/kelp-mid.webp` | 0, 0, 800x600 | skewX 1.3 to -1.4deg, 6s, pivot 50% 100% |
| 5 | Fish x5 | `props/fish.png` | start off screen at left 830; tops 318, 352, 392, 334, 374; widths 44, 34, 28, 40, 30 | swim left 940px with a slight bob, 30 to 40s, linear, staggered |
| 6 | Left kelp | `scenes/home/kelp-left.webp` | 0, 0, 260x600 | skewX -1.7 to 1.3deg, 5s, pivot 0% 100% |
| 7 | Right kelp | `scenes/home/kelp-right.webp` | left 540, 260x600 | skewX 1.5 to -1.4deg, 5.6s, pivot 100% 100% |
| 8 | Foreground rocks and sand | `scenes/home/foreground.webp` | top 440, 800x160 | none |
| 9 | Seagrass | `scenes/home/seagrass.png` | top 505, 800x90 | skewX -7 to 7deg, 2.8s, pivot 50% 100% |
| 10 | Sea stars | `props/sea-star-pink.png`, `sea-star-orange.png` | 392, 530, 80px and 560, 548, 64px | pink rocks -10 to 10deg, 2.2s; orange hops every 5s |
| 11 | Rising bubbles x3 | `props/bubble.png` | start at the bottom, 30, 24 and 20px | rise 640px and fade, 9, 12 and 15s |
| 12 | The three sisters | see below | left 38, 278, 518; top 156; each 242x278 | see below |
| 13 | Vignette | CSS radial gradient | full frame | none |
| 14 | Wordmark | `brand/layers/*` | left 248, top 18, 304x102 | see below |
| 15 | Prompt pill | text | centered, top 134 | none |

Each sister is a link to the map. Her name tag sits 282px below the top of her frame, centered on x = 117 within it.

### A sister (frame 242x278, source images 528x606)

Stack in this order. Everything inside a "floating" wrapper that bobs.

| Order | Piece | Pivot | Motion |
|---|---|---|---|
| wrapper | whole mermaid | | translateY 0 to -7px, 3.3 to 4.2s, ease in out |
| 1 | `hair.png` | 48.5% 35.9% | Ophelia: rotate -1.6 to 1.8deg, 3s. Twins: -1 to 1deg, 2.6s |
| 1b | Daphne only: `pigtail-left.png`, `pigtail-right.png` | 34.3% 28.6% and 62.8% 28.6% | rotate 5 to -6deg, 2.1s and 6 to -5deg, 2.3s |
| 2 | tail group: `fluke.png` then `tail.png` | group 48.5% 61.5% | group rotates -2.5 to 2.5deg, 2.2 to 2.8s |
| 2a | `fluke.png` inside the group | 72.5% 84.6% | rotate -10 to 9deg, 1.1 to 1.4s |
| 3 | `arm.png` (the waving arm) | 42.1% 51.8% | rotate -7 to 11deg, 1.5 to 1.9s |
| 4 | `body.png` | | none |
| 5 | `eyes-open.png` and `eyes-shut.png` | | blink: shut shows for the last few percent of a 3.9 to 5.3s cycle |

Give each sister slightly different durations and start offsets so they never move in step. The exact values are in the reference page.

### The wordmark (frame 304x102 here, source 1979x665)

| Order | Piece | Pivot | Motion |
|---|---|---|---|
| 1 | `layers/letters-navy.png` | | none |
| 2 | `layers/plus.png` | 79.9% 80% | scale 1 to 1.08 and back, 2.4s |
| 3 | tail group: `layers/tail-fin.png` then `layers/tail-body-navy.png` | group 89.7% 64.4% | rotate -1.6 to 2deg, 2.6s |
| 3a | `layers/tail-fin.png` inside the group | 94% 27.7% | rotate -8 to 5deg, 1.3s |

On Midnight backgrounds swap in `letters-pearl.png` and `tail-body-pearl.png`.

## Screen 3: Tide Pool question (locked style frame)

Reference: `reference/html/tide-pool-question.html`, `tide-pool-hint.html`, `tide-pool-solved.html`.

### Layer order, back to front

| # | Layer | File (under `assets/`) | Position and size | Motion |
|---|---|---|---|---|
| 1 | Background | `scenes/tide-pool/bg.jpg` | 0, 0, 800x600 | none |
| 2 | Light shimmer | CSS radial gradient | 0, 0, 800x340 | opacity .05 to .45, 4.5s |
| 3 | Far kelp | `scenes/tide-pool/kelp-far.webp` | left 200, 560x600, opacity .75, blur 1px | skewX -0.8 to 0.9deg, 7s |
| 4 | Mid kelp | `scenes/tide-pool/kelp-mid.webp` | 0, 0, 800x600 | skewX 1.3 to -1.4deg, 6s |
| 5 | Fish x2 | `props/fish.png` | start at left 820 and 856; tops 430 and 448 | swim left 920px, 30s, the second 2.5s behind. They pass low, behind the rocks. |
| 6 | Left kelp | `scenes/tide-pool/kelp-left.webp` | 0, 0, 240x600 | skewX -1.7 to 1.3deg, 5s, pivot 0% 100% |
| 7 | Foreground rocks and sand | `scenes/tide-pool/foreground.webp` | top 350, 800x250 | none |
| 8 | Seagrass | `scenes/tide-pool/seagrass.png` | top 480, 800x102 | skewX -7 to 7deg, 2.8s |
| 9 | Sea stars | `props/sea-star-pink.png`, `sea-star-orange.png` | 392, 452, 66px and 498, 468, 52px | rock and hop, as above |
| 10 | Rising bubbles x3 | `props/bubble.png` | lefts 258, 766, 46 | as above |
| 11 | The crab | see below | left 15, top 204, 250x211 | see below. The whole crab is a button: tap to hear the prompt again. |
| 12 | Right kelp | `scenes/tide-pool/kelp-right.webp` | left 580, 220x600 | rotate -1.4 to 1.6deg, 5.5s, pivot 100% 100% |
| 13 | Vignette | CSS radial gradient | full frame | none |
| 14 | Map button | `ui/icon-map.png` | left 22, top 20, 66x66 | none |
| 15 | Pearl counter | `ui/pearl.png` x filled, rings for empty | right 24, top 26; 22px pearls, 6px apart, on a Midnight pill at 76% | fills one per right answer |
| 16 | Speech bubble | Pearl, radius 30, with `ui/icon-shell.png` (82x70) and the prompt | left 196, top 96; a small tail points to the crab | pops (scale 1 to 1.06, 0.5s) each time the prompt is replayed |
| 17 | Answer bubbles x3 | CSS | left 288, top 230; 140px each, 26px apart | none. Nothing fast crosses them. |
| 18 | Bottom panel | hint or solved | centered, 24px from the bottom | appears on a wrong tap, or on the tenth pearl |

### The crab (frame 250x211, source images 500x422)

| Order | Piece | Pivot | Motion |
|---|---|---|---|
| 1 | `legs.png` | | none (stays planted) |
| wrapper | everything below bobs together | | translateY 0 to -5px, 3.2s |
| 2 | `arm-left.png` | 31.6% 61.1% | rotate 4 to -5deg, 2.6s |
| 3 | `arm-right.png` (the waving claw) | 68.4% 61.1% | rotate -9 to 10deg, 1.5s |
| 4 | `body.png` | | none |
| 5 | `eyes-open.png` and `eyes-shut.png` | | blink on a 4.4s cycle |

### States and behaviour

The storyboard component (`reference/storyboard/StyleFrame.dc.html`, the `renderVals` function) holds the logic in a few lines:

- **Question.** 9 of 10 pearls filled in the example. Three bubbles: 2, 4, 7. Target is 4.
- **Wrong tap.** That bubble drops to 45% opacity and stays there. The hint panel appears: "Count with me" and four orange 26px dots. She can tap again.
- **Right tap.** The 4 turns gold and glows, the tenth pearl fills, and the panel changes to "You found four! That makes 10 pearls." with the "Open the chest" button.
- **Replay.** Tapping the crab or the shell replays the spoken prompt and pops the speech bubble.

## Screens 2, 4, 5, 6: not rebuilt yet

`reference/screens/*-old-style.jpg` and the matching files in `reference/storyboard/` show the content, the copy and a rough layout for the reef map, the Coral Reef dive, the treasure chest and the grotto. They use an earlier look (serif headings, glassy panels, single flat backgrounds, one-piece characters). Keep what is on them. Rebuild how they look to match the two locked screens: layered painted scenery that moves, Baloo 2, Pearl pills, painted icons, the spacing rules.

Their backgrounds and one-piece characters are in `assets/legacy/` so the old screens can be shown as they are until replaced. The countable shells for Coral Reef (`shell-orange.png`, `shell-teal.png`) are also there and need a painted version.
