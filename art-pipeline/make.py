"""One command per scene: draw the layers, rasterize at 2x, paint each with the locked brushwork, crop to content, and record where each layer sits.
Usage: python3 make.py <scene> [layer ...]     (scenes are registered in scenes_v2.SCENES2; run with no arguments to list them)
Writes <scene>_<layer>.jpg|webp|png into ART and updates ART/manifest.json (positions in the 800x600 design space)."""
import os, sys, json
import numpy as np, cv2
import render
from paint import paint, PRESETS
from sprites import bleed, rough, OUT, ART
from sprites2 import painted_alpha

E = ((9, 4), (-1, 10), (8, 6))
KIND = {  # brush sizes per kind of layer: backgrounds broadest, grass finest
    'far':   dict(radii=(18, 9), thresholds=(-1, 9), max_len=(9, 8), sat=1.0, edge=None, ext='webp'),
    'mid':   dict(radii=(18, 9, 4), thresholds=(-1, 10, 16), max_len=(9, 9, 6), sat=1.1, edge=E, ext='webp'),
    'fg':    dict(radii=(36, 18, 9, 4), thresholds=(-1, 11, 17, 24), max_len=(9, 10, 9, 6), sat=1.12, edge=E, ext='webp', lit=True),
    'grass': dict(radii=(10, 5, 3), thresholds=(-1, 8, 12), max_len=(7, 7, 5), sat=1.1, edge=((5, 3), (-1, 8), (7, 5)), ext='png'),
    'prop':  dict(radii=(12, 6, 3), thresholds=(-1, 6, 9), max_len=(6, 7, 5), sat=1.06, edge=None, ext='png', rough=1.2),
    'vector': None,  # crisp details such as faces: cropped and saved, never painted
    'piece': dict(radii=(32, 16, 8, 4), thresholds=(-1, 8, 12, 16), max_len=(6, 8, 8, 5), sat=1.06, edge=None, ext='png', rough=2.2),
}
SC = 2

def manifest():
    p = os.path.join(ART, 'manifest.json'); return json.load(open(p)) if os.path.exists(p) else {}

def make(scene, only=()):
    import scenes_v2
    fn, kinds = scenes_v2.SCENES2[scene]
    svgs = fn(); man = manifest(); man.setdefault(scene, {})
    for name, kind in kinds.items():
        if only and name not in only: continue
        raw = f'{scene}_{name}_src'; open(os.path.join(OUT, raw + '.svg'), 'w').write(svgs[name]); render.main([f'{raw}:{SC}:1'])
        if kind == 'bg':
            src = cv2.imread(os.path.join(OUT, raw + '.png'), cv2.IMREAD_COLOR); out = f'{scene}_bg.jpg'
            cv2.imwrite(os.path.join(ART, out), paint(src, **PRESETS['tide_bg']), [cv2.IMWRITE_JPEG_QUALITY, 90]); man[scene][name] = dict(file=out, x=0, y=0, w=800, h=600); print(out, flush=True); continue
        k = KIND[kind] or dict(ext='png'); im = cv2.imread(os.path.join(OUT, raw + '.png'), cv2.IMREAD_UNCHANGED)
        ys, xs = np.nonzero(im[..., 3] > 8); pad = 12
        x0, y0 = max(0, (xs.min() - pad) // 4 * 4), max(0, (ys.min() - pad) // 4 * 4); x1, y1 = min(im.shape[1], -(-(xs.max() + pad) // 4) * 4), min(im.shape[0], -(-(ys.max() + pad) // 4) * 4)
        im = im[y0:y1, x0:x1]; bgr, a = np.ascontiguousarray(im[..., :3]), np.ascontiguousarray(im[..., 3])
        light = (600 - x0, -460 - y0) if k.get('lit') else None
        p = bleed(bgr, a) if kind == 'vector' else paint(bleed(bgr, a), radii=k['radii'], thresholds=k['thresholds'], max_len=k['max_len'], jitter=.03, edge=5.0, flow_deg=90, light=light, sat=k['sat'])
        a = painted_alpha(a, *k['edge']) if k.get('edge') else rough(a, k['rough'], 12, 5) if k.get('rough') else a
        o = np.dstack([p, a]); o[o[..., 3] == 0, :3] = 0; out = f'{scene}_{name}.{k["ext"]}'
        cv2.imwrite(os.path.join(ART, out), o, [cv2.IMWRITE_WEBP_QUALITY, 90] if out.endswith('.webp') else [])
        man[scene][name] = dict(file=out, x=x0 / SC, y=y0 / SC, w=(x1 - x0) / SC, h=(y1 - y0) / SC); print(out, man[scene][name], os.path.getsize(os.path.join(ART, out)) // 1024, 'KB', flush=True)
    json.dump(man, open(os.path.join(ART, 'manifest.json'), 'w'), indent=1)

if __name__ == '__main__':
    import scenes_v2
    if len(sys.argv) < 2: print('scenes:', ', '.join(scenes_v2.SCENES2)); sys.exit(0)
    make(sys.argv[1], sys.argv[2:])
