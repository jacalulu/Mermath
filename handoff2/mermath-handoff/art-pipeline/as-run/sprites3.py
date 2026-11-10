"""Paint the pick-your-mermaid scene layers and the three sisters' pieces."""
import os, sys
import numpy as np, cv2
from paint import paint, PRESETS
from sprites import sprite, OUT, ART
from sprites2 import layer
E = ((9, 4), (-1, 10), (8, 6))
if 'scene' in sys.argv:
    src = cv2.imread(os.path.join(OUT, 'H_bg.png'), cv2.IMREAD_COLOR)
    cv2.imwrite(os.path.join(ART, 'home_bg0.jpg'), paint(src, **PRESETS['tide_bg']), [cv2.IMWRITE_JPEG_QUALITY, 90])
    layer('H_kelp_far', 'home_kelp_far.webp', (18, 9), (-1, 9), (9, 8), crop=(200, 0, 1500, 1200), rough_amp=0, sat=1.0)
    layer('H_kelp_mid', 'home_kelp_mid.webp', (18, 9, 4), (-1, 10, 16), (9, 9, 6), stroke_edge=E)
    layer('H_kelp_left', 'home_kelp_left.webp', (18, 9, 4), (-1, 10, 16), (9, 9, 6), crop=(0, 0, 520, 1200), stroke_edge=E)
    layer('H_kelp_right', 'home_kelp_right.webp', (18, 9, 4), (-1, 10, 16), (9, 9, 6), crop=(1080, 0, 1600, 1200), sat=1.12, stroke_edge=E)
    layer('H_fg', 'home_fg.webp', (36, 18, 9, 4), (-1, 11, 17, 24), (9, 10, 9, 6), crop=(0, 880, 1600, 1200), light=(600, -1340), sat=1.12, stroke_edge=E)
    layer('H_grass', 'home_grass.png', (10, 5, 3), (-1, 8, 12), (7, 7, 5), crop=(0, 1010, 1600, 1190), stroke_edge=((5, 3), (-1, 8), (7, 5)))
if 'sisters' in sys.argv:
    for who in ('ophelia', 'daphne', 'violet'):
        for part in ('hair', 'fluke', 'tail', 'arm', 'body'):
            sprite(f'm_{who}_{part}', f'm_{who}_{part}.png', (528, 606))
        for part in ('eyes', 'shut'):
            sprite(f'm_{who}_{part}', f'm_{who}_{part}.png', (528, 606), paint_it=False)
