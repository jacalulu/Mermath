"""Painted lettering lockups: a display font's glyphs, hand-bounced and gagged
with underwater objects, then run through the brush painter so the words are
part of the world instead of type set on top of it.

Each candidate font becomes one layer; the gag is held constant (the first
'o' becomes a pearl, bubbles rise off the last letter) so only the letterform
character varies between candidates."""
import os
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen

FONTS = {
    'chewy': 'Chewy-Regular.ttf',
    'lucky': 'LuckiestGuy-Regular.ttf',
    'modak': 'Modak-Regular.ttf',
    'titan': 'TitanOne-Regular.ttf',
}
FDIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'fonts', 'candidates')

DEFS = (
    '<linearGradient id="creamg" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#FFFBEA"/><stop offset=".72" stop-color="#F6E2B2"/>'
    '<stop offset="1" stop-color="#EBCE96"/></linearGradient>'
    '<radialGradient id="pearlg" cx=".35" cy=".3" r=".85">'
    '<stop offset="0" stop-color="#FFFFFF"/><stop offset=".55" stop-color="#FFF0E0"/>'
    '<stop offset="1" stop-color="#E2BFA0"/></radialGradient>'
)


def _glyphs(path, text):
    font = TTFont(path)
    if 'fvar' in font:
        from fontTools.varLib.instancer import instantiateVariableFont
        instantiateVariableFont(font, {'wght': 700})
    gs = font.getGlyphSet()
    cmap = font.getBestCmap()
    upem = font['head'].unitsPerEm
    out = []
    for ch in text:
        if ch == ' ':
            out.append((ch, None, upem * 0.28))
            continue
        pen = SVGPathPen(gs)
        g = gs[cmap[ord(ch)]]
        g.draw(pen)
        out.append((ch, pen.getCommands(), g.width))
    return out, upem


def _letters(gl, k, baseline, cx, tracking=0.97):
    """Per-letter placement: a whisper of bounce, not a jig."""
    total = sum(w for _, _, w in gl) * k * tracking
    x = cx - total / 2
    out = []
    i = 0
    for ch, d, w in gl:
        wpx = w * k * tracking
        if d is not None:
            rot = -1.5 if i % 2 == 0 else 1.2
            dy = -2.0 if i % 2 == 0 else 2.0
            out.append((ch, d, x, baseline + dy, rot, wpx))
        x += wpx
        i += 1
    return out, x


def _lockup(key, text='Coral Reef', cap=74.0, baseline=330.0, cx=400.0):
    from fontTools.pens.boundsPen import BoundsPen
    path = os.path.join(FDIR, FONTS[key])
    gl, upem = _glyphs(path, text)
    k = cap / (upem * 0.7)
    letters, xend = _letters(gl, k, baseline, cx)

    def glyph_el(d, x, y, rot, fill, opacity=1.0, dx=0.0, dyo=0.0):
        return (f'<g transform="translate({x + dx:.1f} {y + dyo:.1f}) rotate({rot})" opacity="{opacity}">'
                f'<path transform="scale({k:.5f} {-k:.5f})" d="{d}" fill="{fill}"/></g>')

    # Pass 1: one soft painted shadow under the whole word (no contour lines)
    parts = [glyph_el(d, x, y, rot, '#0E2C42', 0.4, 4.0, 7.0) for _, d, x, y, rot, _ in letters]
    # Pass 2: the letters themselves, cream with a deeper foot
    parts += [glyph_el(d, x, y, rot, 'url(#creamg)') for _, d, x, y, rot, _ in letters]

    # The gag, kept light: a small pearl nested in the first o's counter
    font = TTFont(path)
    gs = font.getGlyphSet()
    bp = BoundsPen(gs)
    gs[font.getBestCmap()[ord('o')]].draw(bp)
    for ch, d, x, y, rot, wpx in letters:
        if ch == 'o' and bp.bounds:
            x0, y0, x1, y1 = bp.bounds
            pcx = x + (x0 + x1) / 2 * k
            pcy = y - (y0 + y1) / 2 * k
            r = min(x1 - x0, y1 - y0) * k * 0.17
            parts.append(
                f'<circle cx="{pcx:.1f}" cy="{pcy:.1f}" r="{r:.1f}" fill="url(#pearlg)"/>'
                f'<ellipse cx="{pcx - r * 0.33:.1f}" cy="{pcy - r * 0.38:.1f}" rx="{r * 0.3:.1f}" '
                f'ry="{r * 0.2:.1f}" fill="#FFFFFF" opacity=".9"/>')
            break

    # Bubbles drift up off the last letter, quiet
    parts.append(
        f'<circle cx="{xend - 4:.0f}" cy="{baseline - cap - 22:.0f}" r="6" fill="#EAF8FB" opacity=".9"/>'
        f'<circle cx="{xend + 9:.0f}" cy="{baseline - cap - 42:.0f}" r="4" fill="#EAF8FB" opacity=".75"/>'
        f'<circle cx="{xend + 1:.0f}" cy="{baseline - cap - 58:.0f}" r="2.6" fill="#EAF8FB" opacity=".6"/>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 600" width="800" '
            f'height="600"><defs>{DEFS}</defs>{"".join(parts)}</svg>')


def scene_lettering_layers():
    return {f'lt_{key}': _lockup(key) for key in FONTS}
