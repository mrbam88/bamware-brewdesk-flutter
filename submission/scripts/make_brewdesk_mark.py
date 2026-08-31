#!/usr/bin/env python3
"""Draws the BrewDesk mark: a coffee mug whose steam is wifi arcs.

BrewDesk-specific; the rest of the pipeline (generate_play_assets.py) is
app-agnostic and consumes whatever mark.png branding.json points at.
Output: a 1024x1024 transparent PNG, glyph auto-centered, drawn in the
foreground color from branding.json.
"""
import json
from PIL import Image, ImageDraw

CONFIG = json.load(open("submission/assets-src/branding.json"))
FG = CONFIG["foreground_color"]
S = 1024
img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
w = 44  # stroke width

# Mug body: open-top, rounded-bottom outline
cup_l, cup_r = 310, 650
cup_top, cup_bot = 470, 800
d.rounded_rectangle(
    [cup_l, cup_top, cup_r, cup_bot], radius=70, outline=FG, width=w,
    corners=(False, False, True, True),
)

# Handle: a ring overlapping the right wall so it reads attached
hr_outer = [cup_r - w // 2, cup_top + 55, cup_r + 150, cup_top + 245]
d.arc(hr_outer, start=-90, end=90, fill=FG, width=w)

# Steam = wifi arcs rising from the mug, classic quarter span
cx = (cup_l + cup_r) // 2
base_y = 385
for r in (150, 240):
    d.arc([cx - r, base_y - r, cx + r, base_y + r],
          start=225, end=315, fill=FG, width=w)
d.ellipse([cx - 40, base_y - 100, cx + 40, base_y - 20], fill=FG)

# Auto-center the glyph in the canvas
bbox = img.getbbox()
glyph = img.crop(bbox)
out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
out.paste(glyph, ((S - glyph.width) // 2, (S - glyph.height) // 2), glyph)
out.save("submission/assets-src/mark.png")
print(f"mark.png written (glyph {glyph.width}x{glyph.height})")
