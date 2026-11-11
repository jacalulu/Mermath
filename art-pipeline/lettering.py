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
    '<stop offset="0" stop-color="#FFFBEA"/><stop offset="1" stop-color="#F3DDAC"/></linearGradient>'
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


def _lockup(key, text='Coral Reef', cap=74.0, baseline=330.0, cx=400.0):
    gl, upem = _glyphs(os.path.join(FDIR, FONTS[key]), text)
    k = cap / (upem * 0.7)
    total = sum(w for _, _, w in gl) * k
    x = cx - total / 2
    parts = []
    stroke_w = 3.4 / k
    pearl_done = False
    i = 0
    for ch, d, w in gl:
        wpx = w * k
        if d is None:
            x += wpx
            i += 1
            continue
        rot = -4 if i % 2 == 0 else 3
        dy = -5.0 if i % 2 == 0 else 5.0
        if ch == 'o' and not pearl_done:
            # The gag: this o is a pearl of the game's own treasure
            pearl_done = True
            r = cap * 0.33
            pcx, pcy = x + wpx / 2, baseline + dy - cap * 0.33
            parts.append(
                f'<circle cx="{pcx:.1f}" cy="{pcy:.1f}" r="{r:.1f}" fill="url(#pearlg)" '
                f'stroke="#1B4A66" stroke-width="3.4"/>'
                f'<ellipse cx="{pcx - r * 0.35:.1f}" cy="{pcy - r * 0.4:.1f}" rx="{r * 0.3:.1f}" '
                f'ry="{r * 0.18:.1f}" fill="#FFFFFF" opacity=".85"/>')
        else:
            parts.append(
                f'<g transform="translate({x:.1f} {baseline + dy:.1f}) rotate({rot})">'
                f'<path transform="scale({k:.5f} {-k:.5f})" d="{d}" fill="url(#creamg)" '
                f'stroke="#1B4A66" stroke-width="{stroke_w:.1f}" stroke-linejoin="round"/></g>')
        x += wpx
        i += 1
    # Bubbles drift up off the last letter
    bx = x - 6
    parts.append(
        f'<circle cx="{bx:.0f}" cy="{baseline - cap - 26:.0f}" r="7" fill="#DFF3F7" '
        f'stroke="#7FC9D8" stroke-width="2.6"/>'
        f'<circle cx="{bx + 14:.0f}" cy="{baseline - cap - 48:.0f}" r="4.5" fill="#DFF3F7" '
        f'stroke="#7FC9D8" stroke-width="2.2"/>'
        f'<circle cx="{bx + 4:.0f}" cy="{baseline - cap - 66:.0f}" r="3" fill="#EAF8FB" '
        f'stroke="#7FC9D8" stroke-width="2"/>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 600" width="800" '
            f'height="600"><defs>{DEFS}</defs>{"".join(parts)}</svg>')


def scene_lettering_layers():
    return {f'lt_{key}': _lockup(key) for key in FONTS}
