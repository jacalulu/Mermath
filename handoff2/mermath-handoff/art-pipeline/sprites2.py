"""Paint the scenery layers and small moving pieces for the Tide Pool style frame."""
import os
import numpy as np, cv2
from paint import paint
from sprites import bleed, rough, OUT, ART

def painted_alpha(a, radii=(9, 4), thresholds=(-1, 10), max_len=(8, 6)):
    """Silhouette rebuilt from brush strokes, so the edge of a layer is made of strokes like the rest of the painting."""
    pm = paint(cv2.merge([a, a, a]), radii=radii, thresholds=thresholds, max_len=max_len, jitter=0, edge=5.0, flow_deg=90, seed=11)[..., 0].astype(np.float32)
    return np.clip((pm - 70) * 255.0 / 100.0, 0, 255).astype(np.uint8)

def layer(name, out, radii, thresholds, max_len, crop=None, size=None, light=None, rough_amp=1.5, sat=1.1, q=90, stroke_edge=None):
    im = cv2.imread(os.path.join(OUT, name + '.png'), cv2.IMREAD_UNCHANGED)
    if crop: im = im[crop[1]:crop[3], crop[0]:crop[2]]
    bgr, a = np.ascontiguousarray(im[..., :3]), np.ascontiguousarray(im[..., 3])
    p = paint(bleed(bgr, a), radii=radii, thresholds=thresholds, max_len=max_len, jitter=.03, edge=5.0, flow_deg=90, light=light, sat=sat)
    if stroke_edge: a = painted_alpha(a, *stroke_edge)
    elif rough_amp: a = rough(a, rough_amp, 12, 5)
    o = np.dstack([p, a])
    if size: o = cv2.resize(o, size, interpolation=cv2.INTER_AREA)
    o[o[..., 3] == 0, :3] = 0
    path = os.path.join(ART, out)
    cv2.imwrite(path, o, [cv2.IMWRITE_WEBP_QUALITY, q] if out.endswith('.webp') else [])
    print(out, o.shape[1], o.shape[0], os.path.getsize(path), flush=True)

if __name__ == '__main__':
    src = cv2.imread(os.path.join(OUT, 'L_bg.png'), cv2.IMREAD_COLOR)
    from paint import PRESETS
    cv2.imwrite(os.path.join(ART, 'tide_bg0.jpg'), paint(src, **PRESETS['tide_bg']), [cv2.IMWRITE_JPEG_QUALITY, 90])
    layer('L_kelp_far', 'tide_kelp_far.webp', (18, 9), (-1, 9), (9, 8), crop=(400, 0, 1520, 1200), rough_amp=0, sat=1.0)
    layer('L_kelp_mid', 'tide_kelp_mid.webp', (18, 9, 4), (-1, 10, 16), (9, 9, 6), stroke_edge=((9, 4), (-1, 10), (8, 6)))
    layer('L_kelp_left', 'tide_kelp_left.webp', (18, 9, 4), (-1, 10, 16), (9, 9, 6), crop=(0, 0, 480, 1200), stroke_edge=((9, 4), (-1, 10), (8, 6)))
    layer('frame_kelp_r', 'tide_kelp_right.webp', (18, 9, 4), (-1, 10, 16), (9, 9, 6), crop=(1160, 0, 1600, 1200), sat=1.12, stroke_edge=((9, 4), (-1, 10), (8, 6)))
    layer('L_fg', 'tide_fg.webp', (36, 18, 9, 4), (-1, 11, 17, 24), (9, 10, 9, 6), crop=(0, 700, 1600, 1200), light=(600, -1160), sat=1.12, stroke_edge=((9, 4), (-1, 10), (8, 6)))
    layer('L_grass', 'tide_grass.png', (10, 5, 3), (-1, 8, 12), (7, 7, 5), crop=(0, 960, 1600, 1164), stroke_edge=((5, 3), (-1, 8), (7, 5)))
    layer('star_pink', 'star_pink.png', (12, 6, 3), (-1, 6, 9), (6, 7, 5), size=(160, 160), sat=1.06)
    layer('star_orange', 'star_orange.png', (12, 6, 3), (-1, 6, 9), (6, 7, 5), size=(128, 128), sat=1.06)
    layer('sprite_bubble', 'sprite_bubble.png', (6, 3), (-1, 6), (5, 5), size=(96, 96), rough_amp=0.8, sat=1.0)
    layer('sprite_fish', 'sprite_fish.png', (10, 5, 3), (-1, 6, 9), (6, 6, 4), size=(88, 56), sat=1.06)
