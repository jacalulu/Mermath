"""The three sisters split into separately drawn pieces that share one frame, so they stack and can be moved independently."""
import os, math
from chars import BLUR, HEAD, TAIL, FLUKE, BANGS, TORSO, BACK_LONG, BACK_BOB, hexmix, star, glint, eye, shell_top, OUT, SKIN

SISTERS = {
    'ophelia': (dict(SKIN, hair='#5c3822', hairD='#3a2012', hairT='#4a2a18', hairL='#8f5e3c', ta='#ffabd4', tb='#f0508f', fin='#ffd3e8', acc='#ffd27a', accD='#d48a1f', iris='#8a5526'), 'long'),
    'daphne': (dict(SKIN, hair='#e0582c', hairD='#b03c1c', hairT='#c8481f', hairL='#ff9a5a', ta='#fff7a6', tb='#ffd03a', fin='#fffbd0', acc='#8fe9df', accD='#2ba3a0', iris='#3f8fe6'), 'pigtails'),
    'violet': (dict(SKIN, hair='#e0582c', hairD='#b03c1c', hairT='#c8481f', hairL='#ff9a5a', ta='#c9b0ff', tb='#7a55e0', fin='#e6dbff', acc='#ffd27a', accD='#d48a1f', iris='#3f8fe6'), 'buns'),
}

BACK_CAP = "M300 126 C374 122 420 176 412 246 C410 270 402 288 390 298 C360 318 240 318 210 298 C198 288 190 270 188 246 C180 176 226 122 300 126 Z"
PIG = "M206 158 C154 136 102 180 100 244 C98 288 112 322 88 370 C128 352 150 320 152 280 C154 248 174 218 212 204 Z"

def pigtail(p, side):
    """One pigtail hanging from a hair tie at the side of the head. Drawn for the left side and mirrored for the right."""
    hairL, hairD, acc, accD = p['hairL'], p['hairD'], p['acc'], p['accD']
    g = f'''<path d="{PIG}" fill="url(#hairG)"/>
<g clip-path="url(#pigClip)" fill="none" stroke-linecap="round">
<path d="M200 170 C158 160 122 196 114 240 C108 280 118 316 104 352" stroke="{hairL}" stroke-width="7" opacity=".55"/>
<path d="M208 196 C172 208 146 244 140 284 C136 314 122 338 104 358" stroke="{hairD}" stroke-width="6" opacity=".55"/>
<path d="M196 184 C162 188 136 216 128 254 C122 286 128 314 114 340" stroke="{hairD}" stroke-width="4" opacity=".35"/>
<path d="M152 170 C128 188 112 218 110 250" stroke="#ffffff" stroke-width="9" opacity=".22" filter="url(#b2)"/>
</g>
<ellipse cx="203" cy="183" rx="12" ry="24" transform="rotate(-18 203 183)" fill="url(#accG)" stroke="{accD}" stroke-width="2"/>
<ellipse cx="200" cy="175" rx="4" ry="8" transform="rotate(-18 200 175)" fill="#ffffff" opacity=".6"/>'''
    return g if side < 0 else f'<g transform="translate(600 0) scale(-1 1)">{g}</g>'

def parts(p, style):
    skinL, skin, skinS = p['skinL'], p['skin'], p['skinS']
    hair, hairD, hairT, hairL = p['hair'], p['hairD'], p['hairT'], p['hairL']
    ta, tb, fin, acc, accD, iris = p['ta'], p['tb'], p['fin'], p['acc'], p['accD'], p['iris']
    tbD = hexmix(tb, '#1a1040', .55)
    BACK = BACK_LONG if style == 'long' else BACK_CAP if style == 'pigtails' else BACK_BOB
    defs = BLUR + f'''
<radialGradient id="skinG" cx=".66" cy=".28" r=".9"><stop offset="0" stop-color="{skinL}"/><stop offset=".55" stop-color="{skin}"/><stop offset="1" stop-color="{skinS}"/></radialGradient>
<linearGradient id="tailG" x1=".1" y1="0" x2=".9" y2="1"><stop offset="0" stop-color="{ta}"/><stop offset=".55" stop-color="{hexmix(ta, tb, .6)}"/><stop offset="1" stop-color="{tb}"/></linearGradient>
<linearGradient id="finG" x1=".1" y1=".8" x2=".9" y2=".1"><stop offset="0" stop-color="{tb}"/><stop offset=".45" stop-color="{fin}" stop-opacity=".85"/><stop offset="1" stop-color="#ffffff" stop-opacity=".55"/></linearGradient>
<linearGradient id="hairG" x1=".85" y1="0" x2=".15" y2="1"><stop offset="0" stop-color="{hairL}"/><stop offset=".3" stop-color="{hair}"/><stop offset=".7" stop-color="{hairD}"/><stop offset="1" stop-color="{hairT}"/></linearGradient>
<linearGradient id="bangG" x1=".7" y1="0" x2=".3" y2="1"><stop offset="0" stop-color="{hairL}"/><stop offset=".6" stop-color="{hair}"/><stop offset="1" stop-color="{hairD}"/></linearGradient>
<radialGradient id="bunG" cx=".62" cy=".3" r=".8"><stop offset="0" stop-color="{hairL}"/><stop offset=".6" stop-color="{hair}"/><stop offset="1" stop-color="{hairD}"/></radialGradient>
<linearGradient id="accG" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{hexmix(acc, '#ffffff', .45)}"/><stop offset="1" stop-color="{acc}"/></linearGradient>
<pattern id="scales" width="26" height="22" patternUnits="userSpaceOnUse" patternTransform="rotate(-18)"><path d="M0 0 A13 13 0 0 0 26 0 M-13 11 A13 13 0 0 0 13 11 M13 11 A13 13 0 0 0 39 11" fill="none" stroke="#ffffff" stroke-width="2" opacity=".55"/></pattern>
<clipPath id="tailClip"><path d="{TAIL}"/></clipPath><clipPath id="headClip"><path d="{HEAD}"/></clipPath><clipPath id="torsoClip"><path d="{TORSO}"/></clipPath>
<clipPath id="backClip"><path d="{BACK}"/></clipPath><clipPath id="pigClip"><path d="{PIG}"/></clipPath><clipPath id="bangClip"><path d="{BANGS}"/></clipPath>
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
    elif style == 'buns':
        for bx in (208, 392):
            s = -1 if bx < 300 else 1
            back += f'''<circle cx="{bx}" cy="140" r="47" fill="url(#bunG)"/>
<path d="M{bx-26} 150 C{bx-22} 120 {bx+16} 112 {bx+24} 140 C{bx+28} 158 {bx+4} 168 {bx-4} 152 C{bx-8} 142 {bx+6} 136 {bx+8} 146" fill="none" stroke="{hairD}" stroke-width="4" stroke-linecap="round" opacity=".55"/>
<path d="M{bx-30} 122 C{bx-18} 102 {bx+12} 98 {bx+28} 112" fill="none" stroke="{hairL}" stroke-width="7" stroke-linecap="round" opacity=".7"/>
<ellipse cx="{bx-s*26}" cy="176" rx="17" ry="9" transform="rotate({s*-38} {bx-s*26} 176)" fill="{acc}"/>'''
    veins = ''.join(f'<path d="M466 620 Q{mx} {my} {x} {y}" fill="none" stroke="#fff" stroke-width="2" opacity=".4"/>' for mx, my, x, y in ((452, 560, 464, 492), (478, 580, 484, 536), (510, 610, 556, 632), (520, 626, 590, 656), (500, 634, 530, 652)))
    pearls = ''.join(f'<circle cx="{276+48*i/6:.1f}" cy="{347+9*math.sin(math.pi*i/6):.1f}" r="4.4" fill="#fff8ee" stroke="{skinS}" stroke-width=".8"/>' for i in range(7))
    fluke = f'<path d="{FLUKE}" fill="url(#finG)"/>{veins}<path d="{FLUKE}" fill="none" stroke="#ffffff" stroke-width="2.5" opacity=".6"/>'
    tail = f'''<path d="M252 500 C224 506 204 530 200 558 C226 550 246 536 258 520 Z" fill="{fin}" opacity=".75"/>
<path d="{TAIL}" fill="url(#tailG)"/><path d="{TAIL}" fill="url(#scales)" opacity=".5"/>
<g clip-path="url(#tailClip)" fill="none">
<path d="M262 438 C244 480 246 540 262 600 C276 650 330 700 392 690 C430 686 460 664 474 628" stroke="{tbD}" stroke-width="40" opacity=".5" filter="url(#b12)"/>
<path d="M452 612 C442 640 420 652 394 652 C350 652 326 620 330 570 C334 530 344 480 338 438" stroke="#ffffff" stroke-width="14" opacity=".55" filter="url(#b6)"/>
</g>
{glint(300, 520, 9, '#ffffff', .9)}{glint(318, 596, 7, '#ffffff', .8)}{glint(380, 668, 8, '#ffffff', .85)}{glint(286, 478, 5, '#ffffff', .8)}'''
    arm = f'''<path d="M256 364 C232 386 210 398 202 380 C196 364 190 346 186 328" fill="none" stroke="{skinS}" stroke-width="25" stroke-linecap="round"/>
<path d="M257 362 C233 384 211 396 203 378 C197 362 191 344 187 326" fill="none" stroke="{skin}" stroke-width="20" stroke-linecap="round"/>
<g stroke="{skin}" stroke-width="9" stroke-linecap="round"><path d="M185 322 L170 298"/><path d="M186 320 L184 292"/><path d="M188 321 L198 296"/><path d="M190 324 L208 312"/></g>
<circle cx="186" cy="322" r="15" fill="{skin}"/>'''
    body = f'''<path d="M344 364 C372 382 392 400 386 420 C380 438 370 446 362 452" fill="none" stroke="{skinS}" stroke-width="25" stroke-linecap="round"/>
<path d="M345 362 C373 380 393 398 387 418 C381 436 371 444 363 450" fill="none" stroke="{skin}" stroke-width="20" stroke-linecap="round"/>
<circle cx="361" cy="453" r="14" fill="{skin}"/>
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
<path d="M206 240 C194 266 196 296 212 320 C212 294 216 268 226 244 Z" fill="{hair}"/>
<path d="M394 240 C406 266 404 296 388 320 C388 294 384 268 374 244 Z" fill="{hair}"/>
<path d="{BANGS}" fill="url(#bangG)"/>
<g clip-path="url(#bangClip)"><path d="M232 176 C266 152 334 152 368 178" fill="none" stroke="#ffffff" stroke-width="10" stroke-linecap="round" opacity=".28" filter="url(#b2)"/>
<path d="M326 182 C300 202 262 208 236 208" fill="none" stroke="{hairD}" stroke-width="5" opacity=".5"/></g>
<polygon points="{star(368, 178, 23, 10.5, -70)}" fill="#ffd166" stroke="#ffd166" stroke-width="6" stroke-linejoin="round"/>
<polygon points="{star(368, 178, 11, 5, -70)}" fill="#fff3c4" opacity=".9"/>'''
    face = f'''<path d="M246 212 Q262 204 278 210" fill="none" stroke="{hairD}" stroke-width="4" stroke-linecap="round" opacity=".75"/>
<path d="M322 210 Q338 204 354 212" fill="none" stroke="{hairD}" stroke-width="4" stroke-linecap="round" opacity=".75"/>
<path d="M296 276 q4 4 8 0" fill="none" stroke="{skinS}" stroke-width="2.6" stroke-linecap="round"/>
<path d="M284 290 Q300 314 316 290 Q300 296 284 290 Z" fill="#a23b4a"/>
<ellipse cx="300" cy="303" rx="7" ry="3.6" fill="#ff8fa0"/>
'''
    eyes = face + eye(262, 254, iris, -1) + eye(338, 254, iris, 1)
    shut = face + ''.join(f'<path d="M{cx-20} {254+2} Q{cx} {254+20} {cx+20} {254+2}" fill="none" stroke="#2a1a3c" stroke-width="6" stroke-linecap="round"/><path d="M{cx+s*20} {254+2} l{s*8} -5" stroke="#2a1a3c" stroke-width="5" stroke-linecap="round"/>' for cx, s in ((262, -1), (338, 1)))
    w = lambda b: f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 680 780" width="680" height="780"><defs>{defs}</defs><g transform="translate(30 40)">{b}</g></svg>'
    out = dict(hair=w(back), fluke=w(fluke), tail=w(tail), arm=w(arm), body=w(body), eyes=w(eyes), shut=w(shut))
    if style == 'pigtails': out.update(pigl=w(pigtail(p, -1)), pigr=w(pigtail(p, 1)))
    return out

if __name__ == '__main__':
    for who, (p, style) in SISTERS.items():
        for part, svg in parts(p, style).items():
            open(os.path.join(OUT, f'm_{who}_{part}.svg'), 'w').write(svg)
    print('ok')
