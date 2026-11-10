#!/bin/bash
# Syncs design assets into the app's bundled Art folder.
#   assets/ -> app/Art/   (app/Art is generated output; assets/ stays the source of truth)
# - converts .webp layers to .png (keeps decode simple and fast on iOS)
# - pre-bakes the 1px blur into kelp-far (the reference CSS blurs it live;
#   source art is @2x, so the baked radius is 2px)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets"
DST="$ROOT/app/Art"

rm -rf "$DST"
mkdir -p "$DST"
rsync -a --exclude 'fonts' "$SRC/" "$DST/"

find "$DST" -name '*.webp' | while read -r f; do
  png="${f%.webp}.png"
  if ! dwebp -quiet "$f" -o "$png" 2>/dev/null; then
    sips -s format png "$f" --out "$png" >/dev/null
  fi
  rm "$f"
done

python3 - "$DST" <<'EOF'
import sys, pathlib
from PIL import Image, ImageFilter
root = pathlib.Path(sys.argv[1])
for p in sorted(root.glob('scenes/*/kelp-far.png')):
    im = Image.open(p).convert('RGBA')
    im.filter(ImageFilter.GaussianBlur(2)).save(p)
    print(f'pre-blurred {p.relative_to(root)}')
EOF

echo "Art synced to $DST"
