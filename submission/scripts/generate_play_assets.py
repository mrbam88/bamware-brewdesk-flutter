#!/usr/bin/env python3
"""App-agnostic Play asset generator (Bamware house rail).

Reads submission/assets-src/branding.json:
  app_name, tagline, background_color, foreground_color,
  mark (transparent square PNG), headline_font, body_font

Writes:
  android/app/src/main/res/  — adaptive launcher icon (anydpi-v26 XML,
    background color resource, per-density foreground + legacy squares)
  submission/metadata/android/en-US/images/icon.png          (512x512)
  submission/metadata/android/en-US/images/featureGraphic.png (1024x500)

Run from the app repo root:  python3 submission/scripts/generate_play_assets.py
Reuse in another app: copy submission/scripts + assets-src, swap branding.
"""
import json
import os
from PIL import Image, ImageDraw, ImageFont

CONFIG = json.load(open("submission/assets-src/branding.json"))
BG = CONFIG["background_color"]
MARK = Image.open(CONFIG["mark"]).convert("RGBA")
RES = "android/app/src/main/res"

def mark_scaled(box: int, fraction: float) -> Image.Image:
    size = int(box * fraction)
    return MARK.resize((size, size), Image.LANCZOS)

def paste_centered(canvas: Image.Image, layer: Image.Image, dy: int = 0):
    canvas.paste(
        layer,
        ((canvas.width - layer.width) // 2,
         (canvas.height - layer.height) // 2 + dy),
        layer,
    )

# --- Adaptive icon ---------------------------------------------------------
os.makedirs(f"{RES}/mipmap-anydpi-v26", exist_ok=True)
os.makedirs(f"{RES}/values", exist_ok=True)
with open(f"{RES}/mipmap-anydpi-v26/ic_launcher.xml", "w") as f:
    f.write(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '</adaptive-icon>\n'
    )
with open(f"{RES}/values/ic_launcher_background.xml", "w") as f:
    f.write(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        f'<resources><color name="ic_launcher_background">{BG}</color></resources>\n'
    )

DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
for density, scale in DENSITIES.items():
    folder = f"{RES}/mipmap-{density}"
    os.makedirs(folder, exist_ok=True)
    # Foreground layer: 108dp canvas, glyph inside the 66dp safe zone.
    canvas_px = int(108 * scale)
    fg = Image.new("RGBA", (canvas_px, canvas_px), (0, 0, 0, 0))
    paste_centered(fg, mark_scaled(canvas_px, 0.44))
    fg.save(f"{folder}/ic_launcher_foreground.png")
    # Legacy icon: full square, bg + glyph (launchers mask it themselves).
    legacy_px = int(48 * scale)
    legacy = Image.new("RGBA", (legacy_px, legacy_px), BG)
    paste_centered(legacy, mark_scaled(legacy_px, 0.68))
    legacy.save(f"{folder}/ic_launcher.png")

# --- Play store graphics ---------------------------------------------------
img_dir = "submission/metadata/android/en-US/images"
os.makedirs(img_dir, exist_ok=True)

icon = Image.new("RGBA", (512, 512), BG)
paste_centered(icon, mark_scaled(512, 0.64))
icon.convert("RGB").save(f"{img_dir}/icon.png")

feature = Image.new("RGBA", (1024, 500), BG)
badge = mark_scaled(500, 0.62)
feature.paste(badge, (78, (500 - badge.height) // 2), badge)
head = ImageFont.truetype(CONFIG["headline_font"], 108)
try:
    head.set_variation_by_axes([700])
except OSError:
    pass
body = ImageFont.truetype(CONFIG["body_font"], 34)
draw = ImageDraw.Draw(feature)
fg_color = CONFIG["foreground_color"]
draw.text((420, 170), CONFIG["app_name"], font=head, fill=fg_color)
draw.text((424, 300), CONFIG["tagline"], font=body, fill=fg_color)
feature.convert("RGB").save(f"{img_dir}/featureGraphic.png")
print("adaptive icon (5 densities), icon.png, featureGraphic.png written")
