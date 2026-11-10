import os, numpy as np, cv2
from PIL import Image, ImageDraw, ImageFilter
from playwright.sync_api import sync_playwright
from wordmark6 import tail_local, paint_piece, OUT
N = 1024
def page(body, defs, path):
    html = f'<html><body style="margin:0;background:transparent"><div id="box" style="width:{N}px;height:{N}px"><svg width="{N}" height="{N}" viewBox="0 0 {N} {N}"><defs>{defs}</defs>{body}</svg></div></body></html>'
    hp = path.replace('.png', '.html'); open(hp, 'w').write(html)
    with sync_playwright() as pw:
        b = pw.chromium.launch(executable_path='/usr/bin/google-chrome', args=['--no-sandbox', '--allow-file-access-from-files'])
        pg = b.new_page(viewport={'width': N, 'height': N}, device_scale_factor=1); pg.goto('file://' + hp); pg.wait_for_timeout(200)
        pg.locator('#box').screenshot(path=path, omit_background=True); b.close()
def shadow(im, blur=26, k=.38, dx=10, dy=22):
    sh = Image.new('RGBA', (N, N), (0, 0, 0, 0)); a = im.split()[3].filter(ImageFilter.GaussianBlur(blur))
    sh.paste((6, 60, 90, 255), (0, 0), a.point(lambda v: int(v * k))); return sh.transform((N, N), Image.AFFINE, (1, 0, -dx, 0, 1, -dy))
bod, fin, defs, (ex, ey) = tail_local(42, 150, 40, (14, 52, 80), 'navy', 15, 1.08)
K, BX, BY = 3.55, 600, 1040
tp = os.path.join(OUT, 'icon7_tail.png'); page(f'<g transform="translate({BX} {BY}) scale({K})">{fin}{bod}</g>', defs, tp)
p, _ = paint_piece(tp, radii=(22, 11, 6), amp=2.0); p[p[..., 3] == 0, :3] = 0; cv2.imwrite(tp, p)
cx, cy, S_, T = 292, 668, 330, 100
pp = os.path.join(OUT, 'icon7_plus.png'); page(f'<rect x="{cx - T / 2}" y="{cy - S_ / 2}" width="{T}" height="{S_}" rx="{T / 2}" fill="url(#pg)"/><rect x="{cx - S_ / 2}" y="{cy - T / 2}" width="{S_}" height="{T}" rx="{T / 2}" fill="url(#pg)"/>', f'<linearGradient id="pg" gradientUnits="userSpaceOnUse" x1="0" y1="{cy - S_ / 2}" x2="0" y2="{cy + S_ / 2}"><stop offset="0" stop-color="#FFB05A"/><stop offset="1" stop-color="#FF8433"/></linearGradient>', pp)
bg = Image.open('/home/claude/mermaid-art/home_bg0.jpg'); w, h = bg.size; s = int(h * .62)
bg = bg.crop((w // 2 - s // 2 - int(w * .04), 0, w // 2 + s // 2 - int(w * .04), s)).resize((N, N), Image.LANCZOS).convert('RGBA')
tail, pl = Image.open(tp), Image.open(pp)
icon = bg
for layer in (shadow(pl, 22, .34, 8, 18), pl, shadow(tail), tail): icon = Image.alpha_composite(icon, layer)
icon.convert('RGB').save(os.path.join(OUT, 'app_icon7_1024.png'))
m = Image.new('L', (N * 2, N * 2), 0); ImageDraw.Draw(m).rounded_rectangle((0, 0, N * 2 - 1, N * 2 - 1), radius=460, fill=255); icon.putalpha(m.resize((N, N), Image.LANCZOS))
icon.resize((512, 512), Image.LANCZOS).save(os.path.join(OUT, 'app_icon7.png'))
S = Image.new('RGB', (900, 560), (255, 244, 220)); x = 20
for sz in (512, 180, 64, 32):
    im = icon.resize((sz, sz), Image.LANCZOS); S.paste(im, (x, 20), im); x += sz + 24
S.save(os.path.join(OUT, 'check_icon7.png'))
