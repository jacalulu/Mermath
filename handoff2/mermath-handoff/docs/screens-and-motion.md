# Screens and motion

All coordinates are in the 800x600 design space, measured from the top left. The working examples are in `reference/html/`. If this document and those pages ever disagree, the pages win.

Every character and the wordmark are **stacks of same-sized images**. Each piece is a full-frame transparent image, so you place every piece at the same position and size and only set a pivot (`transform-origin`, given as a percentage of that frame). No per-piece offsets are needed.

All motion sits inside `@media (prefers-reduced-motion: no-preference)`. With reduced motion on, everything simply holds still.

## Screen 1: Pick your mermaid (locked)

Reference: `reference/html/pick-your-mermaid.html`, `reference/screens/01-pick-your-mermaid.jpg`.

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

## Screen 3: Tide Pool dive

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

## Screen 2: Reef map

Reference: `reference/html/reef-map.html`. Layers: `assets/scenes/reef-map/layers.json`.

One seabed steps down from the bright shallows on the left to the dark deep on the right, with a place on each step. The whole seabed, with its three places, is one static painted layer (`seabed.webp`).

| Element | Where | Motion |
|---|---|---|
| Far kelp, mid kelp, seagrass | from `layers.json` | sway as on the other screens |
| Fish x2 | high, tops 86 and 104, starting off screen right | swim left, 32s and 36s. They pass under the title and above the mermaid's head. |
| Tide Pool (tappable area 256x252 at 14, 208) | the crab, 104x88, stands on the rock at 10, 216 | crab bobs 3px, waves, blinks. A soft Pearl glow pulses on the place (opacity .25 to .8, 1.6s). |
| Coral Reef (tappable area 262x436 at 306, 90) | the chosen mermaid, 158x181, floats at 358, 90 | she floats, waves, swishes; the same glow pulses half a beat later |
| Deep Sea (not tappable, 200x200 at 600, 380) | `ui/padlock.png`, 52x67, at 678, 408 | none. No glow. |
| Pearl trail | four 11px Pearl dots between each pair of places | the open stretch twinkles in sequence (2s, 0.25s apart); the locked stretch sits still at 40% |
| Place labels | two-line Pearl pills: name 700 24px, what you do there 500 15px in `#17617A`. Tops at 400, 468 and 516. | Deep Sea's label is a Midnight panel at 80% instead of Pearl, because it is locked. |
| Title and switch | "Where shall we dive?" centered at top 24; "Switch mermaid" Pearl pill at 24, 24 | none |

The mermaid shown is whichever sister was picked. In the storyboard it is Ophelia.

## Screen 4: Coral Reef dive

Reference: `reference/html/coral-reef-question.html`, `coral-reef-hint.html`, `coral-reef-solved.html`. Layers: `assets/scenes/coral-reef/layers.json`.

It is the Tide Pool layout with a different scene and a sum in the speech bubble. Same crab, same position (15, 204), same map button, pearl counter, answer bubbles (140px, 26px apart, at 288, 240) and bottom panel.

| Element | Where | Motion |
|---|---|---|
| Coral fans | `fan-left.webp`, `fan-right.webp`, from `layers.json` | skewX about their base: left -2.2 to 1.8deg, 4.6s; right 1.9 to -2deg, 5.2s. The right fan is kept short so it never reaches the answers. |
| Fish x3 | low, tops 438 to 456 | swim left behind the rocks, 30 to 34s, staggered |
| Sea stars | 404, 458, 58px and 512, 470, 46px | rock and hop, clear of the bottom panel |
| Speech bubble | Pearl, at 196, 88 | pops on replay |
| The sum | inside the bubble: shell button, then `3 + 2 =` in Baloo 2 700, 60px, with painted shells above each number (46x37, three `props/shell-orange.png`, two `props/shell-teal.png`) | none |
| Answer slot | a 60px circle with a 3px dashed Midnight ring after the equals sign | when solved it becomes a small gold bubble showing 5 |

States:

- **Wrong tap.** That bubble fades to 45%. The panel reads "Count all the shells: 1, 2, 3 and then 4, 5", with "1, 2, 3" in soft orange and "4, 5" in soft teal to match the shells.
- **Right tap.** The 5 turns gold, the slot fills, the tenth pearl fills, and the panel reads "3 and 2 make 5! That makes 10 pearls." with "Open the chest".

The shells are meant to fade out as she gets faster. That rule is not designed yet (see `open-questions.md`).

## Screen 5: Treasure chest

Reference: `reference/html/treasure-chest.html`. Layers: `assets/scenes/treasure-chest/layers.json`. The side kelp is shared with the home scene (`scenes/home/kelp-left.webp` at 0, 0, 260x600 and `kelp-right.webp` at 540, 0, 260x600).

| Element | Where | Motion |
|---|---|---|
| Warm glow | a 320x300 radial gold glow behind the chest at 240, 190 | pulses, opacity .45 to 1, 1.8s |
| Chest | `chest-lid.png` behind, `chest-box.png` in front, from `layers.json` | none |
| The new item | `starfish-lamp.png` with `starfish-lamp-face.png` on top, in one wrapper at 334, 98 with its own small glow | floats up 10px and tilts -5 to 5deg, 3.4s |
| Twinkles x5 | small four-point Pearl stars around the chest and lamp | fade and turn, 2 to 2.8s, staggered |
| The mermaid | 230x264 at 22, 190 | as on the pick screen, waving a little faster (1.1s) |
| Title | "10 pearls! The chest is open." Pearl pill, 700 26px, centered at top 26 | none |
| Bottom panel | "You earned a starfish lamp!" and the orange "Put it in my grotto" button | none |

There is no pearl counter here; the title says it.

## Screen 6: My grotto

Reference: `reference/html/grotto.html`. Layers: `assets/scenes/grotto/layers.json`. Light comes from the cave mouth at the top centre, not the upper left.

| Element | Where | Motion |
|---|---|---|
| Floor and walls | from `layers.json` | none |
| Kelp curtain | `kelp-curtain.webp` | skewX -2.4 to 2.2deg, 4.2s, pivot at its top (50% 0%) |
| String lights | `string-lights.png` | twinkle, opacity .72 to 1, 1.7s |
| Starfish lamp | hangs on a 2.5px cord from the top centre; lamp, face and glow share one 180x240 wrapper at 310, 0 | the wrapper swings -3.5 to 3.5deg, 3.2s, pivot at the top centre |
| Shell bed | `shell-bed.png` | none |
| The mermaid | 226x259 at 118, 226 | as on the pick screen |
| Empty slots | 92px circles with a 3px dashed Pearl ring on a Midnight wash at 46%: "Next dive", "2 more dives", "3 more dives" | none |
| Tags | orange "New! Starfish lamp" under the lamp; small Pearl pills "Kelp curtain" and "Shell bed" | none |
| Title and button | "My grotto" Pearl pill at 24, 24; orange "Dive again" at the top right | none |

A dashed Pearl ring always means "empty, something goes here", the same as an empty pearl in the counter.
