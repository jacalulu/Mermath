# Art recipe: how to make anything new look like Mermath

Every picture in this game was drawn in code and then repainted with brush strokes by one script. That is the whole look. If you need a new scene, a new item or a new character, **do not improvise a new method**. Run this recipe. It takes under a minute per scene.

It has been run from a clean copy of this folder: the coral, chest, grotto, map and prop layers it produced were pixel-identical to the shipped files (29 of 29).

## What is not allowed

- Flat vector art, CSS-drawn scenery, emoji, stock icons, or art from an image model.
- A "painterly" CSS or canvas filter in place of the paint pass.
- Placing a layer by eye. Positions come from `manifest.json` (or the `layers.json` next to each shipped scene).
- Shipping a screen whose scenery did not come out of `make.py`.

## Set up (once)

```bash
cd art-pipeline
pip install -r requirements.txt        # numpy, opencv-python-headless, scipy, pillow, playwright
playwright install chromium            # only needed if the machine has no Chrome
```

Nothing else to configure. Working files go to `art-pipeline/out/`, finished art to `art-pipeline/painted/`. Two optional environment variables: `MERMATH_ART` (a different output folder) and `MERMATH_CHROME` (a specific Chrome binary, or `bundled` to force Playwright's Chromium).

## The three commands

```bash
python3 make.py                 # lists the scenes: home, coral, chest, grotto, map, props
python3 make.py coral           # draws, rasterizes, paints and crops every layer of one scene
python3 compose.py coral        # flattens the layers into painted/coral_check.png so you can LOOK at it
python3 make_pieces.py daphne   # a character as separate pieces (also: ophelia, violet, crab, icons, shells)
```

`make.py` writes one file per layer plus `painted/manifest.json`, which records where each layer sits in the 800x600 design space:

```json
"fan_right": { "file": "coral_fan_right.webp", "x": 718, "y": 372, "w": 82, "h": 162 }
```

## Making a new scene, step by step

1. **Plan the calm areas first.** Decide where the controls go (guide character on the left, answers centre right, a panel along the bottom). Keep scenery quiet behind them and put the bright, busy things in the bottom corners.
2. **Copy a scene function** in `scenes_v2.py`. `scene_coral_layers()` is the best template for a dive, `scene_grotto_layers()` for an interior. Give it its own seed (the first number passed to `LS`).
3. **Draw back to front, switching layers as you go** with `s.layer('name')`:
   - `open_water(s)`: the locked water, surface ripples and light. Always first.
   - far kelp, blurred (`filter="url(#b3)"`, opacity about .6), on its own layer so it can sway
   - a blurred hill on `bg`, then `s.rays(RAYS, 1000, .5)`
   - things that sway in the middle distance, each on its own layer (wrap in `filter="url(#paintS)"`)
   - `fg`: `sand(...)`, `boulder(...)`, `coral(...)`, `mound(...)`, small shells and sea stars
   - `grass`: seagrass tufts, on their own layer
   - finish with `s.layer('bg'); s.finish(mott=.26, streak=.14, vig=0, grain=0)`
4. **Register it** in `SCENES2` at the bottom of `scenes_v2.py`, giving every layer a kind (table below).
5. **Run** `python3 make.py <name>` then `python3 compose.py <name>`.
6. **Open `painted/<name>_check.png` and look at it.** Compare it side by side with `reference/screens/`. If something looks smeared, too clean, too busy behind the answers, or cut off at an edge, change the drawing and run again.
7. **Copy the files** into `assets/scenes/<name>/` and write a `layers.json` from the manifest entries, back to front.
8. **Build the screen**: stack the layers at exactly those positions, add motion (see `screens-and-motion.md`), then the controls on top.

## Layer kinds

The kind decides the brush sizes, which is what keeps depth readable.

| Kind | Use it for | Brush radii | Saved as |
|---|---|---|---|
| `bg` | the full-frame background | 36, 18, 9, 4 | `.jpg` |
| `far` | pale, blurred distance (far kelp) | 18, 9 | `.webp` |
| `mid` | middle-distance things that sway (kelp, coral fans, a kelp curtain) | 18, 9, 4, with a painted edge | `.webp` |
| `fg` | sand, rocks, coral, cave walls | 36, 18, 9, 4, lit from the upper left, painted edge | `.webp` |
| `grass` | seagrass | 10, 5, 3 | `.png` |
| `piece` | large objects and character parts (the chest, the shell bed) | 32, 16, 8, 4, clean edge | `.png` |
| `prop` | small objects (padlock, lamp, string lights) | 12, 6, 3 | `.png` |
| `vector` | faces and other crisp details | not painted | `.png` |

If a new piece looks too smeared, move it to a finer kind. If it looks too clean next to the scenery, move it to a broader one.

## What keeps a new scene on-model

- **Water.** Use `open_water(s)`. It has two approved palettes: the default, and the slightly deeper one passed in the chest and map scenes.
- **Light.** From the upper left: `LS(seed, 300, -230, 1000)`. The grotto is the one exception (light from the cave mouth, `400, -260`).
- **Sand.** `SAND` for the back slope, `SAND2` for the front strip.
- **Kelp.** Far `#6fd0cd`, middle `#1f8f95`, near `#0f5560` with a pale rim `#bff7e6`.
- **Rocks.** `boulder(...)` with its default colors; darker values only for the Deep Sea.
- **No outlines.** Shapes are separated by light and color, never by a line.
- **Faces stay crisp.** Draw eyes and mouths on a separate `vector` layer (see `lamp(..., face=True)`).
- **Same randomness, same picture.** Each scene has its own seed, so rerunning gives the same painting. If you change one layer's drawing, rerun the whole scene, not just that layer, because later layers share the same random sequence.

## Characters and objects

- **A sister's hair or colors:** edit `SISTERS` in `mpuppet.py` (styles: `long`, `buns`, `pigtails`), then `python3 make_pieces.py <name>`.
- **A new character:** follow `mpuppet.parts()`: every moving part is its own full-frame piece, so the pieces stack with no offsets, and the face is two unpainted layers (eyes open, eyes shut).
- **A new grotto item or icon:** add it as a `prop` (small) or `piece` (large) layer. `scene_props_layers()` is the place for things that belong to no scene.

## Done means all of these

- [ ] Every piece of scenery and every character came from `make.py` or `make_pieces.py`.
- [ ] You opened the `_check.png` and compared it with the reference screens.
- [ ] Layers are placed from the manifest, not by eye.
- [ ] At least three things move, each wrapped in `@media (prefers-reduced-motion: no-preference)`.
- [ ] Nothing that moves crosses a face, a label or an answer.
- [ ] All text is Baloo 2. Words sit on Pearl. Quiet information sits on Midnight panels. Orange appears only on "tap me" and "you got it".
- [ ] Controls are 24px from every edge, neighbours 16px apart, answers 26px apart.
- [ ] A screenshot of the built screen sits comfortably next to `reference/screens/`.

## The files

| File | What it does |
|---|---|
| `make.py` | One command per scene: draw, rasterize, paint, crop, record positions |
| `make_pieces.py` | Characters, icons and shells as pieces |
| `compose.py` | Flattens a painted scene for checking |
| `scenes_v2.py` | The coral, chest, grotto, map and props scenes, and the scene registry |
| `frame.py` | The home scene (registered as `home`) and the original Tide Pool layers |
| `scenes.py`, `chars.py` | The drawing helpers: water, light, kelp, coral, rocks, sea stars, fish |
| `mpuppet.py`, `puppet.py` | The sisters and the crab as pieces; the icon drawings |
| `render.py` | SVG to PNG through headless Chrome |
| `paint.py` | The brush-stroke pass (after Hertzmann, "Painterly Rendering with Curved Brush Strokes of Multiple Sizes", 1998) |
| `sprites.py`, `sprites2.py` | Painting helpers used by the commands above |
| `as-run/` | Older scripts kept for reference only: the wordmark, the app icon, the storyboard preview, and the first home-scene and sister run. They contain paths from the design session and are not part of the recipe. |

One known difference: the shipped Tide Pool layers were made by an earlier run with hand-set crop boxes, so they are not regenerated by `make.py`. Their positions are in `assets/scenes/tide-pool/layers.json`. Use the coral scene as the template for new dives.
