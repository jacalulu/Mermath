"""Three wordmark routes, all built on one idea: a mermaid's tail fin that is part of a letter."""
import os, math
import numpy as np
from PIL import Image
from playwright.sync_api import sync_playwright
from wordmark import FR, FRI, STYLES, OUT

W, H, SC, SIZE, PAD = 1160, 470, 2, 220, (60, 190)
CSS = f"""@font-face{{font-family:'Fr';font-weight:100 900;font-style:normal;src:url(file://{FR})}}
html,body{{margin:0;background:transparent}} #box{{position:relative;width:{W}px;height:{H}px}}
#t{{position:absolute;left:{PAD[0]}px;top:{PAD[1]}px;font-size:{SIZE}px;line-height:1;white-space:nowrap;color:#000;{STYLES['upright']}}}"""

def shot(html, path, ids=()):
    hp = path.replace('.png', '.html'); open(hp, 'w').write(html)
    with sync_playwright() as pw:
        b = pw.chromium.launch(executable_path='/usr/bin/google-chrome', args=['--no-sandbox', '--allow-file-access-from-files'])
        pg = b.new_page(viewport={'width': W, 'height': H}, device_scale_factor=SC)
        pg.goto('file://' + hp); pg.evaluate("document.fonts.ready.then(()=>1)"); pg.wait_for_timeout(450)
        rects = {i: pg.evaluate(f"(()=>{{const r=document.getElementById('{i}').getBoundingClientRect();return [r.left,r.top,r.right,r.bottom]}})()") for i in ids}
        pg.locator('#box').screenshot(path=path, omit_background=True); b.close()
    return rects

def text_page(inner): return f'<html><head><style>{CSS}</style></head><body><div id="box"><div id="t">{inner}</div></div></body></html>'
def svg_page(body, defs=''): return f'<html><body style="margin:0;background:transparent"><div id="box" style="width:{W}px;height:{H}px"><svg width="{W}" height="{H}" viewBox="0 0 {W} {H}"><defs>{defs}</defs>{body}</svg></div></body></html>'

def runs(row):
    xs = np.nonzero(row)[0]; out = []
    if len(xs) == 0: return out
    s = p = xs[0]
    for v in xs[1:]:
        if v != p + 1: out.append((s, p + 1)); s = v
        p = v
    out.append((s, p + 1)); return out

LOBES = [(-8, 0), (-24, -4), (-48, -8), (-70, -19), (-57, -36), (-33, -47), (-15, -43), (-8, -41), (-2, -32), (0, -23), (2, -32), (8, -41), (15, -43), (33, -47), (57, -36), (70, -19), (48, -8), (24, -4), (8, 0)]

def tail(xa, xb, yc, fill, s=1.0, tilt=0.0, bend=0.0, neck=46.0):
    """Tapered neck from the cut stem (xa..xb at yc) up to a fin; s scales the fin, tilt leans it, bend shifts the neck top sideways."""
    cx = (xa + xb) / 2; bx, by = cx + bend, yc - neck * s
    c, sn = math.cos(math.radians(tilt)), math.sin(math.radians(tilt))
    P = [(bx + (x * c - y * sn) * s, by + (x * sn + y * c) * s) for x, y in LOBES]
    L, R = P[0], P[-1]
    f = lambda p: f'{p[0]:.1f} {p[1]:.1f}'
    d = f'M{xa:.1f} {yc+4:.1f} C{xa:.1f} {yc-neck*s*.38:.1f} {L[0]-3*s:.1f} {L[1]+neck*s*.45:.1f} {f(L)} '
    for i in range(1, len(P) - 1, 3): d += f'C{f(P[i])} {f(P[i+1])} {f(P[i+2])} '
    d += f'C{R[0]+3*s:.1f} {R[1]+neck*s*.45:.1f} {xb:.1f} {yc-neck*s*.38:.1f} {xb:.1f} {yc+4:.1f} Z'
    return f'<path d="{d}" fill="{fill}"/>'

def plus(x, y, a=14, t=9.6, col='#FF8A3D'): return f'<path d="M{x-a} {y} H{x+a} M{x} {y-a} V{y+a}" stroke="{col}" stroke-width="{t}" stroke-linecap="round"/>'

def ink(img):
    arr = np.array(img).astype(np.float32); al = arr[..., 3]
    black = (arr[..., 0] < 50) & (arr[..., 1] < 50) & (arr[..., 2] < 50)
    ys = np.nonzero(((al > 20) & black).any(axis=1))[0]
    t = np.clip((np.arange(arr.shape[0]) - ys[0]) / max(1, ys[-1] - ys[0]), 0, 1)[:, None, None]
    col = np.broadcast_to(np.array([18, 66, 98], np.float32) * (1 - t) + np.array([6, 26, 51], np.float32) * t, arr[..., :3].shape)
    arr[..., :3] = np.where(black[..., None], col, arr[..., :3])
    res = Image.fromarray(arr.astype(np.uint8)); bb = res.getbbox(); m = 20
    return res.crop((max(0, bb[0] - m), max(0, bb[1] - m), min(res.width, bb[2] + m), min(res.height, bb[3] + m)))

def stem_at(a, rect, dy, which=0):
    x0, x1 = int(rect[0] * SC), int(rect[2] * SC)
    ytop = int(np.argmax((a[:, x0:x1] > 128).any(axis=1))); yc = ytop + int(dy * SC)
    r = runs(a[yc, x0:x1] > 128)[which]
    return (x0 + r[0]) / SC, (x0 + r[1]) / SC, yc / SC, ytop / SC, x0, x1

def route_a():
    base = os.path.join(OUT, 'r_a_text.png'); r = shot(text_page('Mermat<span id="h">h</span>'), base, ['h'])
    im = np.array(Image.open(base)); xa, xb, yc, yt, x0, x1 = stem_at(im[..., 3], r['h'], 44)
    im[:int(yc * SC), x0 - 20:x1 + 20, 3] = 0
    body = tail(xa, xb, yc, '#000', s=1.04, tilt=-13, bend=9, neck=50) + plus((xa + xb) / 2 + 92, yc - 108, 13, 9)
    tp = os.path.join(OUT, 'r_a_tail.png'); shot(svg_page(body), tp)
    return ink(Image.alpha_composite(Image.fromarray(im), Image.open(tp)))

def route_b():
    base = os.path.join(OUT, 'r_b_text.png')
    r = shot(text_page('<span id="i1">I</span><span style="display:inline-block;width:64px"></span><span id="i2">I</span><span style="margin-left:-2px">ermath</span>'), base, ['i1', 'i2'])
    im = np.array(Image.open(base)); a = im[..., 3]
    def box(rect):
        x0, x1 = int(rect[0] * SC), int(rect[2] * SC); sub = a[:, x0:x1] > 128
        ys = np.nonzero(sub.any(axis=1))[0]; mid = (ys[0] + ys[-1]) // 2; rr = runs(sub[mid])[0]
        return (x0 + rr[0]) / SC, (x0 + rr[1]) / SC, ys[0] / SC, (ys[-1] + 1) / SC
    l0, l1, yT, yB = box(r['i1']); r0, r1, _, _ = box(r['i2'])
    xL, xR, cx, Hh = l1, r0, (l1 + r0) / 2, yB - yT
    o = 9
    d = (f'M{xL-o:.1f} {yT+1:.1f} C{xL+20:.1f} {yT+4:.1f} {cx-13:.1f} {yT+Hh*.25:.1f} {cx:.1f} {yT+Hh*.43:.1f} '
         f'C{cx+13:.1f} {yT+Hh*.25:.1f} {xR-20:.1f} {yT+4:.1f} {xR+o:.1f} {yT+1:.1f} L{xR+o:.1f} {yT+Hh*.30:.1f} '
         f'C{xR-12:.1f} {yT+Hh*.46:.1f} {cx+15:.1f} {yT+Hh*.66:.1f} {cx+9:.1f} {yB-Hh*.15:.1f} C{cx+10:.1f} {yB-Hh*.07:.1f} {cx+13:.1f} {yB-4:.1f} {cx+17:.1f} {yB:.1f} '
         f'L{cx-17:.1f} {yB:.1f} C{cx-13:.1f} {yB-4:.1f} {cx-10:.1f} {yB-Hh*.07:.1f} {cx-9:.1f} {yB-Hh*.15:.1f} '
         f'C{cx-15:.1f} {yT+Hh*.66:.1f} {xL+12:.1f} {yT+Hh*.46:.1f} {xL-o:.1f} {yT+Hh*.30:.1f} Z')
    defs = '<linearGradient id="fg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFB85A"/><stop offset="1" stop-color="#FF7F32"/></linearGradient>'
    tp = os.path.join(OUT, 'r_b_fin.png'); shot(svg_page(f'<path d="{d}" fill="url(#fg)"/>', defs), tp)
    return ink(Image.alpha_composite(Image.fromarray(im), Image.open(tp)))

def route_c():
    base = os.path.join(OUT, 'r_c_text.png'); r = shot(text_page('<span id="m">M</span>erma<span id="tt">t</span><span id="h">h</span>'), base, ['m', 'tt', 'h'])
    im = np.array(Image.open(base)); a = im[..., 3].copy(); body = ''
    xa, xb, yc, yt, x0, x1 = stem_at(a, r['h'], 44); im[:int(yc * SC), x0 - 16:x1 + 20, 3] = 0
    body += tail(xa, xb, yc, '#A98BF5', s=.9, tilt=12, bend=-6, neck=48)
    xa, xb, yc, yt, x0, x1 = stem_at(a, r['tt'], 20); im[:int(yc * SC), x0 - 10:x1 - 30, 3] = 0
    body += tail(xa, xb, yc, '#FFC933', s=.66, tilt=-12, bend=4, neck=40)
    xa, xb, yc, yt, x0, x1 = stem_at(a, r['m'], 30, which=-1)
    im[:int(yc * SC), int(xa * SC) - 8:x1 + 20, 3] = 0
    body += tail(xa, xb, yc, '#FF7EB6', s=1.0, tilt=-10, bend=6, neck=52)
    tp = os.path.join(OUT, 'r_c_tails.png'); shot(svg_page(body), tp)
    return ink(Image.alpha_composite(Image.fromarray(im), Image.open(tp)))

if __name__ == '__main__':
    A, B, C = route_a(), route_b(), route_c()
    for n, im in (('a', A), ('b', B), ('c', C)): im.save(os.path.join(OUT, f'route_{n}.png')); print(n, im.size)
    S = Image.new('RGB', (2300, 1700), (255, 244, 220))
    for i, im in enumerate((A, B, C)): S.paste(im, (60, 40 + i * 550), im)
    S.resize((1150, 850), Image.LANCZOS).save(os.path.join(OUT, 'sheet_routes.png'))
