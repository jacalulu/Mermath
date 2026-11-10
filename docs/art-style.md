# Mermath art style sheet

Every picture in the game shares one look: a bright storybook gouache painting.
The two locked scenes (home / pick-your-mermaid and the Tide Pool) define it;
everything else is generated to match through `art-pipeline/`. This file is the
contract for any new piece.

## The look, in rules

1. **One brushwork.** Everything goes through the stroke pass in
   `art-pipeline/paint.py` (Hertzmann-style curved strokes, four sizes from
   ~36px washes down to 4px detail at 2x). Nothing ships flat: no vector
   fills, no stock icons, no emoji, no AI-photo texture.
2. **Light has a place.** Each scene has one light source and the strokes flow
   away from it (`light=` in the paint presets). Scenes lit from the sky get
   god-rays from that same point; the chest room is lit by the chest itself.
3. **Depth is painted, not blurred live.** Far layers render with baked blur
   and cooler, desaturated color; near silhouettes go nearly to Midnight with
   a thin `#7FE9E0` rim light along their top edge.
4. **Finish pass on every background:** soft mottle + diagonal streaks
   (soft-light), fine grain (overlay), vignette. This is what makes separate
   images feel like pages of one book.
5. **Edges are alive.** Sprites get their alpha roughened (`rough()` in
   `sprites.py`), so cutouts look hand-painted, never die-cut.
6. **Color rules from `docs/visual-language.md` still apply inside art:**
   orange `#FF9A3D` only for "tap me / you got it" (and the goldfish, who were
   grandfathered in), sister colors only on the sisters, gold `#FFD27A`
   reserved for rewards (chest light, lamp glow, Deep Sea lock).

## Scene palettes (water gradients, top to bottom)

| Scene | Water | Light from | Mood |
|---|---|---|---|
| Home | `#93EADF → #051C38` | top right | bright morning |
| Tide Pool | `#DAFCF0 → #136181` | surface, top center | sunlit shallows |
| Reef map | `#9FF1E3 → #050C22` (diagonal) | top left | the whole sea at once |
| Coral Reef | `#86E6DE → #0A1A40` | top right | deeper, corals glow |
| Chest | `#040A1E → #1D5578` | **the chest** (gold) | dark water, warm reveal |
| Grotto | radial `#7FE6DA → #061C3A` | shaft from above | cosy cave, string lights |

## How every piece is made

```
cd art-pipeline
.venv/bin/python scenes.py <names>        # compose the SVG (scenes.py = the scene language)
.venv/bin/python render.py <name>:2:0 ... # raster at 2x via headless Chrome (:2:1 = keep alpha)
.venv/bin/python scenes4.py               # stroke pass: backgrounds + item sprites
```

- Backgrounds render at 1600x1200 for the 800x600 design space and ship as JPG.
- Sprites (characters, props, grotto items) are cropped from the 2x canvas,
  painted with finer strokes (12-16px tops), alpha-roughened, and ship as PNG.
  The crop boxes are 2x the design-space frames the app stages them at — keep
  `scenes4.py` and the screen files in sync.
- Grotto items are composed **in place** in `scene_grotto` and exported as
  separate transparent sprites (`item_lamp`, `item_curtain`, `item_shellbed`),
  so the app can add each one only when it is earned and the labels always
  line up.
- The earlier flat-style art lives in `assets/legacy/` for reference only;
  no screen uses it anymore.

## Adding a new piece (checklist)

- [ ] Compose it in `scenes.py`'s vocabulary (water, rays, kelp, rock, coral,
      grass, particles, finish) or as pieces in the character scripts.
- [ ] Pick the light source first; pass it to the paint preset.
- [ ] Render at 2x; paint with the preset family that matches its distance
      (background / layer / sprite — see `sprites3.py` and `scenes4.py`).
- [ ] Check it next to `reference/screens/tide-pool-question-LOCKED.jpg`:
      same stroke weight, same finish, same storybook warmth.
- [ ] Copy into `assets/`, run `tools/sync-art.sh`, rebuild.
