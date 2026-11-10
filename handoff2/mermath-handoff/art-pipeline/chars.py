import math, os

OUT = os.path.join(os.path.dirname(__file__), 'out')
os.makedirs(OUT, exist_ok=True)

def lerp(a, b, t): return a + (b - a) * t
def hexmix(c1, c2, t):
    a = [int(c1[i:i+2], 16) for i in (1, 3, 5)]; b = [int(c2[i:i+2], 16) for i in (1, 3, 5)]
    return '#%02x%02x%02x' % tuple(round(lerp(x, y, t)) for x, y in zip(a, b))

BLUR = ''.join(f'<filter id="b{n}" x="-80%" y="-80%" width="260%" height="260%"><feGaussianBlur stdDeviation="{n}"/></filter>' for n in (2, 3, 6, 12, 30))

def star(cx, cy, R, r, rot=-90, n=5):
    pts = []
    for i in range(n * 2):
        rad = R if i % 2 == 0 else r
        a = math.radians(rot + i * 180 / n)
        pts.append(f'{cx+rad*math.cos(a):.1f},{cy+rad*math.sin(a):.1f}')
    return ' '.join(pts)

def glint(x, y, s, fill='#fff8dc', op=1):
    return f'<path d="M{x} {y-s} Q{x} {y} {x+s} {y} Q{x} {y} {x} {y+s} Q{x} {y} {x-s} {y} Q{x} {y} {x} {y-s}Z" fill="{fill}" opacity="{op}"/>'

def bubble(x, y, r):
    return (f'<circle cx="{x}" cy="{y}" r="{r}" fill="#ffffff" fill-opacity=".12" stroke="#e6fdff" stroke-width="{max(1.5, r*.2):.1f}" stroke-opacity=".9"/>'
            f'<path d="M{x-r*.5:.1f} {y-r*.2:.1f} A{r*.55:.1f} {r*.55:.1f} 0 0 1 {x-r*.1:.1f} {y-r*.55:.1f}" fill="none" stroke="#fff" stroke-width="{max(1.5, r*.18):.1f}" stroke-linecap="round" opacity=".9"/>')

def eye(cx, cy, iris, side):
    ox = cx + side * 21
    return f'''
<ellipse cx="{cx}" cy="{cy}" rx="18" ry="23" fill="#2a1a3c"/>
<ellipse cx="{cx}" cy="{cy+8}" rx="13.5" ry="13" fill="{iris}"/>
<ellipse cx="{cx}" cy="{cy+3}" rx="8" ry="10" fill="#170d24"/>
<circle cx="{cx+6}" cy="{cy-9}" r="7.5" fill="#fff"/>
<circle cx="{cx-7}" cy="{cy+11}" r="3.4" fill="#fff" opacity=".9"/>
<path d="M{cx-21} {cy-9} Q{cx} {cy-35} {cx+21} {cy-9}" fill="none" stroke="#2a1a3c" stroke-width="6" stroke-linecap="round"/>
<path d="M{ox} {cy-9} l{side*9} -7" stroke="#2a1a3c" stroke-width="5" stroke-linecap="round"/>
<path d="M{ox-side*5} {cy-16} l{side*7} -9" stroke="#2a1a3c" stroke-width="4" stroke-linecap="round"/>'''

def shell_top(cx, cy, r, fill, ridge):
    out = f'<path d="M{cx-r} {cy-2} A{r} {r} 0 0 1 {cx+r} {cy-2} L{cx+r*.36:.1f} {cy+r*.7:.1f} L{cx-r*.36:.1f} {cy+r*.7:.1f} Z" fill="{fill}"/>'
    for a in (-150, -120, -90, -60, -30):
        x = cx + r * math.cos(math.radians(a)); y = cy - 2 + r * math.sin(math.radians(a))
        out += f'<path d="M{cx} {cy+r*.6:.1f} L{x:.1f} {y:.1f}" stroke="{ridge}" stroke-width="1.8" opacity=".8"/>'
    return out

HEAD = "M208 234 C208 172 250 150 300 150 C350 150 392 172 392 234 C392 292 352 330 300 330 C248 330 208 292 208 234 Z"
TAIL = "M262 438 C244 480 246 540 262 600 C276 650 330 700 392 690 C430 686 460 664 474 628 L452 612 C442 640 420 652 394 652 C350 652 326 620 330 570 C334 530 344 480 338 438 Z"
FLUKE = "M455 612 C430 570 432 510 466 462 C492 500 506 552 500 592 C540 590 588 620 614 666 C560 672 508 660 474 630 Z"
BANGS = "M204 246 C196 182 240 138 300 138 C360 138 404 182 396 246 C388 224 372 206 350 196 C340 192 332 188 326 182 C300 202 262 208 236 208 C224 218 212 230 204 246 Z"
TORSO = "M252 356 C252 342 272 338 300 338 C328 338 348 342 348 356 C350 390 340 420 338 440 L262 440 C260 420 250 390 252 356 Z"
BACK_LONG = "M300 126 C368 122 414 168 412 238 C412 290 426 330 404 372 C398 350 384 338 368 336 L250 340 C244 380 250 410 236 450 C226 490 200 520 168 556 C176 520 170 500 150 492 C120 510 96 540 60 548 C88 520 96 490 92 462 C70 462 50 450 34 428 C70 420 96 380 108 330 C122 260 150 190 200 152 C230 132 266 128 300 126 Z"
BACK_BOB = "M300 126 C374 122 420 176 412 252 C410 296 398 326 372 344 L228 344 C202 326 190 296 188 252 C180 176 226 122 300 126 Z"

def mermaid(p, style):
    skinL, skin, skinS = p['skinL'], p['skin'], p['skinS']
    hair, hairD, hairT, hairL = p['hair'], p['hairD'], p['hairT'], p['hairL']
    ta, tb, fin, acc, accD, iris = p['ta'], p['tb'], p['fin'], p['acc'], p['accD'], p['iris']
    tbD = hexmix(tb, '#1a1040', .55)
    BACK = BACK_LONG if style == 'long' else BACK_BOB
    defs = BLUR + f'''
<radialGradient id="skinG" cx=".66" cy=".28" r=".9"><stop offset="0" stop-color="{skinL}"/><stop offset=".55" stop-color="{skin}"/><stop offset="1" stop-color="{skinS}"/></radialGradient>
<linearGradient id="tailG" x1=".1" y1="0" x2=".9" y2="1"><stop offset="0" stop-color="{ta}"/><stop offset=".55" stop-color="{hexmix(ta, tb, .6)}"/><stop offset="1" stop-color="{tb}"/></linearGradient>
<linearGradient id="finG" x1=".1" y1=".8" x2=".9" y2=".1"><stop offset="0" stop-color="{tb}"/><stop offset=".45" stop-color="{fin}" stop-opacity=".85"/><stop offset="1" stop-color="#ffffff" stop-opacity=".55"/></linearGradient>
<linearGradient id="hairG" x1=".85" y1="0" x2=".15" y2="1"><stop offset="0" stop-color="{hairL}"/><stop offset=".3" stop-color="{hair}"/><stop offset=".7" stop-color="{hairD}"/><stop offset="1" stop-color="{hairT}"/></linearGradient>
<linearGradient id="bangG" x1=".7" y1="0" x2=".3" y2="1"><stop offset="0" stop-color="{hairL}"/><stop offset=".6" stop-color="{hair}"/><stop offset="1" stop-color="{hairD}"/></linearGradient>
<radialGradient id="bunG" cx=".62" cy=".3" r=".8"><stop offset="0" stop-color="{hairL}"/><stop offset=".6" stop-color="{hair}"/><stop offset="1" stop-color="{hairD}"/></radialGradient>
<linearGradient id="accG" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{hexmix(acc, '#ffffff', .45)}"/><stop offset="1" stop-color="{acc}"/></linearGradient>
<pattern id="scales" width="26" height="22" patternUnits="userSpaceOnUse" patternTransform="rotate(-18)"><path d="M0 0 A13 13 0 0 0 26 0 M-13 11 A13 13 0 0 0 13 11 M13 11 A13 13 0 0 0 39 11" fill="none" stroke="#ffffff" stroke-width="2" opacity=".55"/></pattern>
<clipPath id="tailClip"><path d="{TAIL}"/></clipPath>
<clipPath id="headClip"><path d="{HEAD}"/></clipPath>
<clipPath id="torsoClip"><path d="{TORSO}"/></clipPath>
<clipPath id="backClip"><path d="{BACK}"/></clipPath>
<clipPath id="bangClip"><path d="{BANGS}"/></clipPath>
'''
    back = f'<path d="{BACK}" fill="url(#hairG)"/>'
    if style == 'long':
        back += f'''<g clip-path="url(#backClip)" fill="none" stroke-linecap="round">
<path d="M150 230 C110 300 96 380 60 440" stroke="{hairL}" stroke-width="7" opacity=".5"/>
<path d="M176 250 C150 330 140 420 90 520" stroke="{hairD}" stroke-width="6" opacity=".55"/>
<path d="M214 330 C196 400 178 450 130 500" stroke="{hairL}" stroke-width="6" opacity=".45"/>
<path d="M238 350 C232 420 212 480 180 540" stroke="{hairD}" stroke-width="5" opacity=".5"/>
<path d="M120 330 C110 380 92 420 50 436" stroke="{hairL}" stroke-width="5" opacity=".4"/>
<path d="M398 230 C402 280 412 320 404 362" stroke="{hairL}" stroke-width="6" opacity=".5"/>
</g>'''
    else:
        for bx in (208, 392):
            s = -1 if bx < 300 else 1
            back += f'''<circle cx="{bx}" cy="140" r="47" fill="url(#bunG)"/>
<path d="M{bx-26} 150 C{bx-22} 120 {bx+16} 112 {bx+24} 140 C{bx+28} 158 {bx+4} 168 {bx-4} 152 C{bx-8} 142 {bx+6} 136 {bx+8} 146" fill="none" stroke="{hairD}" stroke-width="4" stroke-linecap="round" opacity=".55"/>
<path d="M{bx-30} 122 C{bx-18} 102 {bx+12} 98 {bx+28} 112" fill="none" stroke="{hairL}" stroke-width="7" stroke-linecap="round" opacity=".7"/>
<ellipse cx="{bx-s*26}" cy="176" rx="17" ry="9" transform="rotate({s*-38} {bx-s*26} 176)" fill="{acc}"/>'''
    veins = ''.join(f'<path d="M466 620 Q{mx} {my} {x} {y}" fill="none" stroke="#fff" stroke-width="2" opacity=".4"/>' for mx, my, x, y in ((452, 560, 464, 492), (478, 580, 484, 536), (510, 610, 556, 632), (520, 626, 590, 656), (500, 634, 530, 652)))
    pearls = ''.join(f'<circle cx="{276+48*i/6:.1f}" cy="{347+9*math.sin(math.pi*i/6):.1f}" r="4.4" fill="#fff8ee" stroke="{skinS}" stroke-width=".8"/>' for i in range(7))
    body = f'''
<g transform="translate(30 40)">
{back}
<path d="M252 500 C224 506 204 530 200 558 C226 550 246 536 258 520 Z" fill="{fin}" opacity=".75"/>
<path d="{FLUKE}" fill="url(#finG)"/>
{veins}
<path d="{FLUKE}" fill="none" stroke="#ffffff" stroke-width="2.5" opacity=".6"/>
<path d="{TAIL}" fill="url(#tailG)"/>
<path d="{TAIL}" fill="url(#scales)" opacity=".5"/>
<g clip-path="url(#tailClip)" fill="none">
<path d="M262 438 C244 480 246 540 262 600 C276 650 330 700 392 690 C430 686 460 664 474 628" stroke="{tbD}" stroke-width="40" opacity=".5" filter="url(#b12)"/>
<path d="M452 612 C442 640 420 652 394 652 C350 652 326 620 330 570 C334 530 344 480 338 438" stroke="#ffffff" stroke-width="14" opacity=".55" filter="url(#b6)"/>
</g>
{glint(300, 520, 9, '#ffffff', .9)}{glint(318, 596, 7, '#ffffff', .8)}{glint(380, 668, 8, '#ffffff', .85)}{glint(286, 478, 5, '#ffffff', .8)}
<path d="M344 364 C372 382 392 400 386 420 C380 438 370 446 362 452" fill="none" stroke="{skinS}" stroke-width="25" stroke-linecap="round"/>
<path d="M345 362 C373 380 393 398 387 418 C381 436 371 444 363 450" fill="none" stroke="{skin}" stroke-width="20" stroke-linecap="round"/>
<circle cx="361" cy="453" r="14" fill="{skin}"/>
<path d="M256 364 C232 386 210 398 202 380 C196 364 190 346 186 328" fill="none" stroke="{skinS}" stroke-width="25" stroke-linecap="round"/>
<path d="M257 362 C233 384 211 396 203 378 C197 362 191 344 187 326" fill="none" stroke="{skin}" stroke-width="20" stroke-linecap="round"/>
<g stroke="{skin}" stroke-width="9" stroke-linecap="round"><path d="M185 322 L170 298"/><path d="M186 320 L184 292"/><path d="M188 321 L198 296"/><path d="M190 324 L208 312"/></g>
<circle cx="186" cy="322" r="15" fill="{skin}"/>
<path d="{TORSO}" fill="url(#skinG)"/>
<path d="M285 316 L315 316 L317 348 L283 348 Z" fill="{skin}"/>
<g clip-path="url(#torsoClip)"><ellipse cx="300" cy="342" rx="40" ry="13" fill="{skinS}" opacity=".7" filter="url(#b3)"/></g>
<ellipse cx="300" cy="332" rx="22" ry="9" fill="{skinS}" opacity=".7" filter="url(#b2)"/>
<path d="M258 432 C272 446 286 452 300 452 C314 452 328 446 342 432 L342 448 C328 464 314 470 300 470 C286 470 272 464 258 448 Z" fill="url(#accG)"/>
<circle cx="300" cy="461" r="6" fill="#fff8ee"/>
{shell_top(279, 394, 21, 'url(#accG)', accD)}{shell_top(321, 394, 21, 'url(#accG)', accD)}
<circle cx="300" cy="398" r="4" fill="#fff8ee"/>
{pearls}
<path d="{HEAD}" fill="url(#skinG)"/>
<g clip-path="url(#headClip)"><path d="{BANGS}" transform="translate(0 12)" fill="{skinS}" opacity=".6" filter="url(#b3)"/></g>
<ellipse cx="236" cy="286" rx="22" ry="13" fill="#ff6f7f" opacity=".38" filter="url(#b3)"/>
<ellipse cx="364" cy="286" rx="22" ry="13" fill="#ff6f7f" opacity=".38" filter="url(#b3)"/>
{eye(262, 254, iris, -1)}{eye(338, 254, iris, 1)}
<path d="M246 212 Q262 204 278 210" fill="none" stroke="{hairD}" stroke-width="4" stroke-linecap="round" opacity=".75"/>
<path d="M322 210 Q338 204 354 212" fill="none" stroke="{hairD}" stroke-width="4" stroke-linecap="round" opacity=".75"/>
<path d="M296 276 q4 4 8 0" fill="none" stroke="{skinS}" stroke-width="2.6" stroke-linecap="round"/>
<path d="M284 290 Q300 314 316 290 Q300 296 284 290 Z" fill="#a23b4a"/>
<ellipse cx="300" cy="303" rx="7" ry="3.6" fill="#ff8fa0"/>
<path d="M206 240 C194 266 196 296 212 320 C212 294 216 268 226 244 Z" fill="{hair}"/>
<path d="M394 240 C406 266 404 296 388 320 C388 294 384 268 374 244 Z" fill="{hair}"/>
<path d="{BANGS}" fill="url(#bangG)"/>
<g clip-path="url(#bangClip)"><path d="M232 176 C266 152 334 152 368 178" fill="none" stroke="#ffffff" stroke-width="10" stroke-linecap="round" opacity=".28" filter="url(#b2)"/>
<path d="M326 182 C300 202 262 208 236 208" fill="none" stroke="{hairD}" stroke-width="5" opacity=".5"/></g>
<polygon points="{star(368, 178, 23, 10.5, -70)}" fill="#ffd166" stroke="#ffd166" stroke-width="6" stroke-linejoin="round"/>
<polygon points="{star(368, 178, 11, 5, -70)}" fill="#fff3c4" opacity=".9"/>
{bubble(540, 330, 13)}{bubble(566, 292, 7)}{bubble(150, 110, 10)}{bubble(122, 150, 5)}{bubble(520, 420, 5)}
{glint(520, 480, 12)}{glint(430, 720, 9)}{glint(140, 600, 10)}{glint(590, 560, 7)}
</g>'''
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 680 780" width="680" height="780"><defs>{defs}</defs>{body}</svg>'

CAR = "M150 284 C150 204 220 172 300 172 C380 172 450 204 450 284 C450 346 388 388 300 388 C212 388 150 346 150 284 Z"

def claw(cx, cy, rot, r=58):
    lx = r * .44; ly = -r * .9
    return f'''<g transform="translate({cx} {cy}) rotate({rot}) scale(1 1.08)">
<path d="M{-lx:.1f} {ly:.1f} L0 -4 L{lx:.1f} {ly:.1f} A{r} {r} 0 1 1 {-lx:.1f} {ly:.1f} Z" fill="url(#shellG)" stroke="url(#shellG)" stroke-width="8" stroke-linejoin="round"/>
<path d="M{-lx:.1f} {ly:.1f} L0 -4 L{lx:.1f} {ly:.1f}" fill="none" stroke="#a82a1c" stroke-width="5" stroke-linejoin="round" stroke-linecap="round" opacity=".55"/>
<ellipse cx="22" cy="-6" rx="16" ry="24" transform="rotate(24 22 -6)" fill="#fff" opacity=".3" filter="url(#b6)"/>
<ellipse cx="-4" cy="34" rx="40" ry="14" fill="#a82a1c" opacity=".35" filter="url(#b6)"/>
</g>'''

def crab():
    defs = BLUR + f'''
<radialGradient id="shellG" cx=".4" cy=".22" r=".95"><stop offset="0" stop-color="#ffc07a"/><stop offset=".42" stop-color="#ff7f3f"/><stop offset="1" stop-color="#dc3f2a"/></radialGradient>
<radialGradient id="eyeG" cx=".6" cy=".35" r=".8"><stop offset="0" stop-color="#ffffff"/><stop offset=".7" stop-color="#f4fbff"/><stop offset="1" stop-color="#bcd6e8"/></radialGradient>
<clipPath id="carClip"><path d="{CAR}"/></clipPath>
<clipPath id="eyeL"><circle cx="246" cy="116" r="37"/></clipPath><clipPath id="eyeR"><circle cx="354" cy="116" r="37"/></clipPath>
'''
    legs = ''
    for side in (-1, 1):
        for (bx, by), (kx, ky), (fx, fy) in (((108, 352), (66, 16), (20, 56)), ((82, 370), (54, 40), (12, 52)), ((54, 380), (36, 54), (2, 46))):
            x0 = 300 + side * bx; x1 = x0 + side * kx; y1 = by + ky; x2 = x1 + side * fx; y2 = y1 + fy
            legs += f'<path d="M{x0} {by} Q{x1} {y1-22} {x1} {y1} T{x2} {y2}" fill="none" stroke="#b9341f" stroke-width="23" stroke-linecap="round" stroke-linejoin="round"/>'
            legs += f'<path d="M{x0} {by-3} Q{x1} {y1-25} {x1} {y1-3}" fill="none" stroke="#ff8a4c" stroke-width="8" stroke-linecap="round" opacity=".55"/>'
    body = f'''
<g transform="translate(20 30)">
<ellipse cx="300" cy="470" rx="190" ry="20" fill="#02101f" opacity=".4" filter="url(#b6)"/>
{legs}
<path d="M182 300 C132 304 100 272 108 226" fill="none" stroke="#c93b22" stroke-width="34" stroke-linecap="round"/>
<path d="M182 296 C136 298 108 270 114 230" fill="none" stroke="#ff8244" stroke-width="20" stroke-linecap="round"/>
<path d="M418 300 C474 296 510 252 502 200" fill="none" stroke="#c93b22" stroke-width="34" stroke-linecap="round"/>
<path d="M418 296 C470 290 502 250 496 204" fill="none" stroke="#ff8244" stroke-width="20" stroke-linecap="round"/>
<path d="M262 200 C258 172 254 160 250 146" fill="none" stroke="#d9472a" stroke-width="18" stroke-linecap="round"/>
<path d="M338 200 C342 172 346 160 350 146" fill="none" stroke="#d9472a" stroke-width="18" stroke-linecap="round"/>
<path d="{CAR}" fill="url(#shellG)"/>
<g clip-path="url(#carClip)">
<ellipse cx="300" cy="408" rx="190" ry="60" fill="#a82a1c" opacity=".6" filter="url(#b12)"/>
<path d="M300 172 C380 172 450 204 450 284" fill="none" stroke="#fff0c0" stroke-width="12" opacity=".55" filter="url(#b3)"/>
<ellipse cx="246" cy="216" rx="66" ry="22" transform="rotate(-12 246 216)" fill="#ffffff" opacity=".38" filter="url(#b6)"/>
</g>
<circle cx="372" cy="218" r="10" fill="#ffd2a0" opacity=".8"/><circle cx="398" cy="244" r="6.5" fill="#ffd2a0" opacity=".8"/><circle cx="350" cy="198" r="5" fill="#ffd2a0" opacity=".8"/><circle cx="206" cy="246" r="6" fill="#ffd2a0" opacity=".6"/>
{claw(100, 170, -24)}{claw(508, 140, 22)}
<circle cx="246" cy="116" r="37" fill="url(#eyeG)"/><circle cx="354" cy="116" r="37" fill="url(#eyeG)"/>
<g clip-path="url(#eyeL)"><circle cx="254" cy="122" r="20" fill="#1b1030"/><circle cx="262" cy="113" r="8" fill="#fff"/><circle cx="247" cy="131" r="3.6" fill="#fff" opacity=".9"/><rect x="200" y="70" width="100" height="22" fill="#ff7f3f"/></g>
<g clip-path="url(#eyeR)"><circle cx="346" cy="122" r="20" fill="#1b1030"/><circle cx="354" cy="113" r="8" fill="#fff"/><circle cx="339" cy="131" r="3.6" fill="#fff" opacity=".9"/><rect x="300" y="70" width="100" height="22" fill="#ff7f3f"/></g>
<circle cx="246" cy="116" r="37" fill="none" stroke="#d9472a" stroke-width="3" opacity=".5"/><circle cx="354" cy="116" r="37" fill="none" stroke="#d9472a" stroke-width="3" opacity=".5"/>
<ellipse cx="212" cy="300" rx="25" ry="14" fill="#ff3f6a" opacity=".4" filter="url(#b3)"/><ellipse cx="388" cy="300" rx="25" ry="14" fill="#ff3f6a" opacity=".4" filter="url(#b3)"/>
<path d="M266 288 Q300 336 334 288 Q300 298 266 288 Z" fill="#7a1f24"/>
<ellipse cx="300" cy="313" rx="13" ry="7" fill="#ff7d8f"/>
</g>'''
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 540" width="640" height="540"><defs>{defs}</defs>{body}</svg>'

def shell(c1, c2, cD):
    cx, cy, R, n = 130, 176, 104, 7
    a0, a1 = math.radians(196), math.radians(344)
    d = f'M{cx-24} {cy} '
    ridges = ''
    for i in range(n):
        s = a0 + (a1 - a0) * i / n; e = a0 + (a1 - a0) * (i + 1) / n; m = (s + e) / 2
        ps = (cx + R * math.cos(s), cy + R * math.sin(s)); pe = (cx + R * math.cos(e), cy + R * math.sin(e))
        pm = (cx + (R + 20) * math.cos(m), cy + (R + 20) * math.sin(m))
        if i == 0: d += f'L{ps[0]:.1f} {ps[1]:.1f} '
        d += f'Q{pm[0]:.1f} {pm[1]:.1f} {pe[0]:.1f} {pe[1]:.1f} '
        if i > 0: ridges += f'<path d="M{cx} {cy+2} L{ps[0]:.1f} {ps[1]:.1f}" stroke="{cD}" stroke-width="4" stroke-linecap="round" opacity=".55"/><path d="M{cx+3} {cy+2} L{ps[0]+4:.1f} {ps[1]+1:.1f}" stroke="#fff" stroke-width="2" stroke-linecap="round" opacity=".45"/>'
    d += f'L{cx+24} {cy} Z'
    defs = BLUR + f'<linearGradient id="g" x1=".8" y1="0" x2=".3" y2="1"><stop offset="0" stop-color="{hexmix(c1, "#ffffff", .5)}"/><stop offset=".45" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient><clipPath id="c"><path d="{d}"/></clipPath>'
    body = f'''<path d="M{cx-34} {cy-6} L{cx+34} {cy-6} L{cx+24} {cy+18} L{cx-24} {cy+18} Z" fill="{cD}" stroke="{cD}" stroke-width="6" stroke-linejoin="round"/>
<path d="{d}" fill="url(#g)" stroke="{c2}" stroke-width="3" stroke-linejoin="round"/>{ridges}
<g clip-path="url(#c)"><ellipse cx="176" cy="84" rx="46" ry="20" transform="rotate(28 176 84)" fill="#fff" opacity=".45" filter="url(#b6)"/><ellipse cx="110" cy="176" rx="90" ry="26" fill="{cD}" opacity=".45" filter="url(#b6)"/></g>'''
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 260 210" width="260" height="210"><defs>{defs}</defs>{body}</svg>'

SKIN = dict(skinL='#ffe6cf', skin='#f7c9a5', skinS='#dd9a78')
MERMAIDS = {
    'mermaid_a': (dict(SKIN, hair='#8a5230', hairD='#57301c', hairT='#b37be0', hairL='#c98a55', ta='#8b7bf5', tb='#ee7bc6', fin='#f7c6ff', acc='#ffc857', accD='#d48a1f', iris='#7c5cd6'), 'long'),
    'mermaid_b': (dict(SKIN, hair='#f1bd4a', hairD='#cf8f2a', hairT='#f6d27a', hairL='#ffe08a', ta='#3fe3c8', tb='#2f86f0', fin='#b9f6ff', acc='#ff9ecb', accD='#d95a96', iris='#1fae9e'), 'buns'),
    'mermaid_c': (dict(SKIN, hair='#4a3558', hairD='#2a1c38', hairT='#3a2848', hairL='#7a5c90', ta='#ffbd4a', tb='#ff5f74', fin='#ffe2a8', acc='#7fe6ff', accD='#2ba3c9', iris='#c0623a'), 'buns'),
}

if __name__ == '__main__':
    for name, (p, style) in MERMAIDS.items():
        open(os.path.join(OUT, name + '.svg'), 'w').write(mermaid(p, style))
    open(os.path.join(OUT, 'crab.svg'), 'w').write(crab())
    open(os.path.join(OUT, 'shell_orange.svg'), 'w').write(shell('#ffa24a', '#f0642a', '#b8431d'))
    open(os.path.join(OUT, 'shell_teal.svg'), 'w').write(shell('#63e6d6', '#1fa3b5', '#12788c'))
    print('ok')
