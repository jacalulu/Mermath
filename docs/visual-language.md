# Visual language

Everything here is locked unless it says otherwise. Values are also in `design/tokens.json` and `design/tokens.css`.

## The look

A storybook painting you can play in. Scenery is repainted with visible, curved brush strokes. Characters are painted with finer strokes and keep a clean edge, so they read clearly on top. Faces (eyes, brows, mouth) are crisp vector layers laid over the painted bodies, so expressions never smudge.

Two references guided it: a luminous night scene with gold sparkles, and a teal underwater forest with orange fish.

What to avoid: flat vector illustration, glassy panels, outlined icons, drop-shadowed text, emoji.

## Color

### The painted world (used only inside the paintings)

| Name | Hex |
|---|---|
| Surface | `#D7F6F0` |
| Shallows | `#95DFDA` |
| Lagoon | `#4EB8BF` |
| Deep water | `#2494A2` |
| Kelp | `#105563` |
| Sand | `#EBD0A0` |

### Controls (everything she taps or reads)

| Name | Hex | Job |
|---|---|---|
| Midnight | `#061A33` | Text, numerals, quiet panels (panels at 76 to 80% opacity) |
| Pearl | `#FFF4DC` | Carries words: speech bubbles and name tags |
| Bubble | `#CFF5EE` (gradient `#F2FFFB` to `#9FE8DE`) | An answer. Always and only. |
| Goldfish | `#FF9A3D` (button gradient `#FFD27A` to `#FF9A3D`) | "Tap me" or "you got it" |

### The sisters (only ever on the sisters and their name-tag dots)

| Sister | Hex |
|---|---|
| Ophelia | `#FF7EB6` |
| Daphne | `#FFE14D` (lemon, kept clear of Goldfish orange) |
| Violet | `#A98BF5` |

### One job each

- Orange means "tap me" or "you got it". Do not use it for decoration.
- Pearl carries the words.
- A pale bubble is an answer.
- Midnight is for text and quiet panels.
- Sister colors stay on the sisters.

## Type

- **Baloo 2** for all interface text and all numerals. Weights 500, 600, 700. Font files are in `assets/fonts/` (SIL Open Font License).
- It was chosen from four candidates for its numeral shapes: closed 4, a 1 with a small flag, a 7 without a crossbar.
- Answer numerals: 700, 96px in a 140px bubble, Midnight.
- Prompt: 700, 29px. Name tags: 700, 26px. Bottom panels: 600, 24 to 25px. Buttons: 700, 22px.
- Baloo 2 sits low in its line box. The storyboard nudges it with a few pixels of top padding (see the reference HTML).
- The wordmark is artwork. Never set "Mermath" in a live font.

## Spacing (800x600 design space)

- Controls stay **24px** from every edge.
- Neighbours sit at least **16px** apart. Answer bubbles sit **26px** apart.
- Nothing that moves crosses a face, a label or an answer.
- Bottom panels (hint, solved) must not cover scenery that moves. In the Tide Pool the sea stars sit at the back of the sand for this reason.
- Answer bubbles are 140px. Suggested floor (not tested with the girls yet): about 120px, for a three year old's finger.

## Shapes

- Words live in Pearl pills and speech bubbles: fully rounded (radius 999px) or 30px for the speech bubble, with a soft Midnight shadow `0 6px 14px rgba(6,26,51,0.28)`.
- Answer bubbles are circles with a 3px white rim, the Bubble gradient placed as a highlight at the top left, and shadow `0 10px 22px rgba(6,26,51,0.3), inset 0 -10px 18px rgba(23,135,156,0.25)`.
- The right answer swaps to a gold gradient (`#FFF4DC` to `#FFD27A` to `#FF9A3D`) with a glow `0 0 44px rgba(255,210,122,0.95)`.
- Every scene gets a soft vignette: `radial-gradient(ellipse at 50% 45%, rgba(2,8,20,0) 55%, rgba(2,8,20,0.32) 100%)`.

## Icons

Icons are painted objects from the world, not line drawings.

| File | Meaning |
|---|---|
| `assets/ui/icon-shell.png` | A conch with sound lines: say it again |
| `assets/ui/icon-map.png` | A rolled map: back to the reef map |
| `assets/ui/pearl.png` | One pearl in the counter (empty slots are a 2px Pearl ring at 60%) |
| `assets/ui/padlock.png` | A gold padlock: this place is locked |

New icons should be drawn and painted the same way (see `docs/art-recipe.md`).

A dashed Pearl ring means "empty, something goes here": an unearned pearl, an unfilled answer slot, a grotto spot waiting for its item.

## Wordmark and app icon

The word math already has a plus in it: the t. So the t is an orange plus, and beside it the h rises into a mermaid tail, fading from navy ink through purple into a pink fin.

- `assets/brand/wordmark-navy.png`: for light and painted backgrounds.
- `assets/brand/wordmark-pearl.png`: for Midnight backgrounds.
- `assets/brand/layers/`: the same wordmark as separate layers for animation (letters, plus, tail body, tail fin). Stack them at the same size. Pivots are in `screens-and-motion.md`.
- `assets/brand/app-icon-1024.png`: square, full bleed. `app-icon-rounded-512.png` is a preview with rounded corners.

Rules:

- Capital M. The plus is always orange and always stands where the t goes.
- Keep clear space around it of at least the width of the plus.
- In design checks it stayed readable down to about 120px wide. Below that, use the app icon.
- On painted backgrounds add a soft white glow: `drop-shadow(0 0 12px rgba(255,255,255,0.55))`.
- Do not redraw it, recolor it, add an outline, or type it out. The lettering is Fraunces (weight 900, Soft 100, Wonk 1) with the t and the top of the h replaced by hand.

## Characters

- **The sisters.** Chibi mermaids, each built from separately painted pieces so they can move. Ophelia: long dark brown hair, brown eyes, pink tail. Daphne: red hair in pigtails with teal ties, blue eyes, lemon tail. Violet: red hair in buns, blue eyes, purple tail. All three wear a yellow star in their hair.
- **The crab.** The guide in Tide Pool. Orange, friendly, waves, blinks. He is the one who speaks the prompt.
- **The starfish lamp.** The first grotto reward. It has a face, so it is two layers: the painted star and a crisp face on top.
