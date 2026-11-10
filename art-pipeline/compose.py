"""Flatten a painted scene back into one picture so you can look at it before building the screen.
Usage: python3 compose.py <scene>     Reads painted/manifest.json, writes painted/<scene>_check.png (800x600)."""
import os, sys, json
from PIL import Image
from sprites import ART

def compose(scene):
    m = json.load(open(os.path.join(ART, 'manifest.json')))[scene]
    out = Image.open(os.path.join(ART, m['bg']['file'])).convert('RGBA')
    for name, e in m.items():   # manifest order is back to front
        if name == 'bg': continue
        out.alpha_composite(Image.open(os.path.join(ART, e['file'])).convert('RGBA'), (int(e['x'] * 2), int(e['y'] * 2)))
    p = os.path.join(ART, scene + '_check.png'); out.convert('RGB').resize((800, 600), Image.LANCZOS).save(p); print(p)

if __name__ == '__main__':
    compose(sys.argv[1])
