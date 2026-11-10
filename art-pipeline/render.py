"""Render SVG files to PNG/JPEG with headless Chrome. Usage: render.py name:scale:alpha ..."""
import os, sys, re
from playwright.sync_api import sync_playwright
from PIL import Image

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out')

def chrome():
    """Which browser rasterizes the SVGs. Set MERMATH_CHROME to a Chrome/Chromium binary, or leave it unset to use a system Chrome if there is one, otherwise the Chromium that `playwright install chromium` provides."""
    want = os.environ.get('MERMATH_CHROME')
    if want and want != 'bundled': return dict(executable_path=want)
    if not want:
        for p in ('/usr/bin/google-chrome', '/usr/bin/chromium', '/usr/bin/chromium-browser', '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'):
            if os.path.exists(p): return dict(executable_path=p)
    return {}

def main(jobs):
    os.makedirs(OUT, exist_ok=True)
    with sync_playwright() as p:
        b = p.chromium.launch(args=['--no-sandbox'], **chrome())
        for job in jobs:
            name, scale, alpha = job.split(':')
            svg = open(os.path.join(OUT, name + '.svg')).read()
            w, h = map(int, re.search(r'width="(\d+)" height="(\d+)"', svg).groups())
            pg = b.new_page(viewport={'width': w, 'height': h}, device_scale_factor=float(scale))
            pg.set_content(f'<html><body style="margin:0;background:{"transparent" if alpha == "1" else "#000"}"><div style="width:{w}px;height:{h}px;line-height:0">{svg}</div></body></html>')
            pg.wait_for_timeout(150)
            png = os.path.join(OUT, name + '.png')
            pg.screenshot(path=png, omit_background=(alpha == '1'))
            pg.close()
            if alpha != '1':
                Image.open(png).convert('RGB').save(os.path.join(OUT, name + '.jpg'), quality=88)
            print(name, os.path.getsize(png))
        b.close()

def sheet(names, out, cell, cols, bg=(14, 60, 86)):
    ims = [Image.open(os.path.join(OUT, n)).convert('RGBA') for n in names]
    rows = (len(ims) + cols - 1) // cols
    S = Image.new('RGB', (cell[0] * cols, cell[1] * rows), bg)
    for i, im in enumerate(ims):
        im.thumbnail(cell)
        x = (i % cols) * cell[0] + (cell[0] - im.width) // 2; y = (i // cols) * cell[1] + (cell[1] - im.height) // 2
        S.paste(im, (x, y), im)
    S.save(os.path.join(OUT, out))

if __name__ == '__main__':
    if sys.argv[1] == 'sheet':
        cols = int(sys.argv[2]); cw, ch = map(int, sys.argv[3].split('x'))
        sheet(sys.argv[5:], sys.argv[4], (cw, ch), cols)
    else:
        main(sys.argv[1:])
