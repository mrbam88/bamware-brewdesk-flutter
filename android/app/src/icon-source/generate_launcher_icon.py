#!/usr/bin/env python3
"""BrewDesk Android launcher icon generator.

Draws a coffee cup + wifi-signal mark (matching the sibling native
BrewDesk iOS app icon's design language) in the Warm Utilitarian
palette (green #2D5A4C background, cream #FAF9F6 mark) and rasterizes
it to every Android launcher mipmap density.

No third-party image-conversion tools required -- pure Pillow drawing,
supersampled and downsampled for crisp edges at every size.
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

GREEN = (45, 90, 76, 255)  # #2D5A4C
CREAM = (250, 249, 246, 255)  # #FAF9F6

SUPERSAMPLE = 1024

# Densities Flutter's default Android template ships, unchanged.
DENSITIES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def draw_mark(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), GREEN)
    d = ImageDraw.Draw(img)

    cx = size * 0.5

    # --- wifi arcs (signal above the cup) ---
    apex = (cx, size * 0.535)
    band_width = size * 0.045
    for radius in (size * 0.075, size * 0.145, size * 0.215):
        bbox = [
            apex[0] - radius,
            apex[1] - radius,
            apex[0] + radius,
            apex[1] + radius,
        ]
        d.arc(bbox, start=180, end=360, fill=CREAM, width=int(band_width))
    d.ellipse(
        [apex[0] - size * 0.02, apex[1] - size * 0.02, apex[0] + size * 0.02, apex[1] + size * 0.02],
        fill=CREAM,
    )

    # --- cup handle (ring, drawn first so the cup body occludes the inner arc) ---
    handle_cx, handle_cy = cx + size * 0.185, size * 0.665
    outer_r = size * 0.075
    inner_r = size * 0.042
    d.ellipse(
        [handle_cx - outer_r, handle_cy - outer_r, handle_cx + outer_r, handle_cy + outer_r],
        fill=CREAM,
    )
    d.ellipse(
        [handle_cx - inner_r, handle_cy - inner_r, handle_cx + inner_r, handle_cy + inner_r],
        fill=GREEN,
    )

    # --- cup body (tapered trapezoid, rounded corners) ---
    top_l = (cx - size * 0.155, size * 0.605)
    top_r = (cx + size * 0.155, size * 0.605)
    bot_r = (cx + size * 0.115, size * 0.755)
    bot_l = (cx - size * 0.115, size * 0.755)
    d.polygon([top_l, top_r, bot_r, bot_l], fill=CREAM)
    # round the two bottom corners
    corner_r = size * 0.018
    for pt in (bot_l, bot_r):
        d.ellipse(
            [pt[0] - corner_r, pt[1] - corner_r, pt[0] + corner_r, pt[1] + corner_r],
            fill=CREAM,
        )

    # --- saucer ---
    saucer_l = cx - size * 0.205
    saucer_r = cx + size * 0.205
    saucer_t = size * 0.765
    saucer_b = size * 0.795
    d.rounded_rectangle(
        [saucer_l, saucer_t, saucer_r, saucer_b],
        radius=(saucer_b - saucer_t) / 2,
        fill=CREAM,
    )

    return img


def main() -> None:
    source_dir = Path(__file__).parent
    res_dir = source_dir.parent / "main" / "res"

    master = draw_mark(SUPERSAMPLE)
    master.save(source_dir / "ic_launcher_master.png")

    for name, px in DENSITIES.items():
        resized = master.resize((px, px), Image.LANCZOS)
        d = res_dir / name
        d.mkdir(exist_ok=True)
        resized.save(d / "ic_launcher.png")
        print(f"wrote {d / 'ic_launcher.png'} ({px}x{px})")


if __name__ == "__main__":
    main()
