"""Mermath wordmark, fourth design: the h's own stem grows into the tail. No band, no seam: the navy ink fades into violet and pink as the stroke narrows, and scales fade in."""
import os, math, sys
import numpy as np, cv2
from PIL import Image
from wordmark3 import shot, text_page, svg_page, stem_at, plus, W, H, SC, OUT
from sprites import bleed, rough
from paint import paint

FORK = [(-6, 4), (-22, -14), (-52, -46), (-62, -86), (-42, -74), (-16, -54), (0, -30), (14, -50), (36, -66), (54, -74), (46, -42), (22, -14), (6, 4)]
INK = {'navy': ((18, 66, 98), (6, 26, 51)), 'pearl': ((255, 250, 236), (255, 240, 208))}
hx = lambda c: '#%02x%02x%02x' % tuple(int(round(v)) for v in c)

def tail_local(Wd, rise, sway, base, mode='navy', endw=15.0, fs=1.05, under=14.0, tips='#FFB3D6'):
    """Local coordinates: the cut line is y=0, centre x=0, the tail grows up. Returns (body_svg, fin_svg, defs, tip)."""
    P = [(0, under), (0, -rise * .6), (sway * 1.1, -rise * .62), (sway, -rise)]
    def pt(t):
        m = 1 - t; return tuple(m**3 * P[0][k] + 3 * m * m * t * P[1][k] + 3 * m * t * t * P[2][k] + t**3 * P[3][k] for k in (0, 1))
    def tan(t):
        m = 1 - t; d = [3 * m * m * (P[1][k] - P[0][k]) + 6 * m * t * (P[2][k] - P[1][k]) + 3 * t * t * (P[3][k] - P[2][k]) for k in (0, 1)]
        n = math.hypot(*d) or 1; return d[0] / n, d[1] / n
    L, R = [], []
    for i in range(49):
        t = i / 48; x, y = pt(t); dx, dy = tan(t); u = min(1.0, max(0.0, (t - .16) / .84)); w = endw + (Wd - endw) * (1 - u) ** 1.25
        L.append((x + dy * w / 2, y - dx * w / 2)); R.append((x - dy * w / 2, y + dx * w / 2))
    body = 'M' + ' L'.join(f'{x:.1f} {y:.1f}' for x, y in L) + ' L' + ' L'.join(f'{x:.1f} {y:.1f}' for x, y in reversed(R)) + ' Z'
    ex, ey = pt(1); dx, dy = tan(1); ang = math.degrees(math.atan2(dx, -dy))
    f = lambda p: f'{p[0]:.1f} {p[1]:.1f}'
    fd = f'M{f(FORK[0])} ' + ''.join(f'C{f(FORK[i])} {f(FORK[i+1])} {f(FORK[i+2])} ' for i in range(1, len(FORK) - 1, 3)) + 'Z'
    hl = 'M' + ' L'.join(f'{(l[0]*.72+r[0]*.28):.1f} {(l[1]*.72+r[1]*.28):.1f}' for l, r in list(zip(L, R))[10:42])
    mid = ('#2B3C8C', '#6F5BD6') if mode == 'navy' else ('#E6D9FF', '#C4AEFB')
    defs = f'''<linearGradient id="tg" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="0" y2="{ey:.0f}">
<stop offset="0" stop-color="{hx(base)}"/><stop offset=".14" stop-color="{hx(base)}"/><stop offset=".4" stop-color="{mid[0]}"/><stop offset=".62" stop-color="{mid[1]}"/><stop offset=".82" stop-color="#A98BF5"/><stop offset="1" stop-color="#DB8FE2"/></linearGradient>
<linearGradient id="fg" gradientUnits="userSpaceOnUse" x1="0" y1="4" x2="0" y2="-86"><stop offset="0" stop-color="#DB8FE2"/><stop offset=".3" stop-color="#FF7EB6"/><stop offset="1" stop-color="{tips}"/></linearGradient>
<linearGradient id="mg" gradientUnits="userSpaceOnUse" x1="0" y1="0" x2="0" y2="{ey:.0f}"><stop offset=".3" stop-color="#000"/><stop offset=".66" stop-color="#fff"/></linearGradient>
<mask id="mk" maskUnits="userSpaceOnUse" x="-300" y="-500" width="600" height="700"><rect x="-300" y="-500" width="600" height="700" fill="url(#mg)"/></mask>
<pattern id="sc" width="15" height="13" patternUnits="userSpaceOnUse" patternTransform="rotate(-20)"><path d="M0 0 A7.5 7.5 0 0 0 15 0 M-7.5 6.5 A7.5 7.5 0 0 0 7.5 6.5 M7.5 6.5 A7.5 7.5 0 0 0 22.5 6.5" fill="none" stroke="#ffffff" stroke-width="1.4" opacity=".55"/></pattern>
<clipPath id="bc"><path d="{body}"/></clipPath><filter id="bl"><feGaussianBlur stdDeviation="2.5"/></filter>'''
    fin = f'''<g transform="translate({ex:.1f} {ey:.1f}) rotate({ang:.1f}) scale({fs})"><path d="{fd}" fill="url(#fg)"/>
<path d="M0 -4 C-14 -30 -34 -56 -52 -74 M0 -4 C-8 -24 -12 -40 -14 -52 M0 -4 C10 -26 24 -48 40 -62 M0 -4 C6 -22 8 -34 10 -44" fill="none" stroke="#ffffff" stroke-width="1.7" opacity=".6" stroke-linecap="round"/></g>'''
    bod = f'''<path d="{body}" fill="url(#tg)"/><g mask="url(#mk)"><path d="{body}" fill="url(#sc)"/>
<g clip-path="url(#bc)"><path d="{hl}" fill="none" stroke="#ffffff" stroke-width="7" opacity=".45" filter="url(#bl)" stroke-linecap="round"/></g></g>'''
    return bod, fin, defs, (ex, ey)

def paint_piece(path, radii=(10, 5, 3), amp=1.0):
    t = cv2.imread(path, cv2.IMREAD_UNCHANGED); bgr, a = np.ascontiguousarray(t[..., :3]), np.ascontiguousarray(t[..., 3])
    p = paint(bleed(bgr, a), radii=radii, thresholds=(-1, 7, 10), max_len=(6, 6, 4), jitter=.03, edge=4.0, flow_deg=80, sat=1.06)
    return np.dstack([p, rough(a, amp, 12, 5)]), t

def ink_rows(alpha, mode):
    """The lettering's top-to-bottom ink gradient, as one colour per pixel row (RGB)."""
    ys = np.nonzero((alpha > 20).any(axis=1))[0]
    t = np.clip((np.arange(alpha.shape[0]) - ys[0]) / max(1, ys[-1] - ys[0]), 0, 1)[:, None]
    top, bot = INK[mode]; return np.array(top, np.float32) * (1 - t) + np.array(bot, np.float32) * t

def build(word, name, rise=122, sway=42, cut=58, endw=15.0, fs=1.05, plus_at=(62, -56), tips='#FFB3D6'):
    inner = f'<span style="letter-spacing:.012em">{word[:-1]}<span id="h">h</span></span>'
    base = os.path.join(OUT, name + '_text.png'); r = shot(text_page(inner), base, ['h'])
    im = np.array(Image.open(base)); xa, xb, yc, yt, x0, x1 = stem_at(im[..., 3], r['h'], cut)
    im[:int(yc * SC), x0 - 20:x1 + 20, 3] = 0
    cx, Wd = (xa + xb) / 2, xb - xa + 0.8; row = int(yc * SC)
    place = lambda s: f'<g transform="translate({cx:.2f} {yc:.2f})">{s}</g>'
    res, pieces = {}, {}
    for mode in ('navy', 'pearl'):
        rows = ink_rows(im[..., 3], mode)
        bod, fin, defs, (ex, ey) = tail_local(Wd, rise, sway, rows[row], mode, endw, fs, tips=tips)
        bp = os.path.join(OUT, f'{name}_{mode}_body.png'); shot(svg_page(place(bod), defs), bp); body, raw = paint_piece(bp)
        # make the join exact: near the cut, use the lettering's own ink colour and the crisp vector edge
        ramp = np.clip((np.arange(body.shape[0]) - (yc - 36) * SC) / (26 * SC), 0, 1)[:, None]
        body = body.astype(np.float32); body[..., :3] = body[..., :3] * (1 - ramp[..., None]) + rows[:, None, ::-1] * ramp[..., None]
        body[..., 3] = body[..., 3] * (1 - ramp) + raw[..., 3].astype(np.float32) * ramp
        body = body.astype(np.uint8); body[body[..., 3] == 0, :3] = 0; cv2.imwrite(bp, body)
        fp = os.path.join(OUT, f'{name}_{mode}_fin.png'); shot(svg_page(place(fin), defs), fp); fn, _ = paint_piece(fp); fn[fn[..., 3] == 0, :3] = 0; cv2.imwrite(fp, fn)
        arr = np.array(Image.fromarray(im)).astype(np.float32); arr[..., :3] = rows[:, None, :]; text = Image.fromarray(arr.astype(np.uint8))
        pp = os.path.join(OUT, name + '_plus.png'); shot(svg_page(plus(cx + ex + plus_at[0], yc + ey + plus_at[1], 13, 9)), pp)
        pieces[mode] = dict(text=text, fin=Image.open(fp), body=Image.open(bp), plus=Image.open(pp))
        c = text
        for k in ('fin', 'body', 'plus'): c = Image.alpha_composite(c, pieces[mode][k])
        res[mode] = c
    bb = res['navy'].getbbox(); m = 16; box = (max(0, bb[0] - m), max(0, bb[1] - m), min(W * SC, bb[2] + m), min(H * SC, bb[3] + m))
    for mode in res:
        res[mode].crop(box).save(os.path.join(OUT, f'{name}_{mode}.png'))
        for k, v in pieces[mode].items(): v.crop(box).save(os.path.join(OUT, f'{name}_{mode}_L{k}.png'))
    pc = lambda x, y: '%.1f%% %.1f%%' % ((x * SC - box[0]) / (box[2] - box[0]) * 100, (y * SC - box[1]) / (box[3] - box[1]) * 100)
    print(name, 'size', (box[2] - box[0], box[3] - box[1]), 'base pivot', pc(cx, yc), 'fin pivot', pc(cx + ex, yc + ey), 'plus', pc(cx + ex + plus_at[0], yc + ey + plus_at[1]))
    return res['navy'].crop(box), res['pearl'].crop(box)

if __name__ == '__main__':
    todo = sys.argv[1:] or ['a']
    V = dict(a=('Mermath', 'w6_a', dict()), c=('mermath', 'w6_c', dict()), y=('Mermath', 'w6_y', dict(tips='#FFE79A')))
    outs = [build(*V[k][:2], **V[k][2]) for k in todo]
    S = Image.new('RGB', (2060, 80 + sum(o[0].height + 40 for o in outs) + 760), (255, 244, 220)); y = 30
    for nv, pe in outs: S.paste(nv, (40, y), nv); y += nv.height + 40
    nv, pe = outs[0]
    bg = Image.open('/home/claude/mermaid-art/home_bg0.jpg').resize((1600, 1200)).crop((300, 0, 1300, 420)); S.paste(bg, (40, y))
    sm = nv.resize((760, int(nv.height * 760 / nv.width)), Image.LANCZOS); S.paste(sm, (160, y + 80), sm)
    S.paste(Image.new('RGB', (980, 420), (6, 26, 51)), (1060, y)); sm = pe.resize((760, int(pe.height * 760 / pe.width)), Image.LANCZOS); S.paste(sm, (1170, y + 80), sm)
    x = 40
    for wdt in (480, 300, 200, 120):
        sm = nv.resize((wdt, int(nv.height * wdt / nv.width)), Image.LANCZOS); S.paste(sm, (x, y + 470), sm); x += wdt + 40
    c = nv.crop((nv.width - 640, 0, nv.width, nv.height)); S.paste(c, (1380, y + 440 - 0), c) if False else None
    S.save(os.path.join(OUT, 'sheet_w6.png')); nv.crop((nv.width - 700, 0, nv.width, nv.height)).save(os.path.join(OUT, 'close_w6.png'))
