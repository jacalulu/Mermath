"""Mermath wordmark, fifth design: the plus is no longer a floating extra. The t in "math" IS the plus, right beside the h that grows into the tail."""
import os, sys, glob
import numpy as np, cv2
from PIL import Image
from wordmark3 import shot, text_page, svg_page, stem_at, W, H, SC, OUT
from wordmark6 import tail_local, paint_piece, ink_rows

BALOO = glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'fonts', '*', 'package', 'files', 'baloo-2-latin-700-normal.woff2'))[0]

def plus_t(cx, yb, hp=114, wp=110, t=33):
    """A rounded plus standing on the baseline in the t's place."""
    cy = yb + 1 - hp / 2; r = t / 2
    return (f'<rect x="{cx - r:.1f}" y="{yb + 1 - hp:.1f}" width="{t}" height="{hp}" rx="{r}" fill="url(#pg)"/><rect x="{cx - wp / 2:.1f}" y="{cy - r:.1f}" width="{wp}" height="{t}" rx="{r}" fill="url(#pg)"/>',
            f'<linearGradient id="pg" gradientUnits="userSpaceOnUse" x1="0" y1="{yb - hp:.0f}" x2="0" y2="{yb:.0f}"><stop offset="0" stop-color="#FFA548"/><stop offset="1" stop-color="#FF8433"/></linearGradient>', (cx, cy))

def bubbles(x, y):
    """Three pale answer bubbles with 1, 2, 3, rising from the fin."""
    out = ''
    for n, (dx, dy, r) in zip('123', ((40, -6, 19), (78, -44, 15), (66, -86, 11.5))):
        bx, by = x + dx, y + dy
        out += f'<circle cx="{bx:.1f}" cy="{by:.1f}" r="{r}" fill="url(#bub)" stroke="#ffffff" stroke-width="2"/><circle cx="{bx:.1f}" cy="{by:.1f}" r="{r + 1}" fill="none" stroke="#2494A2" stroke-width="1" opacity=".45"/><text x="{bx:.1f}" y="{by + r * .46:.1f}" font-family="Bal" font-weight="700" font-size="{r * 1.5:.1f}" text-anchor="middle" fill="#061A33">{n}</text>'
    return out, f'<radialGradient id="bub" cx=".32" cy=".24" r=".9"><stop offset="0" stop-color="#ffffff"/><stop offset=".3" stop-color="#F2FFFB"/><stop offset=".7" stop-color="#CFF5EE"/><stop offset="1" stop-color="#9FE8DE"/></radialGradient><style>@font-face{{font-family:"Bal";font-weight:700;src:url(file://{BALOO})}}</style>'

def build(name, math="t", tw=128, rise=122, sway=42, cut=58):
    tspan = f'<span id="tt" style="display:inline-block;width:{tw}px;color:transparent">t</span>' if math == 't' else '<span id="tt">t</span>'
    inner = f'<span style="letter-spacing:.012em">Merma{tspan}<span id="h">h</span></span>'
    base = os.path.join(OUT, name + '_text.png'); r = shot(text_page(inner), base, ['h', 'tt'])
    im = np.array(Image.open(base)); xa, xb, yc, yt, x0, x1 = stem_at(im[..., 3], r['h'], cut)
    yb = (np.nonzero((im[:, x0:x1, 3] > 128).any(axis=1))[0][-1] + 1) / SC      # baseline: bottom of the h's flat feet
    im[:int(yc * SC), x0 - 20:x1 + 20, 3] = 0
    cx, Wd = (xa + xb) / 2, xb - xa + 0.8; row = int(yc * SC)
    place = lambda s: f'<g transform="translate({cx:.2f} {yc:.2f})">{s}</g>'
    res, pieces = {}, {}
    for mode in ('navy', 'pearl'):
        rows = ink_rows(im[..., 3], mode)
        bod, fin, defs, (ex, ey) = tail_local(Wd, rise, sway, rows[row], mode)
        bp = os.path.join(OUT, f'{name}_{mode}_body.png'); shot(svg_page(place(bod), defs), bp); body, raw = paint_piece(bp)
        ramp = np.clip((np.arange(body.shape[0]) - (yc - 36) * SC) / (26 * SC), 0, 1)[:, None]
        body = body.astype(np.float32); body[..., :3] = body[..., :3] * (1 - ramp[..., None]) + rows[:, None, ::-1] * ramp[..., None]
        body[..., 3] = body[..., 3] * (1 - ramp) + raw[..., 3].astype(np.float32) * ramp
        body = body.astype(np.uint8); body[body[..., 3] == 0, :3] = 0; cv2.imwrite(bp, body)
        fp = os.path.join(OUT, f'{name}_{mode}_fin.png'); shot(svg_page(place(fin), defs), fp); fn, _ = paint_piece(fp); fn[fn[..., 3] == 0, :3] = 0; cv2.imwrite(fp, fn)
        arr = im.astype(np.float32); arr[..., :3] = rows[:, None, :]; text = Image.fromarray(arr.astype(np.uint8))
        mp = os.path.join(OUT, name + '_math.png')
        if math == 't':
            tcx = (r['tt'][0] + r['tt'][2]) / 2; svg, d, mc = plus_t(tcx, yb)
        else:
            svg, d = bubbles(cx + ex, yc + ey); mc = (cx + ex + 60, yc + ey - 40)
        shot(svg_page(svg, d), mp)
        pieces[mode] = dict(text=text, math=Image.open(mp), fin=Image.open(fp), body=Image.open(bp))
        c = text
        for k in ('math', 'fin', 'body'): c = Image.alpha_composite(c, pieces[mode][k])
        res[mode] = c
    bb = res['navy'].getbbox(); m = 16; box = (max(0, bb[0] - m), max(0, bb[1] - m), min(W * SC, bb[2] + m), min(H * SC, bb[3] + m))
    for mode in res:
        res[mode].crop(box).save(os.path.join(OUT, f'{name}_{mode}.png'))
        for k, v in pieces[mode].items(): v.crop(box).save(os.path.join(OUT, f'{name}_{mode}_L{k}.png'))
    pc = lambda x, y: '%.1f%% %.1f%%' % ((x * SC - box[0]) / (box[2] - box[0]) * 100, (y * SC - box[1]) / (box[3] - box[1]) * 100)
    print(name, 'size', (box[2] - box[0], box[3] - box[1]), 'base pivot', pc(cx, yc), 'fin pivot', pc(cx + ex, yc + ey), 'math centre', pc(*mc), flush=True)
    return res['navy'].crop(box), res['pearl'].crop(box)

if __name__ == '__main__':
    todo = sys.argv[1:] or ['t', 'b']
    outs = [build('w7_' + k, 't' if k == 't' else 'bubbles') for k in todo]
    S = Image.new('RGB', (2060, 60 + sum(o[0].height + 40 for o in outs) + 800), (255, 244, 220)); y = 30
    for nv, pe in outs: S.paste(nv, (40, y), nv); y += nv.height + 40
    nv, pe = outs[0]
    bg = Image.open('/home/claude/mermaid-art/home_bg0.jpg').resize((1600, 1200)).crop((300, 0, 1300, 420)); S.paste(bg, (40, y))
    sm = nv.resize((760, int(nv.height * 760 / nv.width)), Image.LANCZOS); S.paste(sm, (160, y + 80), sm)
    S.paste(Image.new('RGB', (980, 420), (6, 26, 51)), (1060, y)); sm = pe.resize((760, int(pe.height * 760 / pe.width)), Image.LANCZOS); S.paste(sm, (1170, y + 80), sm)
    x = 40
    for wdt in (480, 300, 200, 120):
        sm = nv.resize((wdt, int(nv.height * wdt / nv.width)), Image.LANCZOS); S.paste(sm, (x, y + 470), sm); x += wdt + 40
    S.save(os.path.join(OUT, 'sheet_w7.png'))
