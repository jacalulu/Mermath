"""Paint separate pieces (with transparency) using finer strokes than the scenery, keep a clean silhouette, and save them for the storyboard."""
import os
import numpy as np, cv2
from scipy import ndimage
from paint import paint

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'out')
ART = '/home/claude/mermaid-art'

def bleed(bgr, alpha):
    idx = ndimage.distance_transform_edt(alpha <= 8, return_distances=False, return_indices=True)
    return np.ascontiguousarray(bgr[idx[0], idx[1]])

def rough(alpha, amp, scale, seed):
    h, w = alpha.shape; rng = np.random.default_rng(seed)
    nx = cv2.GaussianBlur(rng.normal(0, 1, (h, w)).astype(np.float32), (0, 0), scale); ny = cv2.GaussianBlur(rng.normal(0, 1, (h, w)).astype(np.float32), (0, 0), scale)
    nx *= amp / (nx.std() + 1e-6); ny *= amp / (ny.std() + 1e-6)
    xs, ys = np.meshgrid(np.arange(w, dtype=np.float32), np.arange(h, dtype=np.float32))
    return cv2.remap(alpha, xs + nx, ys + ny, cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE)

def sprite(name, out, size=None, radii=(32, 16, 8, 4), thresholds=(-1, 8, 12, 16), max_len=(6, 8, 8, 5), amp=2.2, paint_it=True, crop=None, sat=1.06):
    im = cv2.imread(os.path.join(OUT, name + '.png'), cv2.IMREAD_UNCHANGED)
    if crop: im = im[crop[1]:crop[3], crop[0]:crop[2]]
    bgr, a = np.ascontiguousarray(im[..., :3]), np.ascontiguousarray(im[..., 3])
    if paint_it:
        p = paint(bleed(bgr, a), radii=radii, thresholds=thresholds, max_len=max_len, jitter=.022, edge=4.0, flow_deg=90, sat=sat)
        a = rough(a, amp, 12, 5)
    else:
        p = bleed(bgr, a)
    o = np.dstack([p, a])
    if size: o = cv2.resize(o, size, interpolation=cv2.INTER_AREA)
    o[o[..., 3] == 0, :3] = 0
    cv2.imwrite(os.path.join(ART, out), o)
    print(out, o.shape, os.path.getsize(os.path.join(ART, out)), flush=True)

if __name__ == '__main__':
    for part in ('crab_legs', 'crab_arm_l', 'crab_arm_r', 'crab_body'):
        sprite(part, part + '.png', (500, 422))
    for part in ('crab_eyes', 'crab_eyes_shut'):
        sprite(part, part + '.png', (500, 422), paint_it=False)
    sprite('frame_kelp_r', 'kelp_r.png', None, radii=(18, 9, 4), thresholds=(-1, 10, 16), max_len=(9, 9, 6), amp=1.5, crop=(1160, 0, 1600, 1200), sat=1.12)
    sprite('icon_shell', 'icon_shell.png', (150, 128), radii=(12, 6, 3), thresholds=(-1, 6, 8), max_len=(6, 7, 5), amp=1.6)
    sprite('icon_map', 'icon_map.png', (128, 128), radii=(12, 6, 3), thresholds=(-1, 6, 8), max_len=(6, 7, 5), amp=1.6)
    sprite('icon_pearl', 'icon_pearl.png', (64, 64), radii=(10, 5, 3), thresholds=(-1, 6, 9), max_len=(5, 6, 4), amp=1.0)
