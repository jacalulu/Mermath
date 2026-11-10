import math, random, os, sys
from chars import hexmix, star, glint, bubble, OUT, lerp

W, H = 800, 600

def blur(n, i=None):
    return f'<filter id="b{i or n}" x="-80%" y="-80%" width="260%" height="260%"><feGaussianBlur stdDeviation="{n}"/></filter>'

COMMON = blur(1.2, 1) + blur(3) + blur(6) + blur(12) + blur(30) + '''
<filter id="paint" x="-5%" y="-5%" width="110%" height="110%"><feTurbulence type="fractalNoise" baseFrequency="0.022" numOctaves="3" seed="4" result="n"/><feDisplacementMap in="SourceGraphic" in2="n" scale="14" xChannelSelector="R" yChannelSelector="G"/></filter>
<filter id="paintS" x="-5%" y="-5%" width="110%" height="110%"><feTurbulence type="fractalNoise" baseFrequency="0.035" numOctaves="3" seed="9" result="n"/><feDisplacementMap in="SourceGraphic" in2="n" scale="9" xChannelSelector="R" yChannelSelector="G" result="d"/><feGaussianBlur in="d" stdDeviation="0.8"/></filter>
<filter id="mottle" x="0" y="0" width="100%" height="100%" color-interpolation-filters="sRGB"><feTurbulence type="fractalNoise" baseFrequency="0.006 0.009" numOctaves="4" seed="11"/><feColorMatrix type="matrix" values="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1"/><feComponentTransfer><feFuncR type="linear" slope="3.2" intercept="-1.1"/><feFuncG type="linear" slope="3.2" intercept="-1.1"/><feFuncB type="linear" slope="3.2" intercept="-1.1"/></feComponentTransfer></filter>
<filter id="streak" x="0" y="0" width="100%" height="100%" color-interpolation-filters="sRGB"><feTurbulence type="fractalNoise" baseFrequency="0.011 0.0014" numOctaves="3" seed="21"/><feColorMatrix type="matrix" values="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1"/><feComponentTransfer><feFuncR type="linear" slope="3" intercept="-1"/><feFuncG type="linear" slope="3" intercept="-1"/><feFuncB type="linear" slope="3" intercept="-1"/></feComponentTransfer></filter>
<filter id="grain" x="0" y="0" width="100%" height="100%" color-interpolation-filters="sRGB"><feTurbulence type="fractalNoise" baseFrequency="1.1" numOctaves="2" seed="2"/><feColorMatrix type="matrix" values="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1"/></filter>
<filter id="caustic" x="0" y="0" width="100%" height="100%" color-interpolation-filters="sRGB"><feTurbulence type="turbulence" baseFrequency="0.011 0.02" numOctaves="2" seed="7"/><feColorMatrix type="matrix" values="0 0 0 0 1 0 0 0 0 1 0 0 0 0 .85 -7 0 0 0 1.05"/></filter>
<radialGradient id="spark"><stop offset="0" stop-color="#fffbe8"/><stop offset=".3" stop-color="#ffd98a" stop-opacity=".95"/><stop offset="1" stop-color="#ffb347" stop-opacity="0"/></radialGradient>
<radialGradient id="sparkC"><stop offset="0" stop-color="#ffffff"/><stop offset=".3" stop-color="#9ff3ff" stop-opacity=".95"/><stop offset="1" stop-color="#4fd6ff" stop-opacity="0"/></radialGradient>
<radialGradient id="vig" cx=".5" cy=".5" r=".75"><stop offset=".55" stop-color="#020814" stop-opacity="0"/><stop offset="1" stop-color="#020814" stop-opacity="1"/></radialGradient>
<linearGradient id="fishBody" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ff5f1f"/><stop offset=".5" stop-color="#ff9433"/><stop offset="1" stop-color="#ffd476"/></linearGradient>
<linearGradient id="fishTail" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#ff7a2e"/><stop offset="1" stop-color="#ffb347" stop-opacity=".75"/></linearGradient>
<clipPath id="frame"><rect width="800" height="600"/></clipPath>
'''

FISH = '<g transform="translate(-50 -30)"><path d="M78 30 L104 4 C97 22 97 40 104 60 L78 34 Z" fill="url(#fishTail)"/><path d="M34 11 C44 -7 62 -3 70 15 Z" fill="#ff7226"/><path d="M4 31 C18 4 62 2 82 28 C84 31 84 33 82 36 C62 60 18 58 4 31 Z" fill="url(#fishBody)"/><path d="M32 42 C38 56 50 56 56 46 Z" fill="#ffa64d"/><path d="M14 21 C26 10 52 9 68 20" fill="none" stroke="#fff3c4" stroke-width="3.5" stroke-linecap="round" opacity=".75"/><circle cx="18" cy="27" r="5" fill="#1b1030"/><circle cx="19.6" cy="25.4" r="1.7" fill="#fff"/></g>'
WHALE = "M0 40 C30 10 110 0 180 14 C230 24 262 34 286 30 C296 20 306 8 322 4 C318 20 316 30 310 40 C318 50 324 62 330 78 C312 70 298 58 288 46 C250 64 190 78 130 76 C80 76 30 66 0 40 Z M110 66 C120 96 150 112 176 114 C160 98 150 82 150 68 Z"

class S:
    def __init__(s, seed, lx, ly, raylen=1050):
        s.r = random.Random(seed); s.n = 0; s.body = []; s.lx, s.ly = lx, ly
        s.defs = [COMMON, f'<radialGradient id="rayG" gradientUnits="userSpaceOnUse" cx="{lx}" cy="{ly}" r="{raylen}"><stop offset="0" stop-color="#f4fff8" stop-opacity="1"/><stop offset=".5" stop-color="#cffff2" stop-opacity=".42"/><stop offset="1" stop-color="#cffff2" stop-opacity="0"/></radialGradient>']
    def uid(s): s.n += 1; return f'u{s.n}'
    def add(s, x): s.body.append(x); return s
    def lin(s, stops, x1=0, y1=0, x2=0, y2=1, units=''):
        i = s.uid(); st = ''.join(f'<stop offset="{o}" stop-color="{c}" stop-opacity="{a}"/>' for o, c, a in stops)
        s.defs.append(f'<linearGradient id="{i}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" {units}>{st}</linearGradient>'); return f'url(#{i})'
    def rad(s, stops, cx=.5, cy=.5, rr=.5, units=''):
        i = s.uid(); st = ''.join(f'<stop offset="{o}" stop-color="{c}" stop-opacity="{a}"/>' for o, c, a in stops)
        s.defs.append(f'<radialGradient id="{i}" cx="{cx}" cy="{cy}" r="{rr}" {units}>{st}</radialGradient>'); return f'url(#{i})'
    def clip(s, d):
        i = s.uid(); s.defs.append(f'<clipPath id="{i}"><path d="{d}"/></clipPath>'); return f'url(#{i})'
    def water(s, cols, stops, diag=False):
        fill = s.lin([(o, c, 1) for o, c in zip(stops, cols)], x2=(1 if diag else 0)); s.add(f'<rect width="{W}" height="{H}" fill="{fill}"/>')
    def bloom(s, x, y, rr, col, op, ry=None):
        fill = s.rad([(0, col, op), (.45, col, op * .45), (1, col, 0)]); s.add(f'<ellipse cx="{x}" cy="{y}" rx="{rr}" ry="{ry or rr}" fill="{fill}" style="mix-blend-mode:screen"/>')
    def rays(s, angs, length, op, bl='b6'):
        out = ''
        for a, w in angs:
            a1 = math.radians(a - w / 2); a2 = math.radians(a + w / 2)
            out += f'<polygon points="{s.lx},{s.ly} {s.lx+length*math.sin(a1):.0f},{s.ly+length*math.cos(a1):.0f} {s.lx+length*math.sin(a2):.0f},{s.ly+length*math.cos(a2):.0f}" fill="url(#rayG)"/>'
        s.add(f'<g filter="url(#{bl})" opacity="{op}" style="mix-blend-mode:screen">{out}</g>')
    def particles(s, n, big=10, region=(0, 0, W, H), grad='spark', sizes=(2.5, 9)):
        r = s.r; out = ''; x0, y0, x1, y1 = region
        for i in range(n):
            rad = r.uniform(*sizes) * (r.random() ** 1.5 * .9 + .25)
            out += f'<circle cx="{r.uniform(x0, x1):.0f}" cy="{r.uniform(y0, y1):.0f}" r="{rad:.1f}" fill="url(#{grad})" opacity="{r.uniform(.5, 1):.2f}"/>'
        for i in range(big):
            out += f'<circle cx="{r.uniform(x0, x1):.0f}" cy="{r.uniform(y0, y1):.0f}" r="{r.uniform(12, 30):.0f}" fill="url(#{grad})" opacity="{r.uniform(.12, .3):.2f}"/>'
        s.add(f'<g style="mix-blend-mode:screen">{out}</g>')
    def finish(s, mott=.55, streak=.2, grain=.06, vig=.6):
        s.add(f'<rect width="{W}" height="{H}" filter="url(#mottle)" style="mix-blend-mode:soft-light" opacity="{mott}"/>')
        if streak: s.add(f'<g transform="rotate(16 400 300)" style="mix-blend-mode:soft-light" opacity="{streak}"><rect x="-200" y="-250" width="1200" height="1100" filter="url(#streak)"/></g>')
        s.add(f'<rect width="{W}" height="{H}" fill="url(#vig)" opacity="{vig}"/>')
        s.add(f'<rect width="{W}" height="{H}" filter="url(#grain)" style="mix-blend-mode:overlay" opacity="{grain}"/>')
    def svg(s):
        return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}"><defs>{"".join(s.defs)}</defs><g clip-path="url(#frame)">{"".join(s.body)}</g></svg>'

def kelp(r, x, w, col, blade=(50, 110), bw=(10, 20), step=(30, 55), lean=None, rim=None, top=-40, bot=620):
    lean = r.uniform(-40, 40) if lean is None else lean
    c1 = r.uniform(-25, 25); c2 = r.uniform(-25, 25)
    xs = [x, x + c1, x + lean + c2, x + lean]
    def cx(t):
        m = 1 - t; return m**3 * xs[0] + 3 * m * m * t * xs[1] + 3 * m * t * t * xs[2] + t**3 * xs[3]
    d = f'M{xs[0]:.0f} {bot} C{xs[1]:.0f} {bot+(top-bot)/3:.0f} {xs[2]:.0f} {bot+(top-bot)*2/3:.0f} {xs[3]:.0f} {top}'
    out = f'<path d="{d}" fill="none" stroke="{col}" stroke-width="{w}" stroke-linecap="round"/>'
    if rim: out += f'<path d="{d}" transform="translate({w*.42:.0f} 0)" fill="none" stroke="{rim}" stroke-width="{max(1.5, w*.08):.1f}" opacity=".4"/>'
    y = bot - r.uniform(20, 60); side = 1
    while y > top + 10:
        t = (bot - y) / (bot - top); px = cx(t)
        l = r.uniform(*blade); b = r.uniform(*bw); ang = -90 + side * r.uniform(35, 75)
        tr = f'transform="translate({px:.0f} {y:.0f}) rotate({ang:.0f})"'
        out += f'<path {tr} d="M0 0 C{l*.25:.0f} {-b:.0f} {l*.7:.0f} {-b*.9:.0f} {l:.0f} 0 C{l*.7:.0f} {b*.35:.0f} {l*.25:.0f} {b*.5:.0f} 0 0Z" fill="{col}"/>'
        if rim and side > 0: out += f'<path {tr} d="M2 -1 C{l*.25:.0f} {-b:.0f} {l*.7:.0f} {-b*.9:.0f} {l:.0f} 0" fill="none" stroke="{rim}" stroke-width="2" opacity=".4"/>'
        y -= r.uniform(*step); side = -side
    return out

def strand(r, x, y0, length, col, col2):
    amp = r.uniform(6, 12); segs = max(2, int(length / 40)); d = f'M{x} {y0} '
    for i in range(segs):
        yy = y0 + (i + 1) * length / segs; sx = x + (amp if i % 2 == 0 else -amp)
        d += f'Q{sx:.0f} {yy-length/segs/2:.0f} {x} {yy:.0f} '
    out = f'<path d="{d}" fill="none" stroke="{col}" stroke-width="5" stroke-linecap="round"/>'
    for i in range(segs):
        yy = y0 + (i + .5) * length / segs; side = 1 if i % 2 == 0 else -1
        l = r.uniform(24, 40); b = r.uniform(8, 12); ang = 90 - side * r.uniform(40, 60)
        out += f'<path transform="translate({x+side*amp*.5:.0f} {yy:.0f}) rotate({ang:.0f})" d="M0 0 C{l*.25:.0f} {-b:.0f} {l*.7:.0f} {-b*.9:.0f} {l:.0f} 0 C{l*.7:.0f} {b*.5:.0f} {l*.25:.0f} {b*.6:.0f} 0 0Z" fill="{col2 if i % 3 == 0 else col}"/>'
    return out

def hill(r, y0, amp, steps=7):
    pts = [(-20, y0 + r.uniform(-amp, amp))] + [(i * W / steps, y0 + r.uniform(-amp, amp)) for i in range(1, steps)] + [(W + 20, y0 + r.uniform(-amp, amp))]
    d = f'M{pts[0][0]:.0f} {pts[0][1]:.0f} '
    for i in range(1, len(pts) - 1):
        mx = (pts[i][0] + pts[i+1][0]) / 2; my = (pts[i][1] + pts[i+1][1]) / 2
        d += f'Q{pts[i][0]:.0f} {pts[i][1]:.0f} {mx:.0f} {my:.0f} '
    d += f'L{pts[-1][0]:.0f} {pts[-1][1]:.0f} '
    return d + f'L{W+20} {H+20} L-20 {H+20} Z', d

def fish(x, y, sc, ang, op=1, flip=False):
    return f'<g transform="translate({x:.0f} {y:.0f}) rotate({ang:.0f}) scale({-sc if flip else sc:.2f} {sc:.2f})" opacity="{op:.2f}">{FISH}</g>'

def school(r, n, pts, spread, size=(.14, .7), heading=0, flip=False):
    items = []
    for i in range(n):
        seg = r.random() * (len(pts) - 1); k = min(int(seg), len(pts) - 2); f = seg - k
        x = lerp(pts[k][0], pts[k+1][0], f) + r.gauss(0, spread); y = lerp(pts[k][1], pts[k+1][1], f) + r.gauss(0, spread * .6)
        z = r.random() ** 1.7
        items.append((z, x, y, lerp(size[0], size[1], z), heading + r.uniform(-14, 14)))
    items.sort()
    far = ''.join(fish(x, y, sc, a, .55 + .3 * z, flip) for z, x, y, sc, a in items if z < .3)
    near = ''.join(fish(x, y, sc, a, .8 + .2 * z, flip) for z, x, y, sc, a in items if z >= .3)
    return f'<g filter="url(#b1)">{far}</g>', near

def coral(r, x, y, base, tip, size, depth=4, width=13, ang=-90):
    out = []
    def br(x, y, a, l, w, d):
        x2 = x + l * math.cos(math.radians(a)); y2 = y + l * math.sin(math.radians(a))
        out.append(f'<path d="M{x:.0f} {y:.0f} L{x2:.0f} {y2:.0f}" stroke="{hexmix(base, tip, 1 - d / depth)}" stroke-width="{w:.1f}" stroke-linecap="round"/>')
        if d > 0:
            for k in range(r.choice([2, 2, 3])): br(x2, y2, a + r.uniform(-40, 40), l * r.uniform(.6, .8), w * .74, d - 1)
        else:
            out.append(f'<circle cx="{x2:.0f}" cy="{y2:.0f}" r="{w*.8:.1f}" fill="{hexmix(tip, "#ffffff", .45)}"/>')
    br(x, y, ang, size * .42, width, depth)
    c = ''.join(out)
    return f'<g filter="url(#b6)" opacity=".55" style="mix-blend-mode:screen">{c}</g>{c}'

def mound(s, x, y, rx, ry, c1, c2):
    fill = s.rad([(0, hexmix(c1, '#ffffff', .4), 1), (.5, c1, 1), (1, c2, 1)], cx=.62, cy=.2, rr=.95)
    out = f'<path d="M{x-rx} {y} A{rx} {ry} 0 0 1 {x+rx} {y} Z" fill="{fill}"/>'
    for i in range(1, 5):
        k = .2 * i
        out += f'<path d="M{x-rx*k:.0f} {y} A{rx*k:.0f} {ry*k:.0f} 0 0 1 {x+rx*k:.0f} {y}" fill="none" stroke="{c2}" stroke-width="2.5" opacity=".55" stroke-dasharray="9 6" stroke-linecap="round"/>'
    return out

def rock(s, cx, cy, w, h, col, lit, n=8, side=1):
    r = s.r; pts = []
    for i in range(n):
        a = math.pi + math.pi * i / (n - 1); k = r.uniform(.8, 1.08)
        pts.append((cx + w / 2 * k * math.cos(a), cy + h * k * math.sin(a)))
    d = 'M' + ' L'.join(f'{x:.0f} {y:.0f}' for x, y in pts) + 'Z'
    m = n // 2
    lp = (pts[m-1:] if side > 0 else pts[:m+1]) + [(cx + side * w * .08, cy)]
    d2 = 'M' + ' L'.join(f'{x:.0f} {y:.0f}' for x, y in lp) + 'Z'
    return f'<path d="{d}" fill="{col}" stroke="{col}" stroke-width="6" stroke-linejoin="round"/><path d="{d2}" fill="{lit}" opacity=".6"/>'

def seastar(x, y, R, col, rot=-90):
    lite = hexmix(col, '#ffffff', .5)
    out = f'<polygon points="{star(x, y, R, R*.45, rot)}" fill="{col}" stroke="{col}" stroke-width="{R*.3:.1f}" stroke-linejoin="round"/>'
    for i in range(5):
        a = math.radians(rot + i * 72)
        out += f'<circle cx="{x+R*.5*math.cos(a):.1f}" cy="{y+R*.5*math.sin(a):.1f}" r="{R*.09:.1f}" fill="{lite}"/>'
    return out + f'<circle cx="{x}" cy="{y}" r="{R*.13:.1f}" fill="{lite}"/>'

def grass(r, x, y, n, hmin, hmax, col, col2):
    out = ''
    for i in range(n):
        h = r.uniform(hmin, hmax); dx = r.uniform(-18, 18); bx = x + r.uniform(-14, 14); w = r.uniform(5, 9)
        out += f'<path d="M{bx-w/2:.0f} {y} Q{bx+dx*.3:.0f} {y-h*.6:.0f} {bx+dx:.0f} {y-h:.0f} Q{bx+dx*.3+w:.0f} {y-h*.5:.0f} {bx+w/2:.0f} {y}Z" fill="{r.choice([col, col2])}"/>'
    return out

RIM = '#7fe9e0'

def scene_main():
    s = S(7, 700, -80); r = s.r
    s.water(['#93eadf', '#2ea6b6', '#0f6686', '#083a5e', '#051c38'], [0, .2, .48, .8, 1])
    s.bloom(690, -20, 520, '#eafff8', .95)
    far = ''.join(kelp(r, x + r.uniform(-20, 20), 7, '#43b3bf', (34, 64), (7, 12), (24, 42)) for x in (110, 235, 350, 470, 585, 690))
    s.add(f'<g filter="url(#b3)" opacity=".7">{far}</g>')
    s.rays([(-54, 7), (-42, 4), (-31, 9), (-19, 5), (-9, 6), (3, 4)], 1050, .55)
    mid = ''.join(kelp(r, x, 13, '#0f6582', (50, 95), (10, 18), (30, 50)) for x in (175, 430, 615))
    s.add(f'<g filter="url(#paintS)">{mid}</g>')
    ff, nf = school(r, 50, [(860, 30), (620, 110), (360, 90), (120, 150), (-30, 260)], 52, size=(.14, .62), heading=-12)
    s.add(ff)
    d, top = hill(r, 548, 14); s.add(f'<path d="{d}" fill="#0a4664" filter="url(#b1)"/>')
    near = kelp(r, -6, 42, '#052038', (90, 170), (20, 36), (40, 70), lean=30, rim=RIM) + kelp(r, 62, 20, '#06263f', (70, 130), (16, 28), (36, 60), lean=-20, rim=RIM) + kelp(r, 746, 24, '#06263f', (70, 130), (16, 28), (36, 60), lean=24, rim=RIM) + kelp(r, 812, 46, '#052038', (90, 170), (20, 36), (40, 70), lean=-36, rim=RIM)
    s.add(f'<g filter="url(#paint)">{near}</g>')
    d, top = hill(r, 580, 10); s.add(f'<path d="{d}" fill="#041628"/><path d="{top}" fill="none" stroke="{RIM}" stroke-width="2.5" opacity=".45" filter="url(#b1)"/>')
    s.add(nf); s.particles(170, 16, sizes=(3, 10)); s.finish()
    return s.svg()

def scene_coral():
    s = S(31, 680, -80); r = s.r
    s.water(['#86e6de', '#2798ae', '#0e5d80', '#0b3562', '#0a1a40'], [0, .2, .48, .8, 1])
    s.bloom(670, -20, 500, '#eafff8', .9)
    far = ''.join(kelp(r, x + r.uniform(-20, 20), 7, '#3fa9b8', (34, 64), (7, 12), (24, 42)) for x in (90, 260, 420, 560, 720))
    s.add(f'<g filter="url(#b3)" opacity=".6">{far}</g>')
    s.rays([(-56, 6), (-44, 5), (-32, 8), (-20, 4), (-8, 7), (4, 4)], 1050, .5)
    s.add(f'<g filter="url(#b3)" opacity=".8">{rock(s, 120, 560, 300, 150, "#12627f", "#2c93a6")}{rock(s, 690, 570, 340, 170, "#12627f", "#2c93a6")}</g>')
    ff, nf = school(r, 26, [(820, 250), (520, 300), (260, 330), (-20, 420)], 46, size=(.16, .62), heading=-10)
    s.add(ff)
    d, top = hill(r, 560, 12); s.add(f'<path d="{d}" fill="#0b3c5e"/>')
    cor = coral(r, 34, 590, '#b23a2a', '#ffb347', 170, 4, 16, -84) + coral(r, 120, 600, '#b03070', '#ff9ecb', 120, 4, 12, -96) + coral(r, 190, 606, '#5a3aa8', '#c9a8ff', 90, 3, 10, -80)
    cor += coral(r, 770, 590, '#5a3aa8', '#d2b4ff', 170, 4, 16, -96) + coral(r, 690, 602, '#b23a2a', '#ffb347', 120, 4, 12, -84) + coral(r, 618, 608, '#b03070', '#ff9ecb', 86, 3, 10, -98)
    s.add(cor)
    s.add(mound(s, 268, 604, 46, 40, '#35c6a8', '#12788c') + mound(s, 540, 606, 42, 36, '#ffb347', '#c9562b'))
    s.add(grass(r, 330, 606, 7, 30, 64, '#1f9c7c', '#35c6a8') + grass(r, 470, 606, 7, 26, 56, '#1f9c7c', '#35c6a8'))
    d, top = hill(r, 592, 5); s.add(f'<path d="{d}" fill="#041628"/><path d="{top}" fill="none" stroke="{RIM}" stroke-width="2" opacity=".4" filter="url(#b1)"/>')
    s.add(nf); s.particles(160, 14, sizes=(3, 10)); s.finish()
    return s.svg()

def scene_tide():
    s = S(53, 330, -220, 1000); r = s.r
    s.water(['#dafcf0', '#86e3d4', '#34adb9', '#1b819d', '#136181'], [0, .1, .4, .75, 1])
    s.bloom(330, -40, 520, '#ffffff', .9, 320)
    s.add('<path d="M-20 -20 L820 -20 L820 26 C740 44 690 14 610 30 C520 48 470 16 380 32 C300 46 240 18 160 34 C100 46 40 26 -20 38 Z" fill="#f4fff9" opacity=".85" filter="url(#b3)"/>')
    s.add('<path d="M-20 46 C60 32 110 60 190 48 C270 36 330 64 410 52 C500 38 560 66 640 52 C710 40 770 60 820 48" fill="none" stroke="#ffffff" stroke-width="5" opacity=".55" filter="url(#b1)"/>')
    s.add(f'<g filter="url(#b3)" opacity=".7">{rock(s, 90, 470, 300, 110, "#3fb0bb", "#74d6d2", side=-1)}{rock(s, 700, 474, 340, 130, "#3fb0bb", "#74d6d2", side=-1)}{rock(s, 420, 470, 180, 50, "#48b9c0", "#7adad5", side=-1)}</g>')
    s.rays([(-30, 5), (-18, 7), (-6, 4), (6, 8), (18, 5), (30, 6), (42, 4)], 1000, .55)
    ff, nf = school(r, 12, [(800, 250), (640, 290), (560, 330)], 34, size=(.12, .3), heading=-8)
    s.add(ff + nf)
    d1, top1 = hill(r, 468, 9)
    s.add(f'<path d="{d1}" fill="{s.lin([(0, "#f7e6ba", 1), (1, "#d2ad78", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(d1)}"><rect width="{W}" height="{H}" filter="url(#caustic)" opacity=".55" style="mix-blend-mode:screen"/></g>')
    s.add(rock(s, 50, 540, 210, 120, '#2b6f88', '#5fc0c6', side=-1) + rock(s, 150, 566, 120, 60, '#357f96', '#6accce', side=-1) + rock(s, 766, 546, 220, 140, '#2b6f88', '#5fc0c6', side=-1) + rock(s, 660, 574, 110, 54, '#357f96', '#6accce', side=-1))
    s.add(grass(r, 18, 556, 8, 40, 96, '#1f9c7c', '#3fc79a') + grass(r, 208, 580, 6, 24, 54, '#1f9c7c', '#3fc79a') + grass(r, 716, 572, 8, 36, 88, '#1f9c7c', '#3fc79a') + grass(r, 792, 560, 6, 40, 90, '#1f9c7c', '#3fc79a'))
    d2, top2 = hill(r, 566, 7)
    s.add(f'<path d="{d2}" fill="{s.lin([(0, "#fbeecd", 1), (1, "#c79f6c", 1)])}"/>')
    s.add(seastar(262, 560, 19, '#ff7fa6', -80) + seastar(590, 572, 16, '#ffa24a', -100) + seastar(470, 588, 11, '#ff8f6b', -70))
    for x, y in ((360, 580), (520, 566)):
        s.add(f'<path d="M{x-14} {y} A14 14 0 0 1 {x+14} {y} Z" fill="#fff4dc" stroke="#e8c79a" stroke-width="1.5"/><path d="M{x} {y} L{x-9} {y-10} M{x} {y} L{x} {y-14} M{x} {y} L{x+9} {y-10}" stroke="#e8c79a" stroke-width="1.5"/>')
    s.add(''.join(bubble(x + r.uniform(-8, 8), y, rr) for x, y, rr in ((96, 420, 9), (104, 360, 6), (90, 300, 8), (100, 250, 4), (724, 400, 8), (716, 330, 5), (730, 270, 7), (722, 210, 4))))
    s.particles(70, 8, sizes=(2, 7)); s.finish(mott=.4, streak=.28, vig=.35)
    return s.svg()

def scene_map():
    s = S(71, 60, -90, 1100); r = s.r
    s.water(['#9ff1e3', '#33adba', '#0f6283', '#0a2f5a', '#050c22'], [0, .24, .5, .76, 1], diag=True)
    s.bloom(70, -30, 520, '#f0fffa', .9)
    arch = '<path d="M250 420 C250 300 270 220 320 200 C360 186 400 220 404 280 C408 330 400 380 410 420 L372 420 C366 380 372 330 356 300 C340 276 312 290 304 330 C298 366 300 394 296 420 Z" fill="#2796aa"/><path d="M520 420 C524 330 540 250 566 200 C580 250 590 330 600 420 Z" fill="#1f86a0"/><path d="M620 420 C626 360 640 300 664 268 C676 310 690 364 700 420 Z" fill="#1a7896"/><path d="M60 420 C70 360 90 320 120 300 C150 330 170 370 180 420 Z" fill="#35a9b6"/>'
    s.add(f'<g filter="url(#b3)" opacity=".75">{arch}</g>')
    s.add(f'<g transform="translate(456 126) rotate(-7) scale(1.02)" filter="url(#b1)" opacity=".55"><path d="{WHALE}" fill="#4fb3cf"/></g>')
    s.particles(26, 0, region=(470, 110, 780, 230), sizes=(1.5, 5))
    s.rays([(14, 6), (27, 4), (39, 8), (52, 5), (66, 7)], 1100, .5)
    d, top = hill(r, 438, 16); s.add(f'<path d="{d}" fill="{s.lin([(0, "#147191", 1), (1, "#0a3c62", 1)], x2=1)}" filter="url(#b1)"/>')
    s.add('<ellipse cx="176" cy="398" rx="170" ry="34" fill="#f7e6ba" opacity=".55" filter="url(#b6)"/>')
    s.add('<path d="M150 400 C250 350 330 520 440 500 C540 484 580 560 700 570" fill="none" stroke="#f7e7b8" stroke-width="44" opacity=".16" filter="url(#b6)" stroke-linecap="round"/>')
    s.add('<path d="M150 400 C250 350 330 520 440 500 C540 484 580 560 700 570" fill="none" stroke="#ffd98a" stroke-width="5" stroke-dasharray="1 17" stroke-linecap="round" opacity=".95"/>')
    s.add(rock(s, 70, 420, 120, 60, '#2b7f96', '#6accce', side=-1) + rock(s, 282, 414, 90, 44, '#2b7f96', '#6accce', side=-1) + seastar(128, 410, 15, '#ff7fa6', -80) + seastar(232, 404, 11, '#ffa24a', -100) + grass(r, 40, 424, 6, 26, 60, '#1f9c7c', '#3fc79a'))
    cor = coral(r, 318, 548, '#b23a2a', '#ffb347', 110, 4, 12, -98) + coral(r, 360, 556, '#b03070', '#ff9ecb', 74, 3, 9, -84) + coral(r, 574, 536, '#5a3aa8', '#d2b4ff', 104, 4, 12, -82) + coral(r, 534, 548, '#b23a2a', '#ffb347', 70, 3, 9, -96)
    s.add(cor + mound(s, 448, 560, 40, 30, '#35c6a8', '#12788c'))
    ff, nf = school(r, 22, [(640, 260), (480, 250), (330, 300)], 30, size=(.12, .4), heading=-6)
    s.add(ff + nf)
    s.add('<path d="M560 620 C580 560 620 540 650 500 C690 470 740 480 820 430 L820 620 Z" fill="#030a1c"/><path d="M560 620 C580 560 620 540 650 500 C690 470 740 480 820 430" fill="none" stroke="#5a8fd0" stroke-width="2" opacity=".5" filter="url(#b1)"/>')
    near = kelp(r, -8, 34, '#052038', (80, 150), (18, 32), (40, 66), lean=26, rim=RIM, top=120) + kelp(r, 46, 16, '#06263f', (60, 110), (14, 24), (34, 56), lean=-14, rim=RIM, top=260)
    s.add(f'<g filter="url(#paint)">{near}</g>')
    d, top = hill(r, 588, 6); s.add(f'<path d="{d}" fill="#030c1e"/>')
    s.particles(70, 8)
    s.particles(90, 8, region=(520, 380, 800, 600))
    s.particles(30, 0, region=(540, 420, 800, 600), grad='sparkC', sizes=(1.5, 5))
    s.finish(vig=.5)
    return s.svg()

def scene_chest():
    s = S(89, 400, 372, 520); r = s.r
    s.water(['#040a1e', '#0a1f44', '#123d66', '#1d5578'], [0, .4, .8, 1])
    veil = '<path d="M-40 60 C120 -20 260 180 420 90 C560 10 700 120 860 30 L860 -40 L-40 -40 Z" fill="#59c9ff" opacity=".55"/><path d="M-40 160 C140 80 300 260 470 160 C620 70 720 200 860 130 L860 60 C700 130 600 20 440 100 C280 180 140 0 -40 90 Z" fill="#8fe6ff" opacity=".48"/><path d="M-40 250 C120 190 280 320 460 240 C620 170 740 270 860 220 L860 170 C720 220 600 120 450 190 C290 260 130 130 -40 190 Z" fill="#59c9ff" opacity=".28"/>'
    s.add(f'<g filter="url(#b12)" style="mix-blend-mode:screen">{veil}</g>')
    lines = ''.join(f'<path d="M-40 {150+k*14} C140 {70+k*16} 300 {250+k*12} 470 {150+k*14} C620 {60+k*16} 720 {190+k*12} 860 {120+k*14}" fill="none" stroke="{c}" stroke-width="{w}" opacity="{o}"/>' for k, c, w, o in ((-4, '#dff6ff', 1.6, .45), (1.5, '#ffd98a', 1.4, .5)))
    s.add(f'<g filter="url(#b1)" style="mix-blend-mode:screen">{lines}</g>')
    s.bloom(400, 350, 360, '#ffcf7a', .75)
    fan = s.lin([(0, '#fff3c4', .9), (.6, '#ffd27a', .3), (1, '#ffd27a', 0)], x1=0, y1=1, x2=0, y2=0)
    s.add(f'<g filter="url(#b12)" style="mix-blend-mode:screen"><polygon points="320,372 480,372 640,40 160,40" fill="{fan}" opacity=".7"/><polygon points="370,372 430,372 470,40 330,40" fill="{fan}" opacity=".6"/></g>')
    far = kelp(r, 40, 16, '#06142c', (60, 110), (14, 24), (34, 56), lean=20, top=180) + kelp(r, 770, 18, '#06142c', (60, 110), (14, 24), (34, 56), lean=-24, top=150) + kelp(r, 120, 9, '#0a2444', (40, 70), (9, 14), (26, 40), top=300) + kelp(r, 690, 9, '#0a2444', (40, 70), (9, 14), (26, 40), top=280)
    s.add(f'<g filter="url(#paintS)">{far}</g>')
    ff, nf = school(r, 9, [(700, 300), (620, 330)], 30, size=(.12, .3), heading=-6)
    s.add(ff + nf)
    d, top = hill(r, 486, 10); s.add(f'<path d="{d}" fill="{s.lin([(0, "#0b2038", 1), (1, "#030a18", 1)])}"/><path d="{top}" fill="none" stroke="#ffcf7a" stroke-width="2.5" opacity=".5" filter="url(#b1)"/>')
    s.add('<ellipse cx="400" cy="492" rx="210" ry="26" fill="#ffcf7a" opacity=".35" filter="url(#b12)"/>')
    # chest
    lid = 'M298 374 C292 300 338 258 400 258 C462 258 508 300 502 374 Z'
    s.add(f'<path d="{lid}" fill="{s.lin([(0, "#3a1414", 1), (1, "#7a2f22", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(lid)}"><ellipse cx="400" cy="384" rx="120" ry="80" fill="#ffd27a" opacity=".75" filter="url(#b12)"/><path d="M330 372 L352 268 M400 372 L400 258 M470 372 L448 268" stroke="#2a0c0c" stroke-width="2" opacity=".5"/></g>')
    s.add(f'<path d="{lid}" fill="none" stroke="#6a3c1a" stroke-width="14" stroke-linejoin="round"/><path d="{lid}" fill="none" stroke="#ffd27a" stroke-width="4" stroke-linejoin="round"/>')
    s.add('<path d="M350 372 C348 318 360 284 372 264" fill="none" stroke="#e0aa42" stroke-width="9"/><path d="M450 372 C452 318 440 284 428 264" fill="none" stroke="#e0aa42" stroke-width="9"/>')
    s.add('<ellipse cx="400" cy="366" rx="100" ry="34" fill="#fff3c4" filter="url(#b6)"/>')
    s.add('<ellipse cx="400" cy="378" rx="96" ry="20" fill="#ffc94d"/>')
    coins = ''
    for i in range(15):
        x = 316 + i * 12 + r.uniform(-3, 3); y = 368 - 10 * math.sin(math.pi * i / 14) + r.uniform(-3, 3)
        coins += f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="11" ry="9" fill="#ffd866" stroke="#e09a1f" stroke-width="1.5"/><ellipse cx="{x-2:.0f}" cy="{y-2:.0f}" rx="5" ry="3.5" fill="#fff3c4" opacity=".8"/>'
    s.add(coins)
    pearl = s.rad([(0, '#ffffff', 1), (.6, '#fff1e2', 1), (1, '#e3c4a8', 1)], cx=.35, cy=.3, rr=.8)
    s.add(''.join(f'<circle cx="{x}" cy="{y}" r="{rr}" fill="{pearl}"/>' for x, y, rr in ((346, 362, 8), (378, 352, 9), (414, 354, 8), (446, 362, 9), (400, 344, 7), (430, 376, 5), (438, 388, 5), (442, 400, 5), (443, 412, 5), (441, 424, 5))))
    box = 'M296 380 L504 380 L494 474 L306 474 Z'
    s.add(f'<ellipse cx="400" cy="480" rx="130" ry="14" fill="#01060f" opacity=".6" filter="url(#b6)"/>')
    s.add(f'<path d="{box}" fill="{s.lin([(0, "#9a5a28", 1), (1, "#4a2410", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(box)}"><path d="M290 412 L510 412 M290 444 L510 444" stroke="#2f1508" stroke-width="2.5" opacity=".6"/><rect x="290" y="380" width="70" height="100" fill="#1a0a04" opacity=".45" filter="url(#b12)"/><rect x="470" y="380" width="40" height="100" fill="#ffcf7a" opacity=".25" filter="url(#b6)"/></g>')
    gold = s.lin([(0, '#fff0b0', 1), (.5, '#ffcf5a', 1), (1, '#c9882a', 1)])
    s.add(f'<path d="M288 370 L512 370 L508 392 L292 392 Z" fill="{gold}"/><path d="M304 458 L496 458 L494 476 L306 476 Z" fill="{gold}"/><path d="M332 392 L348 392 L350 458 L336 458 Z" fill="{gold}"/><path d="M452 392 L468 392 L464 458 L450 458 Z" fill="{gold}"/>')
    s.add(f'<rect x="383" y="388" width="34" height="42" rx="9" fill="{gold}" stroke="#a86a14" stroke-width="2"/><circle cx="400" cy="404" r="5.5" fill="#3a1a0a"/><path d="M396 406 L404 406 L402 420 L398 420 Z" fill="#3a1a0a"/>')
    s.add(''.join(f'<circle cx="{x}" cy="{y}" r="3.5" fill="#fff3c4"/>' for x, y in ((300, 381), (500, 381), (340, 381), (460, 381), (312, 467), (488, 467))))
    s.add(''.join(f'<ellipse cx="{x}" cy="{y}" rx="12" ry="5" fill="#ffd866" stroke="#e09a1f" stroke-width="1.5"/>' for x, y in ((262, 492), (284, 500), (530, 494), (552, 502), (246, 504))))
    # starfish lamp
    s.bloom(400, 176, 150, '#ffe08a', .95)
    sg = s.rad([(0, '#fffbe0', 1), (.45, '#ffd45e', 1), (1, '#ff9a3d', 1)])
    s.add(f'<polygon points="{star(400, 178, 58, 27, -90)}" fill="{sg}" stroke="#ffe9a8" stroke-width="9" stroke-linejoin="round"/>')
    for i in range(5):
        a = math.radians(-90 + i * 72)
        s.add(f'<circle cx="{400+30*math.cos(a):.1f}" cy="{178+30*math.sin(a):.1f}" r="3.6" fill="#fff8d6"/><circle cx="{400+44*math.cos(a):.1f}" cy="{178+44*math.sin(a):.1f}" r="2.6" fill="#fff8d6"/>')
    s.add('<circle cx="390" cy="176" r="4" fill="#7a3d12"/><circle cx="410" cy="176" r="4" fill="#7a3d12"/><path d="M392 186 Q400 194 408 186" fill="none" stroke="#7a3d12" stroke-width="3" stroke-linecap="round"/><circle cx="391.4" cy="174.6" r="1.4" fill="#fff"/><circle cx="411.4" cy="174.6" r="1.4" fill="#fff"/>')
    rl = ''.join(f'<path d="M{400+78*math.cos(math.radians(a)):.0f} {178+78*math.sin(math.radians(a)):.0f} L{400+104*math.cos(math.radians(a)):.0f} {178+104*math.sin(math.radians(a)):.0f}" stroke="#ffe9a8" stroke-width="4" stroke-linecap="round" opacity=".7"/>' for a in (-162, -18, 18, 54, 90, 126, 162))
    s.add(rl)
    s.particles(190, 16); s.particles(60, 0, region=(250, 80, 550, 380))
    s.finish(mott=.45, streak=0)
    return s.svg()

def scene_grotto():
    s = S(113, 400, -260, 1000); r = s.r
    s.add(f'<rect width="{W}" height="{H}" fill="{s.rad([(0, "#7fe6da", 1), (.35, "#1f93a6", 1), (.7, "#0c466a", 1), (1, "#061c3a", 1)], cx=.5, cy=.36, rr=.8)}"/>')
    back = '<path d="M150 620 C160 420 220 330 300 300 C330 380 330 500 320 620 Z" fill="#177f96"/><path d="M500 620 C490 480 500 370 540 310 C610 340 650 450 660 620 Z" fill="#177f96"/><path d="M330 620 C340 520 370 470 400 460 C440 470 470 520 480 620 Z" fill="#1c8ba0"/>'
    s.add(f'<g filter="url(#b3)" opacity=".7">{back}</g>')
    s.bloom(400, -10, 320, '#ffffff', .95)
    s.rays([(-13, 7), (-4, 5), (5, 8), (14, 5)], 1000, .7)
    d, top = hill(r, 520, 8)
    s.add(f'<path d="{d}" fill="{s.lin([(0, "#f1dcaa", 1), (1, "#9a7850", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(d)}"><rect width="{W}" height="{H}" filter="url(#caustic)" opacity=".35" style="mix-blend-mode:screen"/><ellipse cx="400" cy="530" rx="210" ry="50" fill="#fff6d8" opacity=".55" filter="url(#b12)"/></g>')
    # clam shell bed
    cx, cy = 520, 492
    ed = f'M{cx-112} {cy} '
    n = 8
    for i in range(n):
        a0 = math.pi + math.pi * i / n; a1 = math.pi + math.pi * (i + 1) / n; am = (a0 + a1) / 2
        ed += f'Q{cx+128*math.cos(am):.0f} {cy+118*math.sin(am):.0f} {cx+112*math.cos(a1):.0f} {cy+100*math.sin(a1):.0f} '
    ed += 'Z'
    s.add(f'<ellipse cx="{cx}" cy="{cy+44}" rx="130" ry="14" fill="#3a2a1a" opacity=".45" filter="url(#b6)"/>')
    s.add(f'<path d="{ed}" fill="{s.lin([(0, "#fff0fa", 1), (.6, "#f7b9e4", 1), (1, "#d98ac9", 1)])}" stroke="#c77ab8" stroke-width="3" stroke-linejoin="round"/>')
    s.add(''.join(f'<path d="M{cx} {cy} L{cx+106*math.cos(math.pi+math.pi*i/n):.0f} {cy+96*math.sin(math.pi+math.pi*i/n):.0f}" stroke="#d98ac9" stroke-width="3" opacity=".6"/>' for i in range(1, n)))
    s.add(f'<ellipse cx="{cx}" cy="{cy}" rx="112" ry="20" fill="#fff5fb"/><ellipse cx="{cx-10}" cy="{cy-5}" rx="88" ry="17" fill="{s.lin([(0, "#e3d4ff", 1), (1, "#b79cff", 1)])}"/><ellipse cx="{cx-30}" cy="{cy-10}" rx="40" ry="6" fill="#ffffff" opacity=".5"/>')
    s.add(f'<path d="M{cx-114} {cy} C{cx-110} {cy+66} {cx+110} {cy+66} {cx+114} {cy} C{cx+80} {cy+20} {cx-80} {cy+20} {cx-114} {cy} Z" fill="{s.lin([(0, "#f09fd8", 1), (1, "#9a4f9f", 1)])}"/>')
    s.add(''.join(f'<path d="M{cx+k*26} {cy+16} Q{cx+k*30} {cy+34} {cx+k*24} {cy+48}" fill="none" stroke="#7a3a82" stroke-width="2.5" opacity=".5"/>' for k in (-3, -2, -1, 0, 1, 2, 3)))
    s.add(f'<circle cx="{cx+66}" cy="{cy-12}" r="15" fill="{s.rad([(0, "#ffffff", 1), (.6, "#fff1e2", 1), (1, "#e3c4a8", 1)], cx=.35, cy=.3, rr=.8)}"/>')
    # walls
    lw = 'M-20 -20 L262 -20 C210 40 160 84 138 164 C118 244 146 300 108 384 C84 446 116 520 60 620 L-20 620 Z'
    rw = 'M820 -20 L548 -20 C600 50 656 74 674 152 C694 242 662 312 702 392 C726 452 698 530 746 620 L820 620 Z'
    s.add(f'<g filter="url(#paint)"><path d="{lw}" fill="#0b2c48"/><path d="{rw}" fill="#0b2c48"/><path d="{lw}" transform="translate(-34 0)" fill="#051426"/><path d="{rw}" transform="translate(34 0)" fill="#051426"/>')
    s.add('<path d="M262 -20 L300 70 L330 -20 Z M470 -20 L498 84 L548 -20 Z M190 -20 L214 54 L240 -20 Z M580 -20 L598 60 L620 -20 Z" fill="#051426"/></g>')
    s.add(f'<path d="M262 -20 C210 40 160 84 138 164 C118 244 146 300 108 384 C84 446 116 520 60 620" fill="none" stroke="{RIM}" stroke-width="3" opacity=".5" filter="url(#b1)"/><path d="M548 -20 C600 50 656 74 674 152 C694 242 662 312 702 392 C726 452 698 530 746 620" fill="none" stroke="{RIM}" stroke-width="3" opacity=".5" filter="url(#b1)"/>')
    # kelp curtain
    cur = ''.join(strand(r, x, 60 + r.uniform(0, 30), ln, '#27b592', '#5fe0b6') for x, ln in ((612, 300), (640, 350), (668, 320), (694, 270)))
    s.add(f'<g filter="url(#b6)" opacity=".5" style="mix-blend-mode:screen">{cur}</g>{cur}')
    # crystals
    def crystal(x, y, h, col, rot):
        return f'<g transform="translate({x} {y}) rotate({rot})"><path d="M0 0 L{-h*.2:.0f} {-h*.7:.0f} L0 {-h} L{h*.2:.0f} {-h*.7:.0f} Z" fill="{col}"/><path d="M0 0 L0 {-h} L{h*.2:.0f} {-h*.7:.0f} Z" fill="#ffffff" opacity=".45"/></g>'
    cr = crystal(96, 470, 60, '#8ff0ff', -14) + crystal(118, 478, 44, '#b79cff', 10) + crystal(76, 480, 36, '#8ff0ff', -32) + crystal(716, 470, 54, '#b79cff', 16) + crystal(738, 482, 38, '#8ff0ff', 34)
    s.add(f'<g filter="url(#b6)" style="mix-blend-mode:screen">{cr}</g>{cr}')
    # string lights
    lights = ''
    for (x0, y0), (x1, y1), sag in (((150, 96), (400, 60), 46), ((400, 60), (650, 96), 46)):
        s.add(f'<path d="M{x0} {y0} Q{(x0+x1)/2} {(y0+y1)/2+sag*2} {x1} {y1}" fill="none" stroke="#06182c" stroke-width="2"/>')
        for i in range(1, 8):
            t = i / 8; x = (1-t)**2*x0 + 2*(1-t)*t*(x0+x1)/2 + t*t*x1; y = (1-t)**2*y0 + 2*(1-t)*t*((y0+y1)/2+sag*2) + t*t*y1
            lights += f'<circle cx="{x:.0f}" cy="{y+6:.0f}" r="16" fill="url(#spark)" opacity=".9"/><circle cx="{x:.0f}" cy="{y+6:.0f}" r="4.5" fill="#fff6d8"/>'
    s.add(f'<g style="mix-blend-mode:screen">{lights}</g>')
    # starfish lamp hanging in the shaft
    s.add('<path d="M400 -20 L400 132" stroke="#06182c" stroke-width="2.5"/>')
    s.bloom(400, 176, 130, '#ffe08a', .95)
    sg = s.rad([(0, '#fffbe0', 1), (.45, '#ffd45e', 1), (1, '#ff9a3d', 1)])
    s.add(f'<polygon points="{star(400, 178, 44, 20, -90)}" fill="{sg}" stroke="#ffe9a8" stroke-width="7" stroke-linejoin="round"/>')
    s.add('<circle cx="392" cy="176" r="3.2" fill="#7a3d12"/><circle cx="408" cy="176" r="3.2" fill="#7a3d12"/><path d="M394 184 Q400 190 406 184" fill="none" stroke="#7a3d12" stroke-width="2.5" stroke-linecap="round"/>')
    s.particles(130, 12); s.finish(mott=.45, streak=.18, vig=.45)
    return s.svg()

SCENES = dict(bg_main=scene_main, bg_coral=scene_coral, bg_tide=scene_tide, bg_map=scene_map, bg_chest=scene_chest, bg_grotto=scene_grotto)

if __name__ == '__main__':
    for name in (sys.argv[1:] or SCENES):
        open(os.path.join(OUT, name + '.svg'), 'w').write(SCENES[name]())
    print('ok')
