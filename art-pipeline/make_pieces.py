"""Paint characters and small objects as separate pieces that stack in one frame.
Usage: python3 make_pieces.py ophelia|daphne|violet|crab|icons|shells ...
Faces (eyes, brows, mouth) are saved crisp and never painted."""
import os, sys
import render
from sprites import sprite, OUT

def write(name, svg):
    open(os.path.join(OUT, name + '.svg'), 'w').write(svg); render.main([f'{name}:2:1'])

def sister(who):
    import mpuppet
    p, style = mpuppet.SISTERS[who]
    for part, svg in mpuppet.parts(p, style).items():
        name = f'm_{who}_{part}'; write(name, svg)
        sprite(name, name + '.png', (528, 606), paint_it=part not in ('eyes', 'shut'))

def crab():
    import puppet
    for name, body in puppet.crab_parts().items():
        write(name, puppet.wrap(body)); sprite(name, name + '.png', (500, 422), paint_it='eyes' not in name)

def icons():
    import puppet
    for name, fn, size in (('icon_shell', puppet.icon_shell, (150, 128)), ('icon_map', puppet.icon_map, (128, 128))):
        write(name, fn()); sprite(name, name + '.png', size, radii=(12, 6, 3), thresholds=(-1, 6, 8), max_len=(6, 7, 5), amp=1.6)
    write('icon_pearl', puppet.icon_pearl()); sprite('icon_pearl', 'icon_pearl.png', (64, 64), radii=(10, 5, 3), thresholds=(-1, 6, 9), max_len=(5, 6, 4), amp=1.0)

def shells():
    from chars import shell
    for name, cols in (('shell_orange', ('#ffa24a', '#f0642a', '#b8431d')), ('shell_teal', ('#63e6d6', '#1fa3b5', '#12788c'))):
        write(name, shell(*cols)); sprite(name, name + '_p.png', (130, 105), radii=(12, 6, 3), thresholds=(-1, 6, 8), max_len=(6, 7, 5), amp=1.6)

if __name__ == '__main__':
    for what in sys.argv[1:]:
        {'crab': crab, 'icons': icons, 'shells': shells}.get(what, lambda: sister(what))()
