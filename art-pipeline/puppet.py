"""The crab split into separately drawn pieces (same frame, so they stack), plus the painted-icon sources."""
import os
from chars import BLUR, CAR, claw, OUT

DEFS = BLUR + f'''
<radialGradient id="shellG" cx=".4" cy=".22" r=".95"><stop offset="0" stop-color="#ffc07a"/><stop offset=".42" stop-color="#ff7f3f"/><stop offset="1" stop-color="#dc3f2a"/></radialGradient>
<radialGradient id="eyeG" cx=".6" cy=".35" r=".8"><stop offset="0" stop-color="#ffffff"/><stop offset=".7" stop-color="#f4fbff"/><stop offset="1" stop-color="#bcd6e8"/></radialGradient>
<clipPath id="carClip"><path d="{CAR}"/></clipPath>
<clipPath id="eyeL"><circle cx="246" cy="116" r="37"/></clipPath><clipPath id="eyeR"><circle cx="354" cy="116" r="37"/></clipPath>
'''

def wrap(body, w=640, h=540, tr='translate(20 30)', defs=DEFS):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}"><defs>{defs}</defs><g transform="{tr}">{body}</g></svg>'

def crab_parts():
    legs = ''
    for side in (-1, 1):
        for (bx, by), (kx, ky), (fx, fy) in (((108, 352), (66, 16), (20, 56)), ((82, 370), (54, 40), (12, 52)), ((54, 380), (36, 54), (2, 46))):
            x0 = 300 + side * bx; x1 = x0 + side * kx; y1 = by + ky; x2 = x1 + side * fx; y2 = y1 + fy
            legs += f'<path d="M{x0} {by} Q{x1} {y1-22} {x1} {y1} T{x2} {y2}" fill="none" stroke="#b9341f" stroke-width="23" stroke-linecap="round" stroke-linejoin="round"/>'
            legs += f'<path d="M{x0} {by-3} Q{x1} {y1-25} {x1} {y1-3}" fill="none" stroke="#ff8a4c" stroke-width="8" stroke-linecap="round" opacity=".55"/>'
    arm_l = '<path d="M182 300 C132 304 100 272 108 226" fill="none" stroke="#c93b22" stroke-width="34" stroke-linecap="round"/><path d="M182 296 C136 298 108 270 114 230" fill="none" stroke="#ff8244" stroke-width="20" stroke-linecap="round"/>' + claw(100, 170, -24)
    arm_r = '<path d="M418 300 C474 296 510 252 502 200" fill="none" stroke="#c93b22" stroke-width="34" stroke-linecap="round"/><path d="M418 296 C470 290 502 250 496 204" fill="none" stroke="#ff8244" stroke-width="20" stroke-linecap="round"/>' + claw(508, 140, 22)
    body = f'''<path d="M262 200 C258 172 254 160 250 146" fill="none" stroke="#d9472a" stroke-width="18" stroke-linecap="round"/>
<path d="M338 200 C342 172 346 160 350 146" fill="none" stroke="#d9472a" stroke-width="18" stroke-linecap="round"/>
<path d="{CAR}" fill="url(#shellG)"/>
<g clip-path="url(#carClip)">
<ellipse cx="300" cy="408" rx="190" ry="60" fill="#a82a1c" opacity=".6" filter="url(#b12)"/>
<path d="M300 172 C380 172 450 204 450 284" fill="none" stroke="#fff0c0" stroke-width="12" opacity=".55" filter="url(#b3)"/>
<ellipse cx="246" cy="216" rx="66" ry="22" transform="rotate(-12 246 216)" fill="#ffffff" opacity=".38" filter="url(#b6)"/>
</g>
<circle cx="372" cy="218" r="10" fill="#ffd2a0" opacity=".8"/><circle cx="398" cy="244" r="6.5" fill="#ffd2a0" opacity=".8"/><circle cx="350" cy="198" r="5" fill="#ffd2a0" opacity=".8"/><circle cx="206" cy="246" r="6" fill="#ffd2a0" opacity=".6"/>
<ellipse cx="212" cy="300" rx="25" ry="14" fill="#ff3f6a" opacity=".4" filter="url(#b3)"/><ellipse cx="388" cy="300" rx="25" ry="14" fill="#ff3f6a" opacity=".4" filter="url(#b3)"/>
<path d="M266 288 Q300 336 334 288 Q300 298 266 288 Z" fill="#7a1f24"/>
<ellipse cx="300" cy="313" rx="13" ry="7" fill="#ff7d8f"/>'''
    eyes = '''<circle cx="246" cy="116" r="37" fill="url(#eyeG)"/><circle cx="354" cy="116" r="37" fill="url(#eyeG)"/>
<g clip-path="url(#eyeL)"><circle cx="254" cy="122" r="20" fill="#1b1030"/><circle cx="262" cy="113" r="8" fill="#fff"/><circle cx="247" cy="131" r="3.6" fill="#fff" opacity=".9"/><rect x="200" y="70" width="100" height="22" fill="#ff7f3f"/></g>
<g clip-path="url(#eyeR)"><circle cx="346" cy="122" r="20" fill="#1b1030"/><circle cx="354" cy="113" r="8" fill="#fff"/><circle cx="339" cy="131" r="3.6" fill="#fff" opacity=".9"/><rect x="300" y="70" width="100" height="22" fill="#ff7f3f"/></g>
<circle cx="246" cy="116" r="37" fill="none" stroke="#d9472a" stroke-width="3" opacity=".5"/><circle cx="354" cy="116" r="37" fill="none" stroke="#d9472a" stroke-width="3" opacity=".5"/>'''
    shut = '''<circle cx="246" cy="116" r="37" fill="#ff8a4a"/><circle cx="354" cy="116" r="37" fill="#ff8a4a"/>
<circle cx="246" cy="116" r="37" fill="none" stroke="#d9472a" stroke-width="3" opacity=".6"/><circle cx="354" cy="116" r="37" fill="none" stroke="#d9472a" stroke-width="3" opacity=".6"/>
<path d="M222 122 Q246 140 270 122" fill="none" stroke="#7a1f24" stroke-width="5" stroke-linecap="round"/><path d="M330 122 Q354 140 378 122" fill="none" stroke="#7a1f24" stroke-width="5" stroke-linecap="round"/>'''
    return dict(crab_legs=legs, crab_arm_l=arm_l, crab_arm_r=arm_r, crab_body=body, crab_eyes=eyes, crab_eyes_shut=shut)

G = '''<linearGradient id="shell" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff8e6"/><stop offset=".55" stop-color="#ffe2a8"/><stop offset="1" stop-color="#ffc66a"/></linearGradient>
<linearGradient id="paper" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff6e0"/><stop offset="1" stop-color="#e9c891"/></linearGradient>
<radialGradient id="pearl" cx=".36" cy=".3" r=".8"><stop offset="0" stop-color="#ffffff"/><stop offset=".45" stop-color="#fff4dc"/><stop offset=".85" stop-color="#e9cfa6"/><stop offset="1" stop-color="#c9a878"/></radialGradient>'''

def icon_shell():
    body = '''<g transform="rotate(-16 128 128)">
<path d="M26 132 C58 84 120 58 176 68 C198 100 198 162 176 192 C120 200 58 178 26 132 Z" fill="url(#shell)"/>
<path d="M74 96 Q90 132 74 164" fill="none" stroke="#ff9a3d" stroke-width="8" stroke-linecap="round" opacity=".9"/>
<path d="M106 78 Q126 132 106 180" fill="none" stroke="#ff9a3d" stroke-width="9" stroke-linecap="round" opacity=".9"/>
<path d="M140 68 Q162 132 140 190" fill="none" stroke="#ff9a3d" stroke-width="10" stroke-linecap="round" opacity=".9"/>
<path d="M40 122 C74 92 120 76 164 76" fill="none" stroke="#ffffff" stroke-width="7" stroke-linecap="round" opacity=".6"/>
<ellipse cx="178" cy="130" rx="24" ry="63" fill="#ff7eb6"/>
<ellipse cx="182" cy="130" rx="12" ry="46" fill="#d9508f"/>
<ellipse cx="178" cy="130" rx="24" ry="63" fill="none" stroke="#fff4dc" stroke-width="7"/>
<circle cx="27" cy="132" r="10" fill="#ffc66a"/>
<path d="M224 96 Q244 130 224 164" fill="none" stroke="#061a33" stroke-width="11" stroke-linecap="round"/>
<path d="M248 74 Q280 130 248 186" fill="none" stroke="#061a33" stroke-width="11" stroke-linecap="round"/>
</g>'''
    return wrap(body, 300, 256, 'translate(0 0)', BLUR + G)

def icon_map():
    body = '''<path d="M44 78 C96 60 150 92 212 72 L212 182 C150 202 96 170 44 190 Z" fill="url(#paper)"/>
<path d="M44 78 C96 60 150 92 212 72" fill="none" stroke="#ffffff" stroke-width="5" opacity=".7"/>
<rect x="26" y="62" width="30" height="144" rx="15" fill="#e3bd80"/><rect x="33" y="70" width="9" height="128" rx="4.5" fill="#fff0cf" opacity=".8"/>
<rect x="200" y="56" width="30" height="144" rx="15" fill="#e3bd80"/><rect x="207" y="64" width="9" height="128" rx="4.5" fill="#fff0cf" opacity=".8"/>
<path d="M76 158 C104 116 130 172 158 124" fill="none" stroke="#061a33" stroke-width="8" stroke-dasharray="2 17" stroke-linecap="round"/>
<path d="M162 96 L184 118 M184 96 L162 118" stroke="#ff9a3d" stroke-width="10" stroke-linecap="round"/>
<path d="M70 104 q10 -10 20 0 q10 10 20 0" fill="none" stroke="#17879c" stroke-width="6" stroke-linecap="round"/>'''
    return wrap(body, 256, 256, 'translate(0 0)', BLUR + G)

def icon_pearl():
    body = '''<circle cx="64" cy="64" r="54" fill="url(#pearl)"/>
<ellipse cx="82" cy="86" rx="24" ry="16" fill="#ffb9d6" opacity=".35" filter="url(#b6)"/>
<ellipse cx="44" cy="82" rx="18" ry="14" fill="#9fe8de" opacity=".3" filter="url(#b6)"/>
<ellipse cx="46" cy="40" rx="17" ry="11" transform="rotate(-28 46 40)" fill="#ffffff" opacity=".95"/>'''
    return wrap(body, 128, 128, 'translate(0 0)', BLUR + G)

if __name__ == '__main__':
    for name, body in crab_parts().items():
        open(os.path.join(OUT, name + '.svg'), 'w').write(wrap(body))
    open(os.path.join(OUT, 'icon_shell.svg'), 'w').write(icon_shell())
    open(os.path.join(OUT, 'icon_map.svg'), 'w').write(icon_map())
    open(os.path.join(OUT, 'icon_pearl.svg'), 'w').write(icon_pearl())
    print('ok')

def small_sprites():
    from scenes import seastar, FISH, COMMON
    from chars import bubble
    t = lambda body, w, h: f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}"><defs>{COMMON}</defs>{body}</svg>'
    return dict(star_pink=t(seastar(40, 40, 18, '#ff7eb6', -80), 80, 80), star_orange=t(seastar(32, 32, 13, '#ff9a3d', -100), 64, 64),
                sprite_bubble=t(bubble(24, 24, 17), 48, 48), sprite_fish=t(f'<g transform="translate(22 14) scale(.4)">{FISH}</g>', 44, 28))

if __name__ == '__main__':
    for name, svg in small_sprites().items():
        open(os.path.join(OUT, name + '.svg'), 'w').write(svg)
    print('small ok')
