"""Tide Pool style frame: the scene (source picture for the brush-stroke pass). parts=True leaves out the crab and the near kelp, which become separate moving layers."""
import math, os, base64
from chars import OUT, bubble
from scenes import S, W, H, kelp, hill, school, seastar, grass

def smooth_arc(pts):
    d = f'M{pts[0][0]:.0f} {pts[0][1]:.0f} '
    for i in range(1, len(pts) - 1):
        mx = (pts[i][0] + pts[i+1][0]) / 2; my = (pts[i][1] + pts[i+1][1]) / 2
        d += f'Q{pts[i][0]:.0f} {pts[i][1]:.0f} {mx:.0f} {my:.0f} '
    return d + f'L{pts[-1][0]:.0f} {pts[-1][1]:.0f} '

def boulder(s, cx, cy, w, h, lit='#a8e6d8', base='#3f8492', dark='#1c5266', moss=True, n=9):
    r = s.r; pts = []
    for i in range(n):
        a = math.pi + math.pi * i / (n - 1); k = r.uniform(.88, 1.06) if 0 < i < n - 1 else 1
        pts.append((cx + w / 2 * k * math.cos(a), cy + h * k * math.sin(a)))
    top = smooth_arc(pts)
    d = top + f'L{cx+w/2:.0f} {cy+14:.0f} L{cx-w/2:.0f} {cy+14:.0f} Z'
    out = f'<path d="{d}" fill="{s.lin([(0, lit, 1), (.3, base, 1), (1, dark, 1)])}"/>'
    inner = f'<ellipse cx="{cx-w*.12:.0f}" cy="{cy-h*.92:.0f}" rx="{w*.34:.0f}" ry="{h*.3:.0f}" fill="#eafff6" opacity=".55" filter="url(#b12)"/>'
    inner += f'<ellipse cx="{cx+w*.3:.0f}" cy="{cy-h*.1:.0f}" rx="{w*.36:.0f}" ry="{h*.5:.0f}" fill="#0d3a50" opacity=".45" filter="url(#b12)"/>'
    if moss:
        for i in range(6):
            mx = cx + r.uniform(-.38, .38) * w; my = cy - r.uniform(.2, .85) * h
            inner += f'<ellipse cx="{mx:.0f}" cy="{my:.0f}" rx="{r.uniform(.06, .14)*w:.0f}" ry="{r.uniform(.05, .1)*h+4:.0f}" fill="{r.choice(["#3fae8c", "#2f9c86", "#62c7a2"])}" opacity=".6" filter="url(#b3)"/>'
    for i in range(3):
        x0 = cx + r.uniform(-.3, .3) * w; y0 = cy - r.uniform(.3, .8) * h
        inner += f'<path d="M{x0:.0f} {y0:.0f} q{r.uniform(-20, 20):.0f} {r.uniform(14, 30):.0f} {r.uniform(-10, 10):.0f} {r.uniform(34, 60):.0f}" fill="none" stroke="#12425a" stroke-width="3" opacity=".35" stroke-linecap="round"/>'
    out += f'<g clip-path="{s.clip(d)}">{inner}</g>'
    return out + f'<path d="{top}" fill="none" stroke="#eafff6" stroke-width="2.5" opacity=".6" filter="url(#b1)"/>'

def scene_tide_frame(parts=False):
    s = S(211, 300, -230, 1000); r = s.r
    s.water(['#dcfcef', '#93e7d7', '#3db5be', '#1b86a1', '#12617f'], [0, .1, .38, .72, 1])
    s.bloom(300, -40, 540, '#ffffff', .9, 330)
    s.add('<path d="M-20 -20 L820 -20 L820 26 C740 44 690 14 610 30 C520 48 470 16 380 32 C300 46 240 18 160 34 C100 46 40 26 -20 38 Z" fill="#f4fff9" opacity=".85" filter="url(#b3)"/>')
    s.add('<path d="M-20 46 C60 32 110 60 190 48 C270 36 330 64 410 52 C500 38 560 66 640 52 C710 40 770 60 820 48" fill="none" stroke="#ffffff" stroke-width="5" opacity=".55" filter="url(#b1)"/>')
    far = ''.join(kelp(r, x + r.uniform(-12, 12), 6, '#6fd0cd', (30, 56), (6, 10), (22, 38)) for x in (236, 330, 452, 548, 640, 716))
    s.add(f'<g filter="url(#b3)" opacity=".5">{far}</g>')
    d, top = hill(r, 452, 14); s.add(f'<path d="{d}" fill="#52bcc0" opacity=".7" filter="url(#b3)"/>')
    s.rays([(-30, 5), (-18, 7), (-6, 4), (6, 8), (18, 5), (30, 6), (42, 4)], 1000, .5)
    mid = kelp(r, 18, 12, '#1f8f95', (46, 86), (10, 16), (28, 46), lean=24) + kelp(r, 744, 11, '#1f8f95', (40, 72), (9, 15), (26, 44), lean=-12)
    s.add(f'<g filter="url(#paintS)">{mid}</g>')
    d1, top1 = hill(r, 470, 8)
    s.add(f'<path d="{d1}" fill="{s.lin([(0, "#f7e6ba", 1), (1, "#d6b27c", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(d1)}"><rect width="{W}" height="{H}" filter="url(#caustic)" opacity=".55" style="mix-blend-mode:screen"/></g>')
    ff, nf = school(r, 5, [(690, 430), (600, 452)], 16, size=(.12, .22), heading=-6)
    s.add(ff + nf)
    s.add(boulder(s, 712, 530, 250, 120) + boulder(s, 596, 558, 120, 56, moss=False))
    left = kelp(r, -4, 30, '#0f5560', (80, 140), (18, 30), (38, 62), lean=20, rim='#bff7e6')
    s.add(f'<g filter="url(#paint)">{left}</g>')
    s.add(boulder(s, 140, 486, 310, 100) + boulder(s, 300, 544, 120, 52, moss=False))
    d2, top2 = hill(r, 566, 6)
    s.add(f'<path d="{d2}" fill="{s.lin([(0, "#fbeecd", 1), (1, "#c9a06c", 1)])}"/>')
    s.add('<ellipse cx="140" cy="402" rx="96" ry="12" fill="#0d3a50" opacity=".5" filter="url(#b6)"/>')
    if not parts:
        b64 = base64.b64encode(open(os.path.join(OUT, 'crab2x.png'), 'rb').read()).decode()
        s.add(f'<image href="data:image/png;base64,{b64}" x="15" y="204" width="250" height="211"/>')
    near = kelp(r, 802, 34, '#0b4650', (60, 110), (16, 26), (36, 58), lean=-22, rim='#bff7e6')
    if not parts: s.add(f'<g filter="url(#paint)">{near}</g>')
    s.add(grass(r, 26, 570, 7, 30, 70, '#1f9c7c', '#3fc79a') + grass(r, 252, 574, 6, 22, 50, '#1f9c7c', '#3fc79a') + grass(r, 646, 578, 6, 22, 52, '#1f9c7c', '#3fc79a') + grass(r, 786, 572, 7, 30, 72, '#1f9c7c', '#3fc79a'))
    s.add(seastar(374, 562, 18, '#ff7eb6', -80) + seastar(502, 580, 13, '#ff9a3d', -100) + seastar(440, 590, 9, '#ffd27a', -70))
    for x, y in ((566, 590), (330, 588)):
        s.add(f'<path d="M{x-13} {y} A13 13 0 0 1 {x+13} {y} Z" fill="#fff4dc" stroke="#e8c79a" stroke-width="1.5"/><path d="M{x} {y} L{x-8} {y-9} M{x} {y} L{x} {y-13} M{x} {y} L{x+8} {y-9}" stroke="#e8c79a" stroke-width="1.5"/>')
    s.add(''.join(bubble(x, y, rr) for x, y, rr in ((274, 246, 12), (292, 198, 8), (716, 408, 13), (704, 340, 9), (724, 286, 11))))
    s.finish(mott=.26, streak=.14, vig=.3, grain=0)
    if parts:
        kelp_svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}"><defs>{"".join(s.defs)}</defs><g filter="url(#paint)">{near}</g></svg>'
        return s.svg(), kelp_svg
    return s.svg()

if __name__ == '__main__':
    bg, k = scene_tide_frame(parts=True)
    open(os.path.join(OUT, 'frame_tide_bg.svg'), 'w').write(bg)
    open(os.path.join(OUT, 'frame_kelp_r.svg'), 'w').write(k)
    print('ok')


class LS(S):
    """Scene whose drawing calls are routed to named layers, each rendered on its own."""
    def __init__(s, *a, **k):
        super().__init__(*a, **k); s.layers = {}; s.cur = 'bg'
    def layer(s, name): s.cur = name; return s
    def add(s, x): s.layers.setdefault(s.cur, []).append(x); return s
    def svg_layer(s, name):
        return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}"><defs>{"".join(s.defs)}</defs><g clip-path="url(#frame)">{"".join(s.layers.get(name, []))}</g></svg>'

def scene_tide_layers():
    s = LS(211, 300, -230, 1000); r = s.r
    s.layer('bg')
    s.water(['#dcfcef', '#93e7d7', '#3db5be', '#1b86a1', '#12617f'], [0, .1, .38, .72, 1])
    s.bloom(300, -40, 540, '#ffffff', .9, 330)
    s.add('<path d="M-20 -20 L820 -20 L820 26 C740 44 690 14 610 30 C520 48 470 16 380 32 C300 46 240 18 160 34 C100 46 40 26 -20 38 Z" fill="#f4fff9" opacity=".85" filter="url(#b3)"/>')
    s.add('<path d="M-20 46 C60 32 110 60 190 48 C270 36 330 64 410 52 C500 38 560 66 640 52 C710 40 770 60 820 48" fill="none" stroke="#ffffff" stroke-width="5" opacity=".55" filter="url(#b1)"/>')
    far = ''.join(kelp(r, x + r.uniform(-12, 12), 6, '#6fd0cd', (30, 56), (6, 10), (22, 38)) for x in (236, 330, 452, 548, 640, 716))
    s.layer('kelp_far').add(f'<g filter="url(#b3)" opacity=".6">{far}</g>')
    d, top = hill(r, 452, 14); s.layer('bg').add(f'<path d="{d}" fill="#52bcc0" opacity=".7" filter="url(#b3)"/>')
    s.rays([(-30, 5), (-18, 7), (-6, 4), (6, 8), (18, 5), (30, 6), (42, 4)], 1000, .5)
    mid = kelp(r, 18, 12, '#1f8f95', (46, 86), (10, 16), (28, 46), lean=24) + kelp(r, 744, 11, '#1f8f95', (40, 72), (9, 15), (26, 44), lean=-12)
    s.layer('kelp_mid').add(f'<g filter="url(#paintS)">{mid}</g>')
    d1, top1 = hill(r, 470, 8)
    s.layer('fg').add(f'<path d="{d1}" fill="{s.lin([(0, "#f7e6ba", 1), (1, "#d6b27c", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(d1)}"><rect width="{W}" height="{H}" filter="url(#caustic)" opacity=".55" style="mix-blend-mode:screen"/></g>')
    school(r, 5, [(690, 430), (600, 452)], 16, size=(.12, .22), heading=-6)
    s.add(boulder(s, 712, 530, 250, 120) + boulder(s, 596, 558, 120, 56, moss=False))
    left = kelp(r, -4, 30, '#0f5560', (80, 140), (18, 30), (38, 62), lean=20, rim='#bff7e6')
    s.layer('kelp_left').add(f'<g filter="url(#paint)">{left}</g>')
    s.layer('fg').add(boulder(s, 140, 486, 310, 100) + boulder(s, 300, 544, 120, 52, moss=False))
    d2, top2 = hill(r, 566, 6)
    s.add(f'<path d="{d2}" fill="{s.lin([(0, "#fbeecd", 1), (1, "#c9a06c", 1)])}"/>')
    s.add('<ellipse cx="140" cy="402" rx="96" ry="12" fill="#0d3a50" opacity=".5" filter="url(#b6)"/>')
    kelp(r, 802, 34, '#0b4650', (60, 110), (16, 26), (36, 58), lean=-22, rim='#bff7e6')
    s.layer('grass').add(grass(r, 26, 570, 7, 30, 70, '#1f9c7c', '#3fc79a') + grass(r, 252, 574, 6, 22, 50, '#1f9c7c', '#3fc79a') + grass(r, 646, 578, 6, 22, 52, '#1f9c7c', '#3fc79a') + grass(r, 786, 572, 7, 30, 72, '#1f9c7c', '#3fc79a'))
    s.layer('fg').add(seastar(440, 590, 9, '#ffd27a', -70))
    for x, y in ((566, 590), (330, 588)):
        s.add(f'<path d="M{x-13} {y} A13 13 0 0 1 {x+13} {y} Z" fill="#fff4dc" stroke="#e8c79a" stroke-width="1.5"/><path d="M{x} {y} L{x-8} {y-9} M{x} {y} L{x} {y-13} M{x} {y} L{x+8} {y-9}" stroke="#e8c79a" stroke-width="1.5"/>')
    s.layer('bg'); s.finish(mott=.26, streak=.14, vig=0, grain=0)
    return {n: s.svg_layer(n) for n in ('bg', 'kelp_far', 'kelp_mid', 'kelp_left', 'fg', 'grass')}

if __name__ == '__main__':
    for n, svg in scene_tide_layers().items():
        open(os.path.join(OUT, 'L_' + n + '.svg'), 'w').write(svg)
    print('layers ok')


def scene_home_layers():
    """Pick-your-mermaid scene: open water in the middle for the three sisters, kelp both sides, low sand."""
    s = LS(307, 300, -230, 1000); r = s.r
    s.layer('bg')
    s.water(['#dcfcef', '#8fe3d6', '#35aab8', '#167c9b', '#0e5576'], [0, .1, .38, .72, 1])
    s.bloom(300, -40, 540, '#ffffff', .9, 330)
    s.add('<path d="M-20 -20 L820 -20 L820 26 C740 44 690 14 610 30 C520 48 470 16 380 32 C300 46 240 18 160 34 C100 46 40 26 -20 38 Z" fill="#f4fff9" opacity=".85" filter="url(#b3)"/>')
    s.add('<path d="M-20 46 C60 32 110 60 190 48 C270 36 330 64 410 52 C500 38 560 66 640 52 C710 40 770 60 820 48" fill="none" stroke="#ffffff" stroke-width="5" opacity=".55" filter="url(#b1)"/>')
    far = ''.join(kelp(r, x + r.uniform(-12, 12), 6, '#6fd0cd', (30, 56), (6, 10), (22, 38)) for x in (150, 245, 335, 430, 520, 610, 690))
    s.layer('kelp_far').add(f'<g filter="url(#b3)" opacity=".6">{far}</g>')
    d, top = hill(r, 486, 14); s.layer('bg').add(f'<path d="{d}" fill="#4ab4bd" opacity=".7" filter="url(#b3)"/>')
    s.rays([(-30, 5), (-18, 7), (-6, 4), (6, 8), (18, 5), (30, 6), (42, 4)], 1000, .5)
    mid = kelp(r, 96, 12, '#1f8f95', (46, 86), (10, 16), (28, 46), lean=16) + kelp(r, 706, 11, '#1f8f95', (40, 72), (9, 15), (26, 44), lean=-14)
    s.layer('kelp_mid').add(f'<g filter="url(#paintS)">{mid}</g>')
    left = kelp(r, -6, 32, '#0f5560', (80, 140), (18, 30), (38, 62), lean=18, rim='#bff7e6') + kelp(r, 46, 15, '#12626c', (54, 96), (12, 20), (30, 50), lean=-12, rim='#bff7e6')
    s.layer('kelp_left').add(f'<g filter="url(#paint)">{left}</g>')
    right = kelp(r, 806, 34, '#0b4650', (70, 120), (16, 28), (36, 58), lean=-20, rim='#bff7e6') + kelp(r, 754, 15, '#12626c', (54, 96), (12, 20), (30, 50), lean=12, rim='#bff7e6')
    s.layer('kelp_right').add(f'<g filter="url(#paint)">{right}</g>')
    d1, top1 = hill(r, 510, 8)
    s.layer('fg').add(f'<path d="{d1}" fill="{s.lin([(0, "#f7e6ba", 1), (1, "#d6b27c", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(d1)}"><rect width="{W}" height="{H}" filter="url(#caustic)" opacity=".55" style="mix-blend-mode:screen"/></g>')
    s.add(boulder(s, 70, 570, 210, 76) + boulder(s, 736, 574, 230, 86) + boulder(s, 236, 592, 96, 36, moss=False) + boulder(s, 596, 594, 104, 38, moss=False))
    d2, top2 = hill(r, 584, 5)
    s.add(f'<path d="{d2}" fill="{s.lin([(0, "#fbeecd", 1), (1, "#c9a06c", 1)])}"/>')
    s.layer('grass').add(grass(r, 150, 590, 7, 28, 62, '#1f9c7c', '#3fc79a') + grass(r, 330, 592, 6, 22, 48, '#1f9c7c', '#3fc79a') + grass(r, 505, 592, 6, 22, 50, '#1f9c7c', '#3fc79a') + grass(r, 664, 590, 7, 28, 64, '#1f9c7c', '#3fc79a'))
    s.layer('fg').add(seastar(288, 590, 9, '#ffd27a', -70))
    s.layer('bg'); s.finish(mott=.26, streak=.14, vig=0, grain=0)
    return {n: s.svg_layer(n) for n in ('bg', 'kelp_far', 'kelp_mid', 'kelp_left', 'kelp_right', 'fg', 'grass')}

if __name__ == '__main__':
    for n, svg in scene_home_layers().items():
        open(os.path.join(OUT, 'H_' + n + '.svg'), 'w').write(svg)
    print('home ok')
