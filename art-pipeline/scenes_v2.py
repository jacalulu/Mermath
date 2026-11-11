"""The remaining Mermath scenes in the locked look, each drawn as named layers (same recipe as the Tide Pool and home scenes in frame.py)."""
import math, os
from scenes import W, H, kelp, hill, coral, mound, rock, seastar, grass, school, hexmix, strand
from chars import star
from frame import LS, boulder

SURFACE = ('<path d="M-20 -20 L820 -20 L820 26 C740 44 690 14 610 30 C520 48 470 16 380 32 C300 46 240 18 160 34 C100 46 40 26 -20 38 Z" fill="#f4fff9" opacity=".85" filter="url(#b3)"/>'
           '<path d="M-20 46 C60 32 110 60 190 48 C270 36 330 64 410 52 C500 38 560 66 640 52 C710 40 770 60 820 48" fill="none" stroke="#ffffff" stroke-width="5" opacity=".55" filter="url(#b1)"/>')
RAYS = [(-30, 5), (-18, 7), (-6, 4), (6, 8), (18, 5), (30, 6), (42, 4)]
SAND = [(0, '#f7e6ba', 1), (1, '#d6b27c', 1)]; SAND2 = [(0, '#fbeecd', 1), (1, '#c9a06c', 1)]

def open_water(s, cols=('#dcfcef', '#93e7d7', '#3db5be', '#1b86a1', '#12617f')):
    """The locked water: pale surface, teal depth, light from the upper left."""
    s.layer('bg'); s.water(list(cols), [0, .1, .38, .72, 1]); s.bloom(300, -40, 540, '#ffffff', .9, 330); s.add(SURFACE)

def sand(s, r, y, amp, fill, caustic=True):
    d, top = hill(r, y, amp); s.add(f'<path d="{d}" fill="{s.lin(fill)}"/>')
    if caustic: s.add(f'<g clip-path="{s.clip(d)}"><rect width="{W}" height="{H}" filter="url(#caustic)" opacity=".55" style="mix-blend-mode:screen"/></g>')

def shell_on_sand(x, y):
    return f'<path d="M{x-13} {y} A13 13 0 0 1 {x+13} {y} Z" fill="#fff4dc" stroke="#e8c79a" stroke-width="1.5"/><path d="M{x} {y} L{x-8} {y-9} M{x} {y} L{x} {y-13} M{x} {y} L{x+8} {y-9}" stroke="#e8c79a" stroke-width="1.5"/>'

def scene_coral_layers():
    """Coral Reef dive: the crab's rock on the left, open water behind the answers, bright coral in the bottom corners."""
    s = LS(419, 300, -230, 1000); r = s.r
    open_water(s)
    reef = coral(r, 330, 486, '#4fb3bb', '#9be5df', 150, 4, 13, -94) + coral(r, 470, 492, '#4fb3bb', '#9be5df', 120, 4, 11, -86) + coral(r, 600, 484, '#4fb3bb', '#9be5df', 160, 4, 13, -92)
    s.add(f'<g filter="url(#b3)" opacity=".5">{reef}</g>')
    far = ''.join(kelp(r, x + r.uniform(-12, 12), 6, '#6fd0cd', (30, 56), (6, 10), (22, 38)) for x in (250, 396, 540, 684))
    s.layer('kelp_far').add(f'<g filter="url(#b3)" opacity=".6">{far}</g>')
    d, top = hill(r, 462, 14); s.layer('bg').add(f'<path d="{d}" fill="#52bcc0" opacity=".7" filter="url(#b3)"/>')
    s.rays(RAYS, 1000, .5)
    s.layer('fan_left').add(f'<g filter="url(#paintS)">{coral(r, 44, 484, "#6a43b8", "#d9c2ff", 230, 5, 10, -86)}</g>')
    s.layer('fan_right').add(f'<g filter="url(#paintS)">{coral(r, 782, 520, "#b03070", "#ffb3d6", 118, 4, 9, -93)}</g>')
    s.layer('fg'); sand(s, r, 470, 8, SAND)
    s.add(boulder(s, 712, 548, 240, 96) + boulder(s, 590, 566, 110, 46, moss=False))
    s.add(coral(r, 738, 470, '#5a3aa8', '#d2b4ff', 150, 4, 17, -94) + coral(r, 668, 500, '#b23a2a', '#ffb347', 110, 4, 14, -80))
    s.add(boulder(s, 140, 486, 310, 100) + boulder(s, 300, 544, 120, 52, moss=False))
    s.add('<ellipse cx="140" cy="402" rx="96" ry="12" fill="#0d3a50" opacity=".5" filter="url(#b6)"/>')
    sand(s, r, 566, 6, SAND2, caustic=False)
    s.add(coral(r, 40, 600, '#b23a2a', '#ffb347', 160, 4, 18, -84) + coral(r, 118, 606, '#b03070', '#ff9ecb', 112, 4, 14, -98) + coral(r, 178, 604, '#5a3aa8', '#c9a8ff', 80, 3, 12, -78))
    s.add(coral(r, 768, 604, '#b03070', '#ff9ecb', 128, 4, 15, -96) + coral(r, 704, 606, '#2f9c86', '#9df0d0', 84, 3, 12, -84))
    s.add(mound(s, 246, 598, 44, 36, '#35c6a8', '#12788c') + mound(s, 620, 598, 40, 32, '#ffb347', '#c9562b'))
    s.add(seastar(450, 588, 9, '#ffd27a', -70) + shell_on_sand(350, 590) + shell_on_sand(540, 592))
    s.layer('grass').add(grass(r, 318, 596, 6, 24, 54, '#1f9c7c', '#3fc79a') + grass(r, 520, 596, 6, 22, 50, '#1f9c7c', '#3fc79a'))
    s.layer('bg'); s.finish(mott=.26, streak=.14, vig=0, grain=0)
    return {n: s.svg_layer(n) for n in ('bg', 'kelp_far', 'fan_left', 'fan_right', 'fg', 'grass')}

def lamp(s, x, y, R, face=False):
    """The starfish lamp. Its face is drawn separately so it stays crisp."""
    if face:
        k = R / 58
        return (f'<circle cx="{x-10*k:.1f}" cy="{y-2*k:.1f}" r="{4*k:.1f}" fill="#7a3d12"/><circle cx="{x+10*k:.1f}" cy="{y-2*k:.1f}" r="{4*k:.1f}" fill="#7a3d12"/>'
                f'<path d="M{x-8*k:.1f} {y+8*k:.1f} Q{x:.1f} {y+16*k:.1f} {x+8*k:.1f} {y+8*k:.1f}" fill="none" stroke="#7a3d12" stroke-width="{3*k:.1f}" stroke-linecap="round"/>'
                f'<circle cx="{x-8.6*k:.1f}" cy="{y-3.4*k:.1f}" r="{1.4*k:.1f}" fill="#fff"/><circle cx="{x+11.4*k:.1f}" cy="{y-3.4*k:.1f}" r="{1.4*k:.1f}" fill="#fff"/>')
    sg = s.rad([(0, '#fffbe0', 1), (.45, '#ffd45e', 1), (1, '#ff9a3d', 1)])
    out = f'<polygon points="{star(x, y, R, R*.47, -90)}" fill="{sg}" stroke="#ffe9a8" stroke-width="{R*.16:.1f}" stroke-linejoin="round"/>'
    for i in range(5):
        a = math.radians(-90 + i * 72)
        out += f'<circle cx="{x+R*.52*math.cos(a):.1f}" cy="{y+R*.52*math.sin(a):.1f}" r="{R*.062:.1f}" fill="#fff8d6"/><circle cx="{x+R*.76*math.cos(a):.1f}" cy="{y+R*.76*math.sin(a):.1f}" r="{R*.045:.1f}" fill="#fff8d6"/>'
    return out

def scene_chest_layers():
    """Treasure chest: a kelp clearing with the open chest in the middle and warm light pouring out of it."""
    s = LS(523, 300, -230, 1000); r = s.r
    open_water(s, ('#dcfcef', '#8fe3d6', '#35aab8', '#167c9b', '#0e5576'))
    far = ''.join(kelp(r, x + r.uniform(-12, 12), 6, '#6fd0cd', (30, 56), (6, 10), (22, 38)) for x in (170, 262, 548, 640, 716))
    s.layer('kelp_far').add(f'<g filter="url(#b3)" opacity=".6">{far}</g>')
    d, top = hill(r, 474, 14); s.layer('bg').add(f'<path d="{d}" fill="#4ab4bd" opacity=".7" filter="url(#b3)"/>')
    s.rays(RAYS, 1000, .5)
    s.bloom(400, 340, 300, '#ffe9a8', .8)
    fan = s.lin([(0, '#fff3c4', .9), (.6, '#ffe08a', .3), (1, '#ffe08a', 0)], x1=0, y1=1, x2=0, y2=0)
    s.add(f'<g filter="url(#b12)" style="mix-blend-mode:screen"><polygon points="320,372 480,372 620,60 180,60" fill="{fan}" opacity=".6"/><polygon points="370,372 430,372 468,60 332,60" fill="{fan}" opacity=".55"/></g>')
    mid = kelp(r, 104, 12, '#1f8f95', (46, 86), (10, 16), (28, 46), lean=16) + kelp(r, 700, 11, '#1f8f95', (40, 72), (9, 15), (26, 44), lean=-14)
    s.layer('kelp_mid').add(f'<g filter="url(#paintS)">{mid}</g>')
    s.layer('fg'); sand(s, r, 490, 8, SAND)
    s.add('<ellipse cx="400" cy="496" rx="230" ry="30" fill="#fff3c4" opacity=".6" filter="url(#b12)"/>')
    s.add(boulder(s, 64, 572, 200, 74) + boulder(s, 742, 574, 220, 84))
    sand(s, r, 582, 5, SAND2, caustic=False)
    s.add('<ellipse cx="400" cy="482" rx="132" ry="14" fill="#7a5a2a" opacity=".5" filter="url(#b6)"/>')
    s.add(''.join(f'<ellipse cx="{x}" cy="{y}" rx="12" ry="5" fill="#ffd866" stroke="#e09a1f" stroke-width="1.5"/>' for x, y in ((262, 498), (284, 506), (530, 500), (552, 508), (246, 510))))
    s.add(seastar(596, 590, 9, '#ffd27a', -70) + shell_on_sand(212, 592))
    # the chest: lid (behind) and box (in front) are separate pieces
    lid = 'M298 374 C292 300 338 258 400 258 C462 258 508 300 502 374 Z'
    s.layer('chest_lid').add(f'<path d="{lid}" fill="{s.lin([(0, "#3a1414", 1), (1, "#7a2f22", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(lid)}"><ellipse cx="400" cy="384" rx="120" ry="80" fill="#ffd27a" opacity=".75" filter="url(#b12)"/><path d="M330 372 L352 268 M400 372 L400 258 M470 372 L448 268" stroke="#2a0c0c" stroke-width="2" opacity=".5"/></g>')
    s.add(f'<path d="{lid}" fill="none" stroke="#6a3c1a" stroke-width="14" stroke-linejoin="round"/><path d="{lid}" fill="none" stroke="#ffd27a" stroke-width="4" stroke-linejoin="round"/>')
    s.add('<path d="M350 372 C348 318 360 284 372 264" fill="none" stroke="#e0aa42" stroke-width="9"/><path d="M450 372 C452 318 440 284 428 264" fill="none" stroke="#e0aa42" stroke-width="9"/>')
    s.layer('chest_box').add('<ellipse cx="400" cy="366" rx="100" ry="30" fill="#fff3c4"/><ellipse cx="400" cy="378" rx="96" ry="20" fill="#ffc94d"/>')
    coins = ''
    for i in range(15):
        x = 316 + i * 12 + r.uniform(-3, 3); y = 368 - 10 * math.sin(math.pi * i / 14) + r.uniform(-3, 3)
        coins += f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="11" ry="9" fill="#ffd866" stroke="#e09a1f" stroke-width="1.5"/><ellipse cx="{x-2:.0f}" cy="{y-2:.0f}" rx="5" ry="3.5" fill="#fff3c4" opacity=".8"/>'
    s.add(coins)
    pearl = s.rad([(0, '#ffffff', 1), (.6, '#fff1e2', 1), (1, '#e3c4a8', 1)], cx=.35, cy=.3, rr=.8)
    s.add(''.join(f'<circle cx="{x}" cy="{y}" r="{rr}" fill="{pearl}"/>' for x, y, rr in ((346, 362, 8), (378, 352, 9), (414, 354, 8), (446, 362, 9), (400, 344, 7))))
    box = 'M296 380 L504 380 L494 474 L306 474 Z'
    s.add(f'<path d="{box}" fill="{s.lin([(0, "#9a5a28", 1), (1, "#4a2410", 1)])}"/>')
    s.add(f'<g clip-path="{s.clip(box)}"><path d="M290 412 L510 412 M290 444 L510 444" stroke="#2f1508" stroke-width="2.5" opacity=".6"/><rect x="290" y="380" width="70" height="100" fill="#1a0a04" opacity=".45" filter="url(#b12)"/><rect x="470" y="380" width="40" height="100" fill="#ffcf7a" opacity=".25" filter="url(#b6)"/></g>')
    gold = s.lin([(0, '#fff0b0', 1), (.5, '#ffcf5a', 1), (1, '#c9882a', 1)])
    s.add(f'<path d="M288 370 L512 370 L508 392 L292 392 Z" fill="{gold}"/><path d="M304 458 L496 458 L494 476 L306 476 Z" fill="{gold}"/><path d="M332 392 L348 392 L350 458 L336 458 Z" fill="{gold}"/><path d="M452 392 L468 392 L464 458 L450 458 Z" fill="{gold}"/>')
    s.add(f'<rect x="383" y="388" width="34" height="42" rx="9" fill="{gold}" stroke="#a86a14" stroke-width="2"/><circle cx="400" cy="404" r="5.5" fill="#3a1a0a"/><path d="M396 406 L404 406 L402 420 L398 420 Z" fill="#3a1a0a"/>')
    s.add(''.join(f'<circle cx="{x}" cy="{y}" r="3.5" fill="#fff3c4"/>' for x, y in ((300, 381), (500, 381), (340, 381), (460, 381), (312, 467), (488, 467))))
    s.add(''.join(f'<circle cx="{x}" cy="{y}" r="5" fill="{pearl}"/>' for x, y in ((430, 376), (438, 388), (442, 400), (443, 412), (441, 424))))
    s.layer('lamp').add(lamp(s, 400, 178, 58)); s.layer('lamp_face').add(lamp(s, 400, 178, 58, face=True))
    s.layer('grass').add(grass(r, 160, 592, 7, 28, 60, '#1f9c7c', '#3fc79a') + grass(r, 640, 592, 7, 26, 58, '#1f9c7c', '#3fc79a'))
    s.layer('bg'); s.finish(mott=.26, streak=.14, vig=0, grain=0)
    return {n: s.svg_layer(n) for n in ('bg', 'kelp_far', 'kelp_mid', 'fg', 'chest_lid', 'chest_box', 'lamp', 'lamp_face', 'grass')}

WALL, WALL_D, WALL_L = '#0f4a5c', '#0a3444', '#2c8a98'

def scene_grotto_layers():
    """My grotto: inside a sea cave, looking out at the lit water. Walls frame both sides; the floor is pale sand."""
    s = LS(631, 400, -260, 1000); r = s.r
    s.layer('bg').add(f'<rect width="{W}" height="{H}" fill="{s.rad([(0, "#dcfcef", 1), (.3, "#8fe3d6", 1), (.62, "#35aab8", 1), (1, "#167c9b", 1)], cx=.5, cy=.2, rr=.9)}"/>')
    back = '<path d="M150 620 C160 420 220 330 300 300 C330 380 330 500 320 620 Z" fill="#2f9fb0"/><path d="M500 620 C490 480 500 370 540 310 C610 340 650 450 660 620 Z" fill="#2f9fb0"/><path d="M330 620 C340 520 370 470 400 460 C440 470 470 520 480 620 Z" fill="#3aabb8"/>'
    s.add(f'<g filter="url(#b3)" opacity=".7">{back}</g>')
    s.bloom(400, -10, 320, '#ffffff', .95); s.rays([(-13, 7), (-4, 5), (5, 8), (14, 5)], 1000, .6)
    s.layer('floor'); sand(s, r, 520, 8, SAND)
    s.add('<ellipse cx="400" cy="536" rx="220" ry="46" fill="#fff6d8" opacity=".6" filter="url(#b12)"/>')
    lw = 'M-20 -20 L262 -20 C210 40 160 84 138 164 C118 244 146 300 108 384 C84 446 116 520 60 620 L-20 620 Z'
    rw = 'M820 -20 L548 -20 C600 50 656 74 674 152 C694 242 662 312 702 392 C726 452 698 530 746 620 L820 620 Z'
    s.layer('walls').add(f'<g filter="url(#paint)"><path d="{lw}" fill="{s.lin([(0, WALL_L, 1), (.35, WALL, 1), (1, WALL_D, 1)], x1=1, y1=0, x2=0, y2=0)}"/><path d="{rw}" fill="{s.lin([(0, WALL_L, 1), (.35, WALL, 1), (1, WALL_D, 1)], x1=0, y1=0, x2=1, y2=0)}"/>'
                          f'<path d="{lw}" transform="translate(-40 0)" fill="{WALL_D}"/><path d="{rw}" transform="translate(40 0)" fill="{WALL_D}"/>'
                          f'<path d="M262 -20 L300 70 L330 -20 Z M470 -20 L498 84 L548 -20 Z M190 -20 L214 54 L240 -20 Z M580 -20 L598 60 L620 -20 Z" fill="{WALL}"/></g>')
    s.add(f'<path d="M262 -20 C210 40 160 84 138 164 C118 244 146 300 108 384 C84 446 116 520 60 620" fill="none" stroke="#bff7e6" stroke-width="3" opacity=".55" filter="url(#b1)"/><path d="M548 -20 C600 50 656 74 674 152 C694 242 662 312 702 392 C726 452 698 530 746 620" fill="none" stroke="#bff7e6" stroke-width="3" opacity=".55" filter="url(#b1)"/>')
    def crystal(x, y, h, col, rot):
        return f'<g transform="translate({x} {y}) rotate({rot})"><path d="M0 0 L{-h*.2:.0f} {-h*.7:.0f} L0 {-h} L{h*.2:.0f} {-h*.7:.0f} Z" fill="{col}"/><path d="M0 0 L0 {-h} L{h*.2:.0f} {-h*.7:.0f} Z" fill="#ffffff" opacity=".45"/></g>'
    s.add(crystal(96, 500, 60, '#8ff0ff', -14) + crystal(118, 508, 44, '#b79cff', 10) + crystal(76, 510, 36, '#8ff0ff', -32) + crystal(716, 500, 54, '#b79cff', 16) + crystal(738, 512, 38, '#8ff0ff', 34))
    s.add(boulder(s, 40, 590, 150, 50, moss=False) + boulder(s, 770, 592, 150, 52, moss=False))
    cur = ''.join(strand(r, x, 60 + r.uniform(0, 30), ln, '#27b592', '#5fe0b6') for x, ln in ((612, 300), (640, 350), (668, 320), (694, 270)))
    s.layer('curtain').add(cur)
    cx, cy = 520, 492; n = 8
    ed = f'M{cx-112} {cy} ' + ''.join(f'Q{cx+128*math.cos(math.pi+math.pi*(i+.5)/n):.0f} {cy+118*math.sin(math.pi+math.pi*(i+.5)/n):.0f} {cx+112*math.cos(math.pi+math.pi*(i+1)/n):.0f} {cy+100*math.sin(math.pi+math.pi*(i+1)/n):.0f} ' for i in range(n)) + 'Z'
    s.layer('floor').add(f'<ellipse cx="{cx}" cy="{cy+44}" rx="130" ry="14" fill="#7a5a2a" opacity=".45" filter="url(#b6)"/>')
    s.layer('bed').add(f'<path d="{ed}" fill="{s.lin([(0, "#fff0fa", 1), (.6, "#f7b9e4", 1), (1, "#d98ac9", 1)])}" stroke="#c77ab8" stroke-width="3" stroke-linejoin="round"/>')
    s.add(''.join(f'<path d="M{cx} {cy} L{cx+106*math.cos(math.pi+math.pi*i/n):.0f} {cy+96*math.sin(math.pi+math.pi*i/n):.0f}" stroke="#d98ac9" stroke-width="3" opacity=".6"/>' for i in range(1, n)))
    s.add(f'<ellipse cx="{cx}" cy="{cy}" rx="112" ry="20" fill="#fff5fb"/><ellipse cx="{cx-10}" cy="{cy-5}" rx="88" ry="17" fill="{s.lin([(0, "#e3d4ff", 1), (1, "#b79cff", 1)])}"/><ellipse cx="{cx-30}" cy="{cy-10}" rx="40" ry="6" fill="#ffffff" opacity=".5"/>')
    s.add(f'<path d="M{cx-114} {cy} C{cx-110} {cy+66} {cx+110} {cy+66} {cx+114} {cy} C{cx+80} {cy+20} {cx-80} {cy+20} {cx-114} {cy} Z" fill="{s.lin([(0, "#f09fd8", 1), (1, "#9a4f9f", 1)])}"/>')
    s.add(''.join(f'<path d="M{cx+k*26} {cy+16} Q{cx+k*30} {cy+34} {cx+k*24} {cy+48}" fill="none" stroke="#7a3a82" stroke-width="2.5" opacity=".5"/>' for k in (-3, -2, -1, 0, 1, 2, 3)))
    s.add(f'<circle cx="{cx+66}" cy="{cy-12}" r="15" fill="{s.rad([(0, "#ffffff", 1), (.6, "#fff1e2", 1), (1, "#e3c4a8", 1)], cx=.35, cy=.3, rr=.8)}"/>')
    lights = ''
    for (x0, y0), (x1, y1), sag in (((150, 96), (400, 60), 46), ((400, 60), (650, 96), 46)):
        lights += f'<path d="M{x0} {y0} Q{(x0+x1)/2} {(y0+y1)/2+sag*2} {x1} {y1}" fill="none" stroke="#0a3444" stroke-width="2.5"/>'
        for i in range(1, 8):
            t = i / 8; x = (1-t)**2*x0 + 2*(1-t)*t*(x0+x1)/2 + t*t*x1; y = (1-t)**2*y0 + 2*(1-t)*t*((y0+y1)/2+sag*2) + t*t*y1
            lights += f'<circle cx="{x:.0f}" cy="{y+6:.0f}" r="15" fill="url(#spark)" opacity=".95"/><circle cx="{x:.0f}" cy="{y+6:.0f}" r="5" fill="#fff6d8"/>'
    s.layer('lights').add(lights)
    s.layer('lamp').add(lamp(s, 400, 178, 44)); s.layer('lamp_face').add(lamp(s, 400, 178, 44, face=True))
    s.layer('bg'); s.finish(mott=.26, streak=.14, vig=0, grain=0)
    return {n: s.svg_layer(n) for n in ('bg', 'floor', 'walls', 'curtain', 'bed', 'lights', 'lamp', 'lamp_face')}

def scene_map_layers():
    """Reef map: one seabed stepping down from the bright shallows on the left to the dark deep on the right, with a place on each step."""
    s = LS(747, 300, -230, 1000); r = s.r
    open_water(s, ('#dcfcef', '#8fe3d6', '#35aab8', '#167c9b', '#0e5576'))
    s.add(f'<rect width="{W}" height="{H}" fill="{s.lin([(.3, "#0b2e57", 0), (1, "#0b2e57", .6)], x1=0, y1=.2, x2=1, y2=.8)}"/>')
    far = ''.join(kelp(r, x + r.uniform(-12, 12), 6, '#6fd0cd', (30, 56), (6, 10), (22, 38)) for x in (250, 330, 540, 612))
    s.layer('kelp_far').add(f'<g filter="url(#b3)" opacity=".55">{far}</g>')
    s.layer('bg').add('<path d="M-20 300 C120 280 260 300 400 350 C540 400 680 420 820 436 L820 620 L-20 620 Z" fill="#4ab4bd" opacity=".55" filter="url(#b3)"/>')
    s.rays(RAYS, 1000, .5)
    mid = kelp(r, 20, 12, '#1f8f95', (46, 86), (10, 16), (28, 46), lean=18) + kelp(r, 786, 11, '#14707c', (40, 72), (9, 15), (26, 44), lean=-12)
    s.layer('kelp_mid').add(f'<g filter="url(#paintS)">{mid}</g>')
    s.layer('floor')
    fl = 'M-20 326 C60 314 200 318 270 334 C300 342 304 372 322 388 C360 402 500 396 548 410 C580 420 580 448 600 462 C640 476 760 468 820 474 L820 620 L-20 620 Z'
    s.add(f'<path d="{fl}" fill="{s.lin(SAND)}"/>')
    s.add(f'<g clip-path="{s.clip(fl)}"><rect width="{W}" height="{H}" filter="url(#caustic)" opacity=".5" style="mix-blend-mode:screen"/>'
          f'<path d="M270 334 C300 342 304 372 322 388 L322 620 L262 620 Z" fill="#b98f5c" opacity=".55" filter="url(#b6)"/><path d="M548 410 C580 420 580 448 600 462 L600 620 L540 620 Z" fill="#8a744f" opacity=".6" filter="url(#b6)"/>'
          f'<rect width="{W}" height="{H}" fill="{s.lin([(.34, "#0b2e57", 0), (.7, "#0b2e57", .42), (1, "#0b2e57", .62)], x1=0, y1=0, x2=1, y2=0)}"/></g>')
    # 1. Tide Pool: sunlit sand, mossy rocks around a pale pool
    s.add(boulder(s, 58, 356, 124, 66) + boulder(s, 232, 360, 100, 48, moss=False))
    s.add('<ellipse cx="146" cy="356" rx="72" ry="17" fill="#e9fffa"/><ellipse cx="146" cy="358" rx="63" ry="12.5" fill="#9ee9de"/><ellipse cx="128" cy="354" rx="26" ry="4.5" fill="#ffffff" opacity=".7"/>')
    s.add(seastar(214, 374, 10, '#ff7eb6', -80) + grass(r, 100, 378, 4, 14, 30, '#1f9c7c', '#3fc79a') + shell_on_sand(176, 384))
    # 2. Coral Reef: bright coral on the middle step
    s.add(coral(r, 372, 430, '#b23a2a', '#ffb347', 165, 4, 16, -93) + coral(r, 500, 432, '#5a3aa8', '#d2b4ff', 175, 4, 16, -86) + coral(r, 436, 440, '#b03070', '#ff9ecb', 124, 4, 14, -90))
    s.add(mound(s, 340, 444, 32, 26, '#35c6a8', '#12788c') + mound(s, 530, 446, 28, 22, '#ffb347', '#c9562b') + shell_on_sand(410, 456))
    # 3. Deep Sea: dark rock, a glowing cave mouth, cold crystals
    s.add(boulder(s, 646, 492, 132, 90, lit='#7fb7c4', base='#245f78', dark='#0b2c48', moss=False) + boulder(s, 770, 494, 120, 72, lit='#7fb7c4', base='#245f78', dark='#0b2c48', moss=False))
    s.add('<path d="M676 494 C684 434 730 434 740 494 Z" fill="#061c3a"/><ellipse cx="708" cy="480" rx="22" ry="15" fill="#5fe0ff" opacity=".55" filter="url(#b6)"/>')
    s.add(''.join(f'<g transform="translate({x} {y}) rotate({rot})"><path d="M0 0 L{-h*.2:.0f} {-h*.7:.0f} L0 {-h} L{h*.2:.0f} {-h*.7:.0f} Z" fill="{c}"/><path d="M0 0 L0 {-h} L{h*.2:.0f} {-h*.7:.0f} Z" fill="#ffffff" opacity=".45"/></g>' for x, y, h, c, rot in ((684, 500, 36, '#8ff0ff', -16), (734, 502, 30, '#b79cff', 14), (708, 504, 22, '#8ff0ff', 2))))
    s.add(boulder(s, 30, 600, 130, 40, moss=False) + shell_on_sand(300, 588) + seastar(520, 590, 8, '#ffd27a', -70))
    s.layer('grass').add(grass(r, 120, 598, 6, 22, 46, '#1f9c7c', '#3fc79a') + grass(r, 590, 598, 6, 20, 42, '#1f9c7c', '#3fc79a'))
    s.layer('bg'); s.finish(mott=.26, streak=.14, vig=0, grain=0)
    return {n: s.svg_layer(n) for n in ('bg', 'kelp_far', 'kelp_mid', 'floor', 'grass')}

def scene_hunt_layers():
    """The treasure garden for the hidden-object hunt: a sunken rowboat on a
    bright sandy clearing, with boulders, corals and grass to tuck little
    treasures beside. The findables themselves are app overlays."""
    s = LS(733, 300, -230, 1000); r = s.r
    open_water(s)
    far = ''.join(kelp(r, x + r.uniform(-12, 12), 6, '#6fd0cd', (30, 56), (6, 10), (22, 38)) for x in (160, 300, 470, 620, 740))
    s.layer('kelp_far').add(f'<g filter="url(#b3)" opacity=".6">{far}</g>')
    d, top = hill(r, 450, 16); s.layer('bg').add(f'<path d="{d}" fill="#4fb8bd" opacity=".65" filter="url(#b3)"/>')
    s.rays(RAYS, 1000, .5)
    s.layer('fg'); sand(s, r, 452, 9, SAND)
    # The wreck: an old rowboat, resting at a tilt in the sand
    hull = s.lin([(0, '#8a5c34', 1), (1, '#573418', 1)])
    planks = ''.join(f'<path d="M{308+i*4} {466-i*15} C370 {450-i*15} 530 {450-i*15} {588-i*3} {464-i*15}" fill="none" stroke="#3f2410" stroke-width="3" opacity=".5"/>' for i in (1, 2, 3))
    s.add(f'<g transform="rotate(-7 420 470)">'
          f'<path d="M300 470 C310 430 330 414 352 410 L520 410 C560 416 588 438 596 470 C560 500 340 504 300 470 Z" fill="{hull}"/>'
          f'{planks}'
          f'<path d="M300 470 C340 504 560 500 596 470 L592 482 C540 510 350 514 306 482 Z" fill="#3f2410" opacity=".8"/>'
          f'<circle cx="394" cy="446" r="13" fill="#2b4a5e" stroke="#a87648" stroke-width="5"/>'
          f'<path d="M520 410 L548 338 L566 342 L540 412 Z" fill="#6a4426"/>'
          f'</g>')
    s.add(boulder(s, 96, 500, 220, 86) + boulder(s, 724, 520, 200, 80) + boulder(s, 640, 556, 100, 42, moss=False))
    s.add(coral(r, 60, 486, '#b03070', '#ff9ecb', 150, 4, 14, -86) + coral(r, 756, 470, '#5a3aa8', '#d2b4ff', 160, 4, 15, -94) + coral(r, 688, 520, '#b23a2a', '#ffb347', 100, 3, 12, -80))
    sand(s, r, 560, 6, SAND2, caustic=False)
    s.add(mound(s, 206, 592, 42, 34, '#35c6a8', '#12788c') + mound(s, 560, 596, 38, 30, '#ffb347', '#c9562b'))
    s.add(shell_on_sand(250, 588) + shell_on_sand(480, 592))
    s.layer('grass').add(grass(r, 150, 594, 7, 26, 60, '#1f9c7c', '#3fc79a') + grass(r, 420, 598, 6, 24, 52, '#1f9c7c', '#3fc79a') + grass(r, 700, 596, 7, 26, 58, '#1f9c7c', '#3fc79a'))
    s.layer('bg'); s.finish(mott=.26, streak=.14, vig=0, grain=0)
    return {n: s.svg_layer(n) for n in ('bg', 'kelp_far', 'fg', 'grass')}


def scene_deep_layers():
    """The Deep Sea: darker water, pale glowing corals, the crab's rock on the
    left and open space on the right for the counting rings."""
    s = LS(947, 300, -230, 1000); r = s.r
    open_water(s, cols=('#7fd0d8', '#3d9bb0', '#1b6a8e', '#0e3f66', '#081f44'))
    far = ''.join(kelp(r, x + r.uniform(-12, 12), 6, '#4fa8b4', (30, 56), (6, 10), (22, 38)) for x in (200, 360, 520, 680))
    s.layer('kelp_far').add(f'<g filter="url(#b3)" opacity=".55">{far}</g>')
    d, top = hill(r, 470, 14); s.layer('bg').add(f'<path d="{d}" fill="#1f6d88" opacity=".6" filter="url(#b3)"/>')
    s.rays(RAYS, 1000, .4)
    s.layer('fg'); sand(s, r, 476, 8, [(0, '#c9b58b', 1), (1, '#8a7452', 1)])
    s.add(boulder(s, 140, 486, 310, 104) + boulder(s, 302, 548, 120, 50, moss=False))
    s.add(boulder(s, 742, 544, 180, 70) + boulder(s, 652, 572, 90, 36, moss=False))
    s.add(coral(r, 52, 492, '#3a7f9c', '#aef0ff', 160, 4, 14, -88) + coral(r, 760, 500, '#4a5fb0', '#bcd2ff', 150, 4, 14, -92) + coral(r, 690, 540, '#2f8c9c', '#9ff0e8', 96, 3, 11, -80))
    sand(s, r, 574, 5, [(0, '#d6c29a', 1), (1, '#7a6648', 1)], caustic=False)
    s.add(mound(s, 420, 598, 40, 32, '#2f9c9c', '#0e5f78') + mound(s, 560, 600, 34, 28, '#4a5fb0', '#20306e'))
    s.add(shell_on_sand(360, 592) + seastar(500, 590, 9, '#9fd0ff', -75))
    s.layer('grass').add(grass(r, 240, 596, 6, 22, 50, '#157c74', '#2fae9c') + grass(r, 620, 598, 6, 20, 46, '#157c74', '#2fae9c'))
    s.layer('bg'); s.finish(mott=.3, streak=.12, vig=.25, grain=0)
    return {n: s.svg_layer(n) for n in ('bg', 'kelp_far', 'fg', 'grass')}


# ---- The intro's treasure gallery: three wall segments the camera pans
# across. Every segment ends in the same dark rock pillar, so they tile
# seamlessly in any order.

_EDGE_L = '<path d="M-20 -20 L74 -20 C44 120 64 300 38 470 C52 556 32 620 -20 620 Z" fill="#061c33"/>'
_EDGE_R = '<path d="M820 -20 L726 -20 C756 120 736 300 762 470 C748 556 768 620 820 620 Z" fill="#061c33"/>'


def _ledge(x, y, w):
    return (f'<path d="M{x} {y} Q{x+w/2} {y-10} {x+w} {y} L{x+w-8} {y+18} Q{x+w/2} {y+26} {x+8} {y+18} Z" fill="#0d3a5c"/>'
            f'<path d="M{x} {y} Q{x+w/2} {y-10} {x+w} {y}" fill="none" stroke="#7fe9e0" stroke-width="2.5" opacity=".35"/>')


def _goblet(g, x, y, h=44):
    w = h * .52
    return (f'<g transform="translate({x} {y})">'
            f'<path d="M{-w/2} {-h} Q0 {-h+8} {w/2} {-h} L{w*.3} {-h*.45} Q0 {-h*.3} {-w*.3} {-h*.45} Z" fill="{g}"/>'
            f'<path d="M-3 {-h*.45} L3 {-h*.45} L2 -6 L-2 -6 Z" fill="{g}"/>'
            f'<path d="M{-w*.36} 0 Q0 -8 {w*.36} 0 L{w*.3} 4 L{-w*.3} 4 Z" fill="{g}"/></g>')


def _crown(g, x, y, w=46):
    return (f'<g transform="translate({x} {y})">'
            f'<path d="M{-w/2} 0 L{-w/2} {-w*.34} L{-w*.25} {-w*.14} L0 {-w*.42} L{w*.25} {-w*.14} L{w/2} {-w*.34} L{w/2} 0 Z" fill="{g}" stroke="#a86a14" stroke-width="2"/>'
            f'<circle cx="0" cy="{-w*.1}" r="4.5" fill="#e04a6a"/></g>')


def _bottle(x, y, h, col):
    w = h * .42
    return (f'<g transform="translate({x} {y})">'
            f'<path d="M{-w/2} 0 L{-w/2} {-h*.62} Q{-w/2} {-h*.72} {-w*.18} {-h*.78} L{-w*.18} {-h} L{w*.18} {-h} L{w*.18} {-h*.78} Q{w/2} {-h*.72} {w/2} {-h*.62} L{w/2} 0 Z" fill="{col}" opacity=".9"/>'
            f'<ellipse cx="{-w*.16}" cy="{-h*.4}" rx="{w*.13}" ry="{h*.18}" fill="#ffffff" opacity=".35"/></g>')


def _mirror(g, x, y, h=54):
    r = h * .3
    return (f'<g transform="translate({x} {y})">'
            f'<ellipse cx="0" cy="{-h+r*1.2}" rx="{r}" ry="{r*1.25}" fill="#bfe9f2" stroke="{g}" stroke-width="5"/>'
            f'<path d="M-4 {-h+r*2.5} L4 {-h+r*2.5} L3 0 L-3 0 Z" fill="{g}"/></g>')


def _vase(x, y, h, col, col2):
    w = h * .54
    return (f'<g transform="translate({x} {y})">'
            f'<path d="M{-w*.2} {-h} L{w*.2} {-h} L{w*.16} {-h*.8} Q{w*.55} {-h*.6} {w*.4} {-h*.25} Q{w*.3} 0 0 0 Q{-w*.3} 0 {-w*.4} {-h*.25} Q{-w*.55} {-h*.6} {-w*.16} {-h*.8} Z" fill="{col}"/>'
            f'<path d="M{-w*.3} {-h*.5} Q0 {-h*.4} {w*.3} {-h*.5}" fill="none" stroke="{col2}" stroke-width="3" opacity=".7"/></g>')


def _teacup(x, y, h=26):
    w = h * 1.3
    return (f'<g transform="translate({x} {y})">'
            f'<path d="M{-w/2} {-h} L{w/2} {-h} Q{w*.44} 0 0 0 Q{-w*.44} 0 {-w/2} {-h} Z" fill="#fdf3f8"/>'
            f'<path d="M{w/2} {-h*.85} Q{w*.85} {-h*.7} {w*.42} {-h*.3}" fill="none" stroke="#fdf3f8" stroke-width="4"/>'
            f'<path d="M{-w*.42} {-h*.75} Q0 {-h*.6} {w*.42} {-h*.75}" fill="none" stroke="#ff9ecb" stroke-width="3"/></g>')


def _chestlet(g, x, y, w=58):
    h = w * .62
    return (f'<g transform="translate({x} {y})">'
            f'<path d="M{-w/2} {-h*.55} L{w/2} {-h*.55} L{w*.46} 0 L{-w*.46} 0 Z" fill="#6a4426"/>'
            f'<path d="M{-w/2} {-h*.55} Q0 {-h*1.15} {w/2} {-h*.55} Z" fill="#8a5c34"/>'
            f'<path d="M{-w/2} {-h*.55} L{w/2} {-h*.55}" stroke="{g}" stroke-width="5"/>'
            f'<rect x="-5" y="{-h*.62}" width="10" height="13" rx="3" fill="{g}"/></g>')


def _garland(s, x0, y0, x1, sag, n=9, r=7):
    pf = s.rad([(0, '#ffffff', 1), (.6, '#fff1e2', 1), (1, '#e3c4a8', 1)], cx=.35, cy=.3, rr=.8)
    out = f'<path d="M{x0} {y0} Q{(x0+x1)/2} {y0+sag*2} {x1} {y0}" fill="none" stroke="#e8d8c0" stroke-width="2"/>'
    for i in range(n):
        t = i / (n - 1)
        x = x0 + (x1 - x0) * t
        y = y0 + sag * 2 * t * (1 - t) * 2
        out += f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{r}" fill="{pf}"/>'
    return out


def _gallery(seed):
    """One 800x600 segment of the treasure gallery, stuffed shelf to shelf."""
    s = LS(seed, 400, -260, 900); r = s.r
    s.layer('bg')
    s.add(f'<rect width="800" height="600" fill="{s.lin([(0, "#16466a", 1), (.5, "#0f3756", 1), (1, "#0a2440", 1)])}"/>')
    s.bloom(400, -60, 460, '#9fe8df', .55)
    s.rays([(-10, 6), (2, 5), (14, 7)], 900, .3)
    gold = s.lin([(0, '#fff0b0', 1), (.5, '#ffcf5a', 1), (1, '#c9882a', 1)])
    pf = s.rad([(0, '#ffffff', 1), (.6, '#fff1e2', 1), (1, '#e3c4a8', 1)], cx=.35, cy=.3, rr=.8)
    jewels = ['#e04a6a', '#8FE9DF', '#C9A8FF', '#ff9ecb']

    def glowjar(x, y, h=40):
        w = h * .72
        glow = s.rad([(0, '#ffe9a8', .85), (1, '#ffe9a8', 0)])
        return (f'<circle cx="{x}" cy="{y-h*.45:.0f}" r="{h*1.3:.0f}" fill="{glow}"/>'
                f'<g transform="translate({x} {y})"><rect x="{-w/2}" y="{-h*.8}" width="{w}" height="{h*.8}" rx="7" fill="#d8f2f2" opacity=".6"/>'
                f'<rect x="{-w*.56}" y="{-h}" width="{w*1.12}" height="{h*.22}" rx="4" fill="#a86a14"/>'
                f'<circle cx="0" cy="{-h*.38}" r="{h*.2}" fill="#fff6e0"/></g>')

    def shelf_items(y, xs):
        out = ''
        for x in xs:
            kind = r.choice(['goblet', 'crown', 'bottle', 'mirror', 'vase', 'jar', 'cup', 'pearl', 'star'])
            if kind == 'goblet': out += _goblet(gold, x, y, r.uniform(38, 52))
            elif kind == 'crown': out += _crown(gold, x, y, r.uniform(38, 50))
            elif kind == 'bottle': out += _bottle(x, y, r.uniform(44, 60), r.choice(['#7fc9b8', '#b79cff', '#8fd0e8']))
            elif kind == 'mirror': out += _mirror(gold, x, y, r.uniform(48, 60))
            elif kind == 'vase': out += _vase(x, y, r.uniform(44, 58), r.choice(jewels), '#fff0b0')
            elif kind == 'jar': out += glowjar(x, y, r.uniform(36, 44))
            elif kind == 'cup': out += _teacup(x, y, r.uniform(22, 28))
            elif kind == 'pearl': out += f'<circle cx="{x}" cy="{y-10}" r="10" fill="{pf}"/><circle cx="{x+16}" cy="{y-8}" r="8" fill="{pf}"/>'
            else: out += f'<polygon points="{star(x, y - 12, 13, 6, -90)}" fill="{r.choice(jewels)}"/>'
        return out

    # Three shelf rows, each a pair of carved ledges crowded with treasure
    for y, lanes in ((218, ((90, 280), (430, 280)),), (352, ((140, 240), (470, 250)),), (486, ((80, 300), (450, 270)),)):
        for lx, lw in lanes:
            n = max(2, int(lw / r.uniform(62, 80)))
            xs = [lx + lw * (i + 0.5) / n + r.uniform(-8, 8) for i in range(n)]
            s.add(shelf_items(y, xs))
            s.add(_ledge(lx - 14, y + 2, lw + 28))
    # Pearl garlands draped between the shelves
    s.add(_garland(s, r.uniform(80, 140), 110, r.uniform(300, 380), r.uniform(28, 40)))
    s.add(_garland(s, r.uniform(430, 500), 96, r.uniform(680, 730), r.uniform(26, 38)))
    # The floor: sand, coin drifts, a little chest
    s.add(f'<path d="M-20 556 Q200 540 420 554 Q620 566 820 552 L820 620 L-20 620 Z" fill="{s.lin([(0, "#e8d4a4", 1), (1, "#9a7850", 1)])}"/>')
    coins = ''.join(f'<ellipse cx="{r.uniform(80, 720):.0f}" cy="{r.uniform(560, 590):.0f}" rx="10" ry="7" fill="#ffd866" stroke="#e09a1f" stroke-width="1.5"/>' for _ in range(10))
    s.add(coins + _chestlet(gold, r.uniform(180, 620), 574, 64))
    s.add(''.join(f'<circle cx="{r.uniform(60, 740):.0f}" cy="{r.uniform(556, 586):.0f}" r="{r.uniform(6, 9):.0f}" fill="{pf}"/>' for _ in range(6)))
    # The seam pillars, identical on every segment
    s.add(_EDGE_L + _EDGE_R)
    s.finish(mott=.3, streak=0, vig=.3)
    return {'bg': s.svg_layer('bg')}


def scene_iwalla_layers(): return _gallery(1201)
def scene_iwallb_layers(): return _gallery(1202)
def scene_iwallc_layers(): return _gallery(1203)


def _rockpillar(r, cx, w, topw=.7):
    """A floor-to-ceiling rock column with organic, bumpy edges."""
    left, right = [], []
    y = -30
    while y < 640:
        k = 1 - (1 - topw) * max(0, (300 - abs(y - 300)) / 300)
        left.append((cx - w / 2 * k * r.uniform(.82, 1.12), y))
        right.append((cx + w / 2 * k * r.uniform(.82, 1.12), y))
        y += r.uniform(46, 84)
    d = 'M' + ' L'.join(f'{x:.0f} {y:.0f}' for x, y in left) \
        + ' L' + ' L'.join(f'{x:.0f} {y:.0f}' for x, y in reversed(right)) + ' Z'
    return d


def scene_ipillars_layers():
    """Foreground silhouette pillars for the intro's multiplane pan: painted
    rock columns with rough edges, nothing straight anywhere."""
    s = LS(1301, 300, -230, 900); r = s.r
    for name, cx, w in (('pillar_a', 180, 220), ('pillar_b', 560, 150)):
        s.layer(name)
        fill = s.lin([(0, '#0a2c48', 1), (1, '#051426', 1)], x2=1, y2=0)
        d = _rockpillar(r, cx, w)
        s.add(f'<path d="{d}" fill="{fill}"/>')
        s.add(f'<path d="{d}" fill="none" stroke="#7fe9e0" stroke-width="3" opacity=".22"/>')
        s.add(''.join(f'<ellipse cx="{cx + r.uniform(-w*.3, w*.3):.0f}" cy="{r.uniform(60, 560):.0f}" rx="{r.uniform(8, 18):.0f}" ry="{r.uniform(5, 9):.0f}" fill="#113a58" opacity=".8"/>' for _ in range(5)))
    return {n: s.svg_layer(n) for n in ('pillar_a', 'pillar_b')}


def scene_ihome_layers():
    """The gallery's last segment: the grotto entrance. A big cave-mouth
    window onto open water (the whale passes behind it), ledges that the hero
    treasures live on, all layered so the app can stage the story:
      bg    - open water, light, distant kelp (what the window looks out on)
      wall  - the interior wall WITH the window hole, ledges and floor baked
      items - the generic shelf treasures (hidden after the sneeze)
    The hero treasures stay live app overlays, so they can rattle and fly."""
    s = LS(1310, 560, -120, 900); r = s.r
    # What lies beyond the window
    s.layer('bg')
    open_water(s, cols=('#bdf4e6', '#6fd6cb', '#2d9fb4', '#15648d', '#0b3560'))
    far = ''.join(kelp(r, x + r.uniform(-14, 14), 6, '#5fc4c4', (30, 56), (6, 10), (22, 38)) for x in (470, 580, 690, 760))
    s.add(f'<g filter="url(#b3)" opacity=".6">{far}</g>')
    s.rays([(-6, 6), (6, 5), (18, 7)], 900, .45)
    s.finish(mott=.25, streak=.1, vig=0, grain=0)

    # The interior wall with the window hole (everything else shows through)
    s.layer('wall')
    hole = ('M470 320 C452 206 520 110 612 102 C716 96 790 170 796 282 '
            'C800 380 744 470 640 486 C540 498 482 420 470 320 Z')
    wall_fill = s.lin([(0, '#143f60', 1), (.55, '#0e3350', 1), (1, '#0a2440', 1)])
    s.add(f'<path d="M-20 -20 L820 -20 L820 620 L-20 620 Z {hole}" fill-rule="evenodd" fill="{wall_fill}"/>')
    s.add(f'<path d="{hole}" fill="none" stroke="#061c33" stroke-width="16"/>')
    s.add(f'<path d="{hole}" fill="none" stroke="#7fe9e0" stroke-width="3" opacity=".3"/>')
    s.bloom(400, -60, 380, '#9fe8df', .4)
    # Ledges, left of the window
    for lx, lw, y in ((54, 300, 218), (96, 250, 356), (40, 330, 490)):
        s.add(_ledge(lx, y, lw))
    # The floor, running under the window
    s.add(f'<path d="M-20 548 Q220 532 430 548 Q640 562 820 548 L820 620 L-20 620 Z" fill="{s.lin([(0, "#e8d4a4", 1), (1, "#9a7850", 1)])}"/>')
    s.add(''.join(f'<ellipse cx="{r.uniform(60, 740):.0f}" cy="{r.uniform(560, 592):.0f}" rx="9" ry="6" fill="#ffd866" stroke="#e09a1f" stroke-width="1.4" opacity=".9"/>' for _ in range(8)))
    s.add(_EDGE_L)
    s.finish(mott=.3, streak=0, vig=.25)

    # The generic treasures on those ledges (vanish with the sneeze)
    s.layer('items')
    gold = s.lin([(0, '#fff0b0', 1), (.5, '#ffcf5a', 1), (1, '#c9882a', 1)])
    pf = s.rad([(0, '#ffffff', 1), (.6, '#fff1e2', 1), (1, '#e3c4a8', 1)], cx=.35, cy=.3, rr=.8)
    s.add(_goblet(gold, 110, 216, 46) + _crown(gold, 186, 216, 44) + _bottle(258, 216, 54, '#b79cff') + _mirror(gold, 322, 216, 56))
    s.add(_vase(150, 354, 52, '#8FE9DF', '#fff0b0') + _teacup(226, 354, 26) + _bottle(292, 354, 48, '#7fc9b8'))
    s.add(_goblet(gold, 96, 488, 42) + _vase(190, 488, 56, '#ff9ecb', '#fff0b0') + _crown(gold, 276, 488, 40) + _bottle(340, 488, 50, '#8fd0e8'))
    s.add(_garland(s, 60, 120, 300, 34) + _chestlet(gold, 150, 576, 60))
    s.add(''.join(f'<circle cx="{r.uniform(60, 400):.0f}" cy="{r.uniform(556, 588):.0f}" r="{r.uniform(6, 9):.0f}" fill="{pf}"/>' for _ in range(5)))
    return {n: s.svg_layer(n) for n in ('bg', 'wall', 'items')}


# ---- The scatter journey: a bright open coral reef the camera pans across,
# a different part of the ocean from the grotto. Segments tile behind an
# identical coral-cluster edge (not the grotto's rock pillars).

_REEF_EDGE_L = None  # built once below


def _reef_edge(s, r):
    out = boulder(s, 10, 540, 180, 90) + boulder(s, -6, 580, 120, 60, moss=False)
    out += coral(r, 6, 470, '#7a2f6a', '#e89ad0', 190, 4, 15, -88)
    return out


def _reefstrip(seed):
    """One 800x600 segment of the open reef: bright water, vivid coral."""
    s = LS(seed, 300, -200, 1000); r = s.r
    s.layer('bg')
    open_water(s, cols=('#d2f9ec', '#8ce5d2', '#3cb3bd', '#1e86a0', '#136181'))
    far = ''.join(kelp(r, x + r.uniform(-14, 14), 6, '#6fd0cd', (28, 50), (6, 10), (22, 36)) for x in (120, 300, 480, 660))
    s.add(f'<g filter="url(#b3)" opacity=".55">{far}</g>')
    d, top = hill(r, 440, 16)
    s.add(f'<path d="{d}" fill="#3fb0b8" opacity=".6" filter="url(#b3)"/>')
    s.rays(RAYS, 1000, .5)
    ff, nf = school(r, 14, [(760, r.uniform(120, 200)), (430, r.uniform(150, 230)), (60, r.uniform(120, 220))], 40, size=(.12, .4), heading=-8)
    s.add(ff + nf)
    sand(s, r, 452, 9, SAND)
    # A big joyful coral garden, different mix per segment
    cols = [('#b23a2a', '#ffb347'), ('#b03070', '#ff9ecb'), ('#5a3aa8', '#d2b4ff'), ('#2f9c86', '#9df0d0'), ('#c9562b', '#ffd27a')]
    xs = sorted(r.uniform(120, 700) for _ in range(5))
    for i, x in enumerate(xs):
        c1, c2 = cols[(i + seed) % len(cols)]
        s.add(coral(r, x, r.uniform(470, 520), c1, c2, r.uniform(120, 210), 4, r.uniform(11, 16), r.uniform(-98, -78)))
    s.add(boulder(s, r.uniform(200, 380), 560, 170, 70) + boulder(s, r.uniform(500, 640), 572, 130, 56, moss=False))
    s.add(mound(s, r.uniform(140, 300), 596, 42, 34, '#35c6a8', '#12788c') + mound(s, r.uniform(460, 660), 598, 38, 30, '#ffb347', '#c9562b'))
    s.add(seastar(r.uniform(300, 500), 588, 11, r.choice(['#ff7fa6', '#ffa24a', '#9fd0ff']), r.uniform(-100, -70)))
    sand(s, r, 566, 6, SAND2, caustic=False)
    s.add(grass(r, r.uniform(120, 240), 596, 6, 24, 54, '#1f9c7c', '#3fc79a') + grass(r, r.uniform(520, 680), 598, 6, 22, 50, '#1f9c7c', '#3fc79a'))
    # The identical seam cluster on both edges
    import random as _rnd
    s.add(_reef_edge(s, _rnd.Random(77)))
    s.add(f'<g transform="translate(800 0) scale(-1 1)">{_reef_edge(s, _rnd.Random(77))}</g>')
    s.finish(mott=.3, streak=.16, vig=.2, grain=0)
    return {'bg': s.svg_layer('bg')}


def scene_journeya_layers(): return _reefstrip(1501)
def scene_journeyb_layers(): return _reefstrip(1502)
def scene_journeyc_layers(): return _reefstrip(1503)


def scene_props_layers():
    """Small painted objects used by the screens: the padlock for a locked zone,
    the two countable shells, and the Tide Pool's big answer fish (it carries a
    numeral on its pale belly patch; the face stays crisp on a vector layer)."""
    from chars import shell
    s = LS(5, 300, -230, 1000)
    gold = s.lin([(0, '#fff0b0', 1), (.5, '#ffcf5a', 1), (1, '#c9882a', 1)])
    s.layer('lock').add(f'<path d="M172 150 V124 a28 28 0 0 1 56 0 V150" fill="none" stroke="#e0aa42" stroke-width="13" stroke-linecap="round"/><path d="M172 150 V124 a28 28 0 0 1 56 0 V150" fill="none" stroke="#fff0b0" stroke-width="4" stroke-linecap="round" opacity=".7"/>'
                        f'<rect x="150" y="146" width="100" height="78" rx="16" fill="{gold}" stroke="#a86a14" stroke-width="3"/><circle cx="200" cy="178" r="10" fill="#3a1a0a"/><path d="M194 180 L206 180 L203 204 L197 204 Z" fill="#3a1a0a"/><ellipse cx="176" cy="160" rx="18" ry="6" fill="#ffffff" opacity=".5"/>')
    body = s.lin([(0, '#ff6a24', 1), (.45, '#ff9433', 1), (1, '#ffc96a', 1)])
    tail = s.lin([(0, '#ff7a2e', 1), (1, '#ffb347', .85)], x2=1, y2=0)
    s.layer('afish').add(
        f'<path d="M446 292 L484 258 C474 282 474 302 484 326 L446 296 Z" fill="{tail}"/>'
        f'<path d="M366 256 C378 232 410 234 420 258 Z" fill="#ff7226"/>'
        f'<path d="M330 292 C338 248 446 246 454 292 C446 338 338 336 330 292 Z" fill="{body}"/>'
        f'<path d="M378 312 C386 332 406 332 414 318 Z" fill="#ffa64d"/>'
        f'<ellipse cx="392" cy="298" rx="40" ry="27" fill="#fff6e0"/>')
    s.layer('afish_face').add(
        '<circle cx="352" cy="280" r="10" fill="#ffffff"/><circle cx="350.5" cy="281" r="6" fill="#1b1030"/><circle cx="348" cy="278" r="2.4" fill="#ffffff"/>'
        '<path d="M340 300 Q349 308 358 302" fill="none" stroke="#7a3d12" stroke-width="3" stroke-linecap="round"/>'
        '<ellipse cx="364" cy="299" rx="6" ry="4" fill="#ff9ecb" opacity=".5"/>')
    # The great big whale from the intro: friendly, huge, about to sneeze.
    back = s.lin([(0, '#2e6e94', 1), (.55, '#3d85ac', 1), (1, '#6fb3cc', 1)])
    belly = s.lin([(0, '#cfe9ef', 1), (1, '#9fcfdd', 1)])
    s.layer('whale').add(
        f'<path d="M150 320 C180 230 330 200 460 228 C560 248 620 300 628 332 C600 318 584 316 566 322 C590 338 602 362 600 388 C560 420 420 446 300 436 C210 428 150 380 150 320 Z" fill="{back}"/>'
        f'<path d="M628 332 C652 300 676 288 706 284 C694 310 692 326 698 352 C692 378 668 392 640 396 C620 380 606 360 600 388 C602 362 590 338 566 322 C584 316 600 318 628 332 Z" fill="{back}"/>'
        f'<path d="M160 340 C220 384 420 416 560 392 C540 416 420 442 300 436 C216 428 166 386 160 340 Z" fill="{belly}"/>'
        f'<path d="M190 354 C260 392 420 412 540 396" fill="none" stroke="#8fc3d4" stroke-width="5" opacity=".7"/>'
        f'<path d="M206 372 C276 404 420 420 520 408" fill="none" stroke="#8fc3d4" stroke-width="5" opacity=".6"/>'
        f'<path d="M330 404 C350 436 400 444 430 424 C410 452 350 452 330 404 Z" fill="#2e6e94"/>')
    s.layer('whale_face').add(
        '<circle cx="246" cy="300" r="15" fill="#ffffff"/><circle cx="243" cy="302" r="9" fill="#1b1030"/><circle cx="239.5" cy="297.5" r="3.4" fill="#ffffff"/>'
        '<path d="M180 342 Q220 362 262 352" fill="none" stroke="#1b3a52" stroke-width="5" stroke-linecap="round"/>'
        '<ellipse cx="282" cy="334" rx="11" ry="7" fill="#ff9ecb" opacity=".45"/>')
    # Foreground coral fans for the journey's parallax (instead of the
    # grotto's rock pillars): deep-toned, anchored to the bottom edge.
    for name, cx, c1, c2 in (('fgfan_a', 200, '#6a2358', '#c96aa8'), ('fgfan_b', 560, '#3a2a78', '#8a6ad0')):
        s.layer(name)
        fr = __import__('random').Random(31 if name.endswith('a') else 47)
        s.add(boulder(s, cx, 620, 300, 110))
        s.add(coral(fr, cx - 40, 600, c1, c2, 420, 5, 24, -92))
        s.add(coral(fr, cx + 80, 614, c1, c2, 280, 4, 18, -80))

    # The big open treasure map for the intro's briefing: a real storybook
    # chart on torn parchment - sea wash, an island chain carrying the three
    # zones as little vignettes, a red dashed trail to a circled X, compass
    # rose, and doodles in the margins. Readable at ~340 wide on screen.
    import random as _r
    s.layer('bigmap')
    parch = s.lin([(0, '#fdf2d8', 1), (.6, '#f3ddb0', 1), (1, '#e2bf8c', 1)])
    torn = ('M150 140 C200 118 260 132 320 120 C390 108 470 124 540 114 C600 106 644 124 654 144 '
            'C670 182 652 230 666 280 C678 330 658 380 668 428 C676 470 658 502 638 514 '
            'C568 530 480 512 400 524 C330 534 250 518 198 526 C164 532 142 508 138 478 '
            'C128 420 148 360 134 300 C124 250 138 188 150 140 Z')
    s.add(f'<path d="{torn}" fill="{parch}" stroke="#b8905c" stroke-width="5" stroke-linejoin="round"/>')
    s.add(f'<path d="{torn}" fill="none" stroke="#8a6a3c" stroke-width="2.5" opacity=".5" transform="translate(4 5)"/>')
    # Worn stains and a hand-drawn inner border
    s.add('<ellipse cx="200" cy="180" rx="44" ry="26" fill="#a9834f" opacity=".14"/>'
          '<ellipse cx="620" cy="470" rx="50" ry="30" fill="#a9834f" opacity=".13"/>'
          '<ellipse cx="610" cy="160" rx="30" ry="20" fill="#a9834f" opacity=".11"/>'
          '<ellipse cx="170" cy="470" rx="34" ry="22" fill="#a9834f" opacity=".11"/>')
    s.add('<path d="M172 162 C300 148 480 150 630 144 M646 166 C636 280 650 380 648 492 '
          'M630 506 C480 514 300 508 176 508 M158 486 C166 380 152 270 160 164" '
          'fill="none" stroke="#b8905c" stroke-width="2.5" opacity=".55" stroke-dasharray="1 0"/>')
    # The sea, washed over the middle of the chart, with wave squiggles
    sea = s.lin([(0, '#b4e6e6', 1), (1, '#7fc3cf', 1)])
    s.add(f'<path d="M190 200 C280 170 420 178 540 172 C610 168 638 210 630 270 '
          f'C622 330 644 380 630 440 C618 486 560 496 480 490 C380 482 300 498 240 484 '
          f'C196 474 178 440 186 390 C194 330 176 260 190 200 Z" fill="{sea}"/>')
    for wx, wy in ((230, 220), (560, 200), (600, 330), (210, 420), (470, 470), (250, 330)):
        s.add(f'<path d="M{wx} {wy} q9 -7 18 0 q9 7 18 0" fill="none" stroke="#5fa8ba" stroke-width="3" stroke-linecap="round"/>')
    # The island chain, snaking from the tide pool down to the deep
    sand_f = s.lin([(0, '#f7e6ba', 1), (1, '#dcb87e', 1)])
    s.add(f'<path d="M226 206 C280 186 330 198 352 226 C372 250 356 276 384 296 '
          f'C416 318 470 310 496 338 C520 364 506 396 530 418 C552 438 586 436 596 458 '
          f'C604 476 586 492 556 490 C510 486 470 462 430 452 C390 442 348 420 330 390 '
          f'C312 360 330 330 300 308 C268 286 232 288 216 258 C204 234 208 214 226 206 Z" '
          f'fill="{sand_f}" stroke="#c9a05e" stroke-width="3.5"/>')
    # Vignette 1, the Tide Pool: a bright turquoise pool with sea stars
    s.add('<ellipse cx="282" cy="248" rx="34" ry="20" fill="#49c6c0"/>'
          '<ellipse cx="278" cy="244" rx="20" ry="11" fill="#9fe9e2"/>')
    s.add(f'<polygon points="{star(246, 272, 10, 4.2, -90)}" fill="#ff8f6b"/>'
          f'<polygon points="{star(320, 238, 9, 3.8, -70)}" fill="#ff9ecb"/>'
          f'<polygon points="{star(258, 224, 8, 3.4, -50)}" fill="#e85d75"/>')
    s.add(shell_on_sand(316, 272) + shell_on_sand(238, 244))
    # Vignette 2, the Coral Reef: a full painted coral garden with seagrass
    s.add(coral(_r.Random(9), 436, 352, '#b03070', '#ff9ecb', 56, 3, 7, -88)
          + coral(_r.Random(5), 466, 356, '#b23a2a', '#ffb347', 42, 2, 6, -78)
          + coral(_r.Random(21), 412, 356, '#2f7c5c', '#7fd8a8', 34, 2, 5, -98)
          + coral(_r.Random(13), 492, 372, '#7a3d9c', '#c79aea', 38, 2, 5, -82)
          + coral(_r.Random(33), 390, 344, '#c9512a', '#ff9e6b', 30, 2, 5, -94))
    s.add('<path d="M380 360 q-4 -14 2 -24 M470 384 q4 -12 -2 -22 M452 378 q-3 -10 2 -18" '
          'fill="none" stroke="#49a07a" stroke-width="3" stroke-linecap="round"/>')
    # Vignette 3, the Deep Sea: a jagged dark trench in the open water
    s.add('<path d="M536 350 C548 328 586 320 612 332 C632 342 630 360 608 370 C580 382 544 372 536 350 Z" fill="#1b3a5c"/>'
          '<path d="M548 350 C562 340 594 336 608 346" fill="none" stroke="#0d2338" stroke-width="4" stroke-linecap="round"/>'
          '<circle cx="570" cy="352" r="3" fill="#bfe9ff" opacity=".9"/><circle cx="592" cy="356" r="2.4" fill="#bfe9ff" opacity=".75"/>')
    # The red dashed trail, pool -> coral -> past the trench -> down to the X
    s.add('<path d="M300 272 C330 300 356 318 396 330 C434 340 478 336 516 348 C548 358 560 396 570 436" '
          'fill="none" stroke="#d94a3a" stroke-width="6.5" stroke-dasharray="15 13" stroke-linecap="round"/>')
    s.add('<circle cx="580" cy="466" r="25" fill="none" stroke="#d94a3a" stroke-width="5"/>'
          '<path d="M568 454 L592 478 M592 454 L568 478" stroke="#d94a3a" stroke-width="9" stroke-linecap="round"/>')
    # Compass rose, pearls by the X, and margin doodles: fish, bubbles, kelp
    s.add(f'<polygon points="{star(205, 450, 32, 8, -90, 4)}" fill="#8a6a3c"/>'
          f'<polygon points="{star(205, 450, 22, 5.5, -90, 4)}" fill="#f3ddb0"/>'
          f'<circle cx="205" cy="450" r="6" fill="#8a6a3c"/>'
          f'<circle cx="205" cy="414" r="4.5" fill="#d94a3a"/>')
    s.add('<circle cx="616" cy="490" r="6.5" fill="#fff6ea" stroke="#b89a74" stroke-width="2"/>'
          '<circle cx="631" cy="483" r="5.5" fill="#fff6ea" stroke="#b89a74" stroke-width="2"/>'
          '<circle cx="625" cy="498" r="4.5" fill="#fff6ea" stroke="#b89a74" stroke-width="2"/>')
    def _doodlefish(x, y, c, flip=1):
        return (f'<g transform="translate({x} {y}) scale({flip} 1)">'
                f'<path d="M0 0 C8 -8 22 -8 28 0 C22 8 8 8 0 0 Z" fill="{c}"/>'
                f'<path d="M28 0 L38 -7 L36 0 L38 7 Z" fill="{c}"/>'
                f'<circle cx="7" cy="-1.5" r="1.8" fill="#fdf2d8"/></g>')
    s.add(_doodlefish(500, 222, '#3a7d9c') + _doodlefish(560, 262, '#b03070', -1) + _doodlefish(222, 376, '#2f7c5c')
          + _doodlefish(238, 318, '#e0762a') + _doodlefish(266, 342, '#3a7d9c') + _doodlefish(594, 414, '#49a07a', -1))
    s.add('<circle cx="480" cy="200" r="4" fill="none" stroke="#5fa8ba" stroke-width="2"/>'
          '<circle cx="492" cy="188" r="3" fill="none" stroke="#5fa8ba" stroke-width="2"/>'
          '<circle cx="470" cy="186" r="2.4" fill="none" stroke="#5fa8ba" stroke-width="2"/>')
    s.add('<path d="M606 220 q-8 -16 2 -30 q10 -14 4 -30" fill="none" stroke="#2f7c5c" stroke-width="4" stroke-linecap="round"/>'
          '<path d="M606 220 q10 -12 6 -26" fill="none" stroke="#49a07a" stroke-width="3.5" stroke-linecap="round"/>'
          '<path d="M248 486 q8 -14 -2 -26 M248 486 q-8 -10 -4 -22" fill="none" stroke="#2f7c5c" stroke-width="3.5" stroke-linecap="round"/>')

    # The pre-sneeze face: eyes squeezed shut, mouth wide open mid "aaah"
    s.layer('whale_face_uhoh').add(
        '<path d="M231 296 Q246 286 261 296" fill="none" stroke="#1b1030" stroke-width="6" stroke-linecap="round"/>'
        '<ellipse cx="226" cy="344" rx="26" ry="19" fill="#5a2b3c"/><ellipse cx="226" cy="338" rx="26" ry="10" fill="#1b3a52"/>'
        '<ellipse cx="282" cy="326" rx="12" ry="8" fill="#ff9ecb" opacity=".55"/>')
    # The grotto's treasure hoard, Ariel style: four clusters that can each
    # tumble away when the sneeze hits. Drawn at their grotto positions.
    gold = s.lin([(0, '#fff0b0', 1), (.5, '#ffcf5a', 1), (1, '#c9882a', 1)])
    pearl_fill = s.rad([(0, '#ffffff', 1), (.6, '#fff1e2', 1), (1, '#e3c4a8', 1)], cx=.35, cy=.3, rr=.8)
    def pearls(pts, r=9):
        return ''.join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{pearl_fill}"/>' for x, y in pts)
    def coins(pts):
        return ''.join(f'<ellipse cx="{x}" cy="{y}" rx="11" ry="8" fill="#ffd866" stroke="#e09a1f" stroke-width="1.5"/><ellipse cx="{x-2}" cy="{y-2}" rx="5" ry="3" fill="#fff3c4" opacity=".8"/>' for x, y in pts)
    s.layer('hoard_left').add(
        f'<path d="M150 468 Q196 448 244 468 L236 476 L158 476 Z" fill="#8a6a3c"/>'
        f'<path d="M168 466 L178 420 L206 420 L216 466 Z" fill="{gold}" stroke="#a86a14" stroke-width="2"/>'
        f'<path d="M166 418 L218 418 L212 430 L172 430 Z" fill="{gold}"/>'
        f'<path d="M226 448 L238 428 L248 444 L258 424 L268 448 Z" fill="{gold}" stroke="#a86a14" stroke-width="2"/>'
        + coins(((150, 466), (166, 470), (240, 468), (256, 464))) + pearls(((146, 452), (226, 460)))
        + f'<circle cx="238" cy="436" r="4" fill="#e04a6a"/><circle cx="252" cy="436" r="4" fill="#2f9c86"/>')
    s.layer('hoard_right').add(
        f'<ellipse cx="610" cy="406" rx="24" ry="30" fill="#b9e8f2" stroke="{gold}" stroke-width="6"/>'
        f'<path d="M604 436 L616 436 L614 470 L606 470 Z" fill="{gold}"/>'
        f'<path d="M648 414 L672 414 L668 470 L652 470 Z" fill="#7fc9b8"/><path d="M652 414 L668 414 L666 404 L654 404 Z" fill="#4a9c8c"/>'
        + coins(((588, 470), (604, 474), (636, 472), (664, 476), (680, 470))) + pearls(((582, 458), (688, 458)))
        + f'<polygon points="{star(694, 436, 14, 6.5, -90)}" fill="#ff8f6b"/>')
    s.layer('hoard_floor').add(
        f'<path d="M352 540 Q400 516 448 540 L440 556 L360 556 Z" fill="#8a6a3c"/>'
        + coins(((350, 548), (368, 554), (388, 548), (410, 554), (430, 548), (448, 552), (466, 548)))
        + pearls(((346, 534), (402, 530), (458, 534)), 10)
        + f'<polygon points="{star(330, 548, 15, 7, -80)}" fill="#ffd27a"/>'
        f'<polygon points="{star(478, 552, 13, 6, -100)}" fill="#ff9ecb"/>')
    s.layer('hoard_strings').add(
        '<path d="M150 140 Q250 220 350 150" fill="none" stroke="#e8d8c0" stroke-width="2"/>'
        + pearls([(150 + i * 25, 140 + 76 * (1 - abs(i - 4) / 4) ** 1.2) for i in range(9)], 7)
        + '<path d="M470 130 Q560 210 650 140" fill="none" stroke="#e8d8c0" stroke-width="2"/>'
        + pearls([(470 + i * 22.5, 130 + 74 * (1 - abs(i - 4) / 4) ** 1.2) for i in range(9)], 7))
    return {name: s.svg_layer(name) for name in (
        'lock', 'afish', 'afish_face', 'whale', 'whale_face',
        'whale_face_uhoh', 'hoard_left', 'hoard_right', 'hoard_floor', 'hoard_strings',
        'fgfan_a', 'fgfan_b', 'bigmap')}

from frame import scene_home_layers

SCENES2 = {
    'home': (scene_home_layers, dict(bg='bg', kelp_far='far', kelp_mid='mid', kelp_left='mid', kelp_right='mid', fg='fg', grass='grass')),
    'coral': (scene_coral_layers, dict(bg='bg', kelp_far='far', fan_left='mid', fan_right='mid', fg='fg', grass='grass')),
    'chest': (scene_chest_layers, dict(bg='bg', kelp_far='far', kelp_mid='mid', fg='fg', chest_lid='piece', chest_box='piece', lamp='prop', lamp_face='vector', grass='grass')),
    'grotto': (scene_grotto_layers, dict(bg='bg', floor='fg', walls='fg', curtain='mid', bed='piece', lights='prop', lamp='prop', lamp_face='vector')),
    'map': (scene_map_layers, dict(bg='bg', kelp_far='far', kelp_mid='mid', floor='fg', grass='grass')),
    'hunt': (scene_hunt_layers, dict(bg='bg', kelp_far='far', fg='fg', grass='grass')),
    'deep': (scene_deep_layers, dict(bg='bg', kelp_far='far', fg='fg', grass='grass')),
    'iwalla': (scene_iwalla_layers, dict(bg='bg')),
    'iwallb': (scene_iwallb_layers, dict(bg='bg')),
    'iwallc': (scene_iwallc_layers, dict(bg='bg')),
    'ipillars': (scene_ipillars_layers, dict(pillar_a='fg', pillar_b='fg')),
    'ihome': (scene_ihome_layers, dict(bg='bg', wall='fg', items='piece')),
    'journeya': (scene_journeya_layers, dict(bg='bg')),
    'journeyb': (scene_journeyb_layers, dict(bg='bg')),
    'journeyc': (scene_journeyc_layers, dict(bg='bg')),
    'props': (scene_props_layers, dict(lock='prop', afish='prop', afish_face='vector', whale='piece', whale_face='vector',
                                       whale_face_uhoh='vector', hoard_left='prop', hoard_right='prop',
                                       hoard_floor='prop', hoard_strings='vector',
                                       fgfan_a='fg', fgfan_b='fg', bigmap='prop')),
}
