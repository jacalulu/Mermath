"""Legibility check for painted lettering on the reef map, the way shipping
games do it: measure each name's ink against the WORST part of the ground it
sits on (Xbox Accessibility Guideline 102 - judge a busy background by its
lowest-contrasting region), using WCAG relative-luminance ratios.

Builds the map plate from the real painted layers, places each baked lockup
at its map position, prints the ratio per name (large-text floor 3.0, target
4.5), and writes an annotated composite.

Usage: art-pipeline/.venv/bin/python tools/check-contrast.py [out.png]
"""
import sys
import numpy as np
from PIL import Image, ImageDraw

ROOT = __file__.rsplit('/', 2)[0]

# (lockup png, ink kind, design-space center x, y, target design width)
PLACEMENTS = [
    ('lettering_name_tide', 'light', 134, 218, 200),
    ('lettering_name_coral', 'deep', 424, 470, 235),
    ('lettering_name_deep', 'light', 672, 486, 200),
]


def rel_lum(rgb):
    c = rgb / 255.0
    c = np.where(c <= 0.03928, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    return c[..., 0] * 0.2126 + c[..., 1] * 0.7152 + c[..., 2] * 0.0722


def plate():
    base = Image.open(f'{ROOT}/assets/scenes/reef-map/bg.jpg').convert('RGB').resize((1600, 1200))
    base = base.convert('RGBA')
    for name, (x, y) in (('kelp-far.webp', (288, 194)), ('kelp-mid.webp', (648, 192)),
                         ('seabed.webp', (0, 88)), ('seagrass.png', (294, 296))):
        im = Image.open(f'{ROOT}/assets/scenes/reef-map/{name}').convert('RGBA')
        base.alpha_composite(im, (x * 2, y * 2))
    return base


def ink_luminance(im, kind):
    a = np.asarray(im)
    opaque = a[a[..., 3] > 220][:, :3]
    lum = rel_lum(opaque.astype(float))
    half = np.median(lum)
    core = lum[lum > half] if kind == 'light' else lum[lum < half]
    return float(np.median(core))


def main():
    base = plate()
    report = []
    boxes = []
    for name, kind, cx, cy, w in PLACEMENTS:
        im = Image.open(f'{ROOT}/art-pipeline/painted/{name}.png').convert('RGBA')
        scale = (w * 2) / im.width
        im = im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS)
        px, py = cx * 2 - im.width // 2, cy * 2 - im.height // 2
        # Composite first: what ships is what gets judged. The ground is then
        # everything the eye sees around the letter cores - pocket included.
        base.alpha_composite(im, (px, py))
        shipped = np.asarray(base.convert('RGB'))[py:py + im.height, px:px + im.width]
        alpha = np.asarray(im)[..., 3]
        letters = alpha > 230
        # Judge only the ring the letters actually touch (within ~8 design px)
        import cv2
        ring = cv2.dilate(letters.astype(np.uint8), np.ones((33, 33), np.uint8)).astype(bool) & (alpha < 80)
        slum = rel_lum(shipped.astype(float))[ring]
        worst = float(np.percentile(slum, 95 if kind == 'light' else 5))
        ink = ink_luminance(im, kind)
        hi, lo = max(ink, worst), min(ink, worst)
        ratio = (hi + 0.05) / (lo + 0.05)
        report.append((name, kind, ratio))
        boxes.append((px, py, im.width, im.height, ratio))

    d = ImageDraw.Draw(base)
    for px, py, w, h, ratio in boxes:
        ok = ratio >= 4.5
        color = (46, 160, 90, 255) if ok else (200, 60, 50, 255) if ratio < 3 else (220, 150, 30, 255)
        d.rounded_rectangle([px + w - 8, py - 26, px + w + 118, py + 18],
                            radius=12, fill=(10, 34, 56, 200))
        d.text((px + w + 54, py - 4), f'{ratio:.1f} : 1', fill=color, anchor='mm', font_size=30)

    out = sys.argv[1] if len(sys.argv) > 1 else '/tmp/claude-501/contrast-check.png'
    img = base.convert('RGB')
    img.thumbnail((1100, 1100))
    img.save(out)
    for name, kind, ratio in report:
        verdict = 'PASS 4.5' if ratio >= 4.5 else 'pass 3.0 (large text)' if ratio >= 3 else 'FAIL'
        print(f'{name:28s} ink={kind:5s} worst-ground contrast {ratio:4.1f}:1  {verdict}')
    print('wrote', out)


if __name__ == '__main__':
    main()
