"""Mermath wordmark: the name set in a soft serif, with one idea: a tail fin diving into the valley of the M."""
import glob, os, sys, json
import numpy as np
from PIL import Image
from playwright.sync_api import sync_playwright

FD = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'fonts'))
g = lambda pat: glob.glob(FD + '/' + pat)[0]
FR = g('x_fontsource-variable-fraunces-*/package/files/fraunces-latin-full-normal.woff2')
FRI = g('x_fontsource-variable-fraunces-*/package/files/fraunces-latin-full-italic.woff2')
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out')
STYLES = {
    'upright': "font-family:'Fr';font-weight:900;font-variation-settings:'SOFT' 100,'WONK' 1,'opsz' 144;letter-spacing:-4px",
    'italic': "font-family:'Fr';font-style:italic;font-weight:800;font-variation-settings:'SOFT' 100,'WONK' 1,'opsz' 144;letter-spacing:-4px",
}
FLUKE = "M-8 8 C-8 -8 -5 -22 -2 -32 C-8 -50 -26 -62 -46 -76 C-24 -76 -8 -68 0 -54 C8 -68 24 -76 46 -76 C26 -62 8 -50 2 -32 C5 -22 8 -8 8 8 Z"

def page_html(style, ink, fluke=None, word='Mermath', size=220, w=1040, h=400, pad=(40, 120), drops=True):
    css = f"""@font-face{{font-family:'Fr';font-weight:100 900;font-style:normal;src:url(file://{FR})}}
@font-face{{font-family:'Fr';font-weight:100 900;font-style:italic;src:url(file://{FRI})}}
html,body{{margin:0;background:transparent}} #box{{position:relative;width:{w}px;height:{h}px}}
#t{{position:absolute;left:{pad[0]}px;top:{pad[1]}px;font-size:{size}px;line-height:1;white-space:nowrap;{STYLES[style]};{ink}}}"""
    fl = ''
    if fluke:
        x, y, sc, rot, fill = fluke
        d = ''
        if drops:
            d = f'<ellipse cx="-34" cy="-18" rx="5" ry="7.5" transform="rotate(-24 -34 -18)" fill="{fill}"/><ellipse cx="33" cy="-24" rx="4" ry="6" transform="rotate(22 33 -24)" fill="{fill}"/>'
        fl = f'<svg style="position:absolute;left:0;top:0;width:{w}px;height:{h}px;z-index:0" viewBox="0 0 {w} {h}"><defs><linearGradient id="fg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFC062"/><stop offset="1" stop-color="#FF7F32"/></linearGradient></defs><g transform="translate({x:.1f} {y:.1f}) rotate({rot}) scale({sc})"><path d="{FLUKE}" fill="{fill}"/>{d}</g></svg>'
    return f'<html><head><style>{css}</style></head><body><div id="box">{fl}<div id="t" style="z-index:1"><span id="m">{word[0]}</span>{word[1:]}</div></div></body></html>'

def shoot(html, path, w=1040, h=400, scale=2):
    hp = path.replace('.png', '.html'); open(hp, 'w').write(html)
    with sync_playwright() as pw:
        b = pw.chromium.launch(executable_path='/usr/bin/google-chrome', args=['--no-sandbox', '--allow-file-access-from-files'])
        pg = b.new_page(viewport={'width': w, 'height': h}, device_scale_factor=scale)
        pg.goto('file://' + hp); pg.evaluate("document.fonts.ready.then(()=>1)"); pg.wait_for_timeout(600)
        rect = pg.evaluate("(()=>{const r=document.getElementById('m').getBoundingClientRect();return [r.left,r.top,r.right,r.bottom]})()")
        pg.locator('#box').screenshot(path=path, omit_background=True); b.close()
    return rect

def valley(path, rect, scale=2):
    a = np.array(Image.open(path))[..., 3]
    x0, x1 = int(rect[0] * scale), int(rect[2] * scale)
    lo, hi = int(x0 + (x1 - x0) * .3), int(x0 + (x1 - x0) * .7)
    tops = np.array([np.argmax(a[:, x] > 128) if (a[:, x] > 128).any() else 0 for x in range(lo, hi)])
    k = int(np.argmax(tops)); return (lo + k) / scale, tops[k] / scale, np.argmax((a[:, x0:x1] > 128).any(axis=1)) / scale

if __name__ == '__main__':
    INK = "color:#061A33"
    res = {}
    for st in STYLES:
        p = os.path.join(OUT, f'wm_{st}_base.png')
        rect = shoot(page_html(st, INK), p)
        vx, vy, cap = valley(p, rect)
        res[st] = (vx, vy, cap); print(st, 'valley', round(vx, 1), round(vy, 1), 'cap top', cap)
        rot = -8 if st == 'upright' else 6
        shoot(page_html(st, INK, fluke=(vx, vy + 14, 1.0, rot, 'url(#fg)')), os.path.join(OUT, f'wm_{st}.png'))
    json.dump(res, open(os.path.join(OUT, 'wm_valleys.json'), 'w'))
    S = Image.new('RGB', (2080, 1600), (215, 246, 240))
    for i, st in enumerate(STYLES):
        im = Image.open(os.path.join(OUT, f'wm_{st}.png')); S.paste(im, (0, i * 800), im)
    S.resize((1040, 800)).save(os.path.join(OUT, 'sheet_wm.png'))
