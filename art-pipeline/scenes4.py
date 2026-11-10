"""Paint the four remaining scene backgrounds and the grotto item sprites.
Run scenes.py and render.py first (see the commands in the module docstring of
sprites3.py; everything renders at 2x, so coordinates below are 1600x1200).
Usage: scenes4.py [bgs] [items]"""
import os, sys
import cv2
from paint import paint
from sprites import sprite, OUT, ART

# The tide/home backgrounds used these stroke sizes; each scene keeps its own
# light so the stroke flow radiates from where the light actually comes from.
BASE = dict(radii=(36, 18, 9, 4), thresholds=(-1, 11, 17, 24), max_len=(9, 10, 9, 6), edge=5.0, sat=1.12)
BGS = {
    'bg_map': dict(BASE, light=(120, -180)),
    'bg_coral': dict(BASE, light=(1360, -160)),
    'bg_chest': dict(BASE, light=(800, 744), sat=1.05),   # lit by the chest itself
    'bg_grotto': dict(BASE, light=(800, -520)),
}

# Item sprites: finer strokes, clean silhouettes. Crops are 2x the design-space
# boxes the app stages them at (see the screen files).
ITEMS = [
    # name, out, crop (2x), paint kwargs
    ('item_lamp', 'item_lamp.png', (540, 96, 1060, 616),
     dict(radii=(12, 6, 3), thresholds=(-1, 6, 8), max_len=(6, 7, 5), amp=1.2)),
    ('item_curtain', 'item_curtain.png', (1160, 80, 1460, 920),
     dict(radii=(14, 7, 3), thresholds=(-1, 7, 10), max_len=(7, 8, 5), amp=1.8)),
    ('item_shellbed', 'item_shellbed.png', (760, 720, 1320, 1120),
     dict(radii=(16, 8, 4), thresholds=(-1, 8, 12), max_len=(7, 8, 6), amp=1.6)),
    ('shell_orange', 'shell_orange.png', (620, 420, 980, 740),
     dict(radii=(12, 6, 3), thresholds=(-1, 6, 8), max_len=(6, 7, 5), amp=1.6)),
    ('shell_teal', 'shell_teal.png', (620, 420, 980, 740),
     dict(radii=(12, 6, 3), thresholds=(-1, 6, 8), max_len=(6, 7, 5), amp=1.6)),
]

if __name__ == '__main__':
    args = sys.argv[1:] or ['bgs', 'items']
    if 'bgs' in args:
        for name, kw in BGS.items():
            src = cv2.imread(os.path.join(OUT, name + '.png'), cv2.IMREAD_COLOR)
            cv2.imwrite(os.path.join(ART, name + '.jpg'), paint(src, **kw), [cv2.IMWRITE_JPEG_QUALITY, 90])
            print(name, 'painted', flush=True)
    if 'items' in args:
        for name, out, crop, kw in ITEMS:
            sprite(name, out, None, crop=crop, **kw)
