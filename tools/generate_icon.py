#!/usr/bin/env python3
"""Generate a windfall (Fallobst) apple launcher icon — bruised, wormy, wilted leaf."""
from PIL import Image, ImageDraw
import math

def draw_apple_icon(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    s = size / 60.0  # scale factor (designed at 60px)

    # Dark circle background
    cx, cy = size // 2, size // 2
    r = int(27 * s)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(25, 25, 25, 255))

    # Apple body — asymmetric, slightly lopsided (fallen fruit)
    apple_cx = int(30 * s)
    apple_cy = int(35 * s)
    apple_rx = int(14 * s)
    apple_ry = int(14 * s)

    points = []
    for angle in range(360):
        rad = math.radians(angle)
        rx = apple_rx
        ry = apple_ry
        # Top indent (apple dimple)
        if 75 <= angle <= 105:
            ry -= int(3 * s)
        # Dent on lower right (bruise/fall damage)
        if 310 <= angle <= 350:
            rx -= int(2.5 * s)
        # Slight bulge on left (asymmetry)
        if 180 <= angle <= 240:
            rx += int(1 * s)
        x = apple_cx + rx * math.cos(rad)
        y = apple_cy + ry * math.sin(rad)
        points.append((x, y))

    # Overripe yellow-green (Fallobst color)
    draw.polygon(points, fill=(145, 155, 50, 255))

    # Brown bruise spots (impact damage from falling)
    bx, by = int(34 * s), int(39 * s)
    draw.ellipse([bx - int(4*s), by - int(3*s), bx + int(4*s), by + int(3*s)],
                 fill=(95, 75, 30, 255))
    draw.ellipse([int(23*s), int(36*s), int(28*s), int(40*s)],
                 fill=(105, 85, 35, 255))

    # Wormhole — small dark circle with slight rim
    wx, wy = int(26 * s), int(33 * s)
    wr = int(2.2 * s)
    draw.ellipse([wx - wr - 1, wy - wr - 1, wx + wr + 1, wy + wr + 1],
                 fill=(110, 90, 40, 255))  # rim
    draw.ellipse([wx - wr, wy - wr, wx + wr, wy + wr],
                 fill=(40, 30, 15, 255))  # hole

    # Stem — slightly crooked
    stem_base = (int(30 * s), int(21 * s))
    stem_mid = (int(31 * s), int(16 * s))
    stem_top = (int(29 * s), int(13 * s))
    draw.line([stem_base, stem_mid, stem_top], fill=(90, 65, 35, 255), width=max(2, int(2 * s)))

    # Wilted leaf — drooping, curled edges
    leaf_points = [
        (int(30 * s), int(15 * s)),
        (int(36 * s), int(17 * s)),  # droops down instead of up
        (int(40 * s), int(19 * s)),
        (int(38 * s), int(15 * s)),
        (int(34 * s), int(13 * s)),
    ]
    draw.polygon(leaf_points, fill=(75, 100, 35, 255))  # dull olive (wilted)
    # Leaf vein
    draw.line([(int(31 * s), int(15 * s)), (int(38 * s), int(17 * s))],
              fill=(55, 75, 25, 255), width=max(1, int(s)))

    # Subtle highlight on apple
    hx, hy = int(24 * s), int(29 * s)
    hr = int(3 * s)
    draw.ellipse([hx - hr, hy - hr, hx + hr, hy + hr], fill=(165, 175, 65, 160))

    return img


# 60x60 for launcher icon
img60 = draw_apple_icon(60)
img60.save("../resources/drawables/launcher_icon.png")
print("Generated 60x60 launcher_icon.png")

# 256x256 for store listing
img256 = draw_apple_icon(256)
img256.save("../resources/drawables/store_icon.png")
print("Generated 256x256 store_icon.png")
