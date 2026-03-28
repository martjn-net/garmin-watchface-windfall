#!/usr/bin/env python3
"""Generate small complication icons for the watch face (18x18, white on transparent)."""
from PIL import Image, ImageDraw
import math

SIZE = 18
HALF = SIZE // 2

def new_icon():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)

def icon_heart():
    """Heart icon for heart rate."""
    img, draw = new_icon()
    # Two circles for top of heart + triangle for bottom
    r = 3
    draw.ellipse([3, 3, 3 + 2*r, 3 + 2*r], fill=(255, 255, 255, 255))
    draw.ellipse([9, 3, 9 + 2*r, 3 + 2*r], fill=(255, 255, 255, 255))
    draw.polygon([(2, 7), (9, 15), (16, 7)], fill=(255, 255, 255, 255))
    return img

def icon_bolt():
    """Lightning bolt for battery."""
    img, draw = new_icon()
    points = [
        (10, 1), (5, 9), (9, 9),
        (8, 17), (13, 8), (9, 8)
    ]
    draw.polygon(points, fill=(255, 255, 255, 255))
    return img

def icon_shoe():
    """Shoe/footstep for steps."""
    img, draw = new_icon()
    # Simplified shoe/sneaker silhouette
    draw.ellipse([3, 2, 9, 8], fill=(255, 255, 255, 255))   # toe
    draw.ellipse([7, 5, 15, 13], fill=(255, 255, 255, 255))  # heel
    draw.rectangle([5, 5, 12, 10], fill=(255, 255, 255, 255)) # bridge
    # Sole
    draw.rectangle([2, 8, 15, 11], fill=(255, 255, 255, 255))
    return img

def icon_stairs():
    """Stairs for floors climbed."""
    img, draw = new_icon()
    w = 255
    # Step pattern (bottom-left to top-right)
    draw.rectangle([2, 13, 6, 16], fill=(w, w, w, w))
    draw.rectangle([6, 9, 10, 16], fill=(w, w, w, w))
    draw.rectangle([10, 5, 14, 16], fill=(w, w, w, w))
    draw.rectangle([14, 1, 16, 16], fill=(w, w, w, w))
    return img

def icon_flame():
    """Flame for calories."""
    img, draw = new_icon()
    # Flame shape using polygon
    points = [
        (9, 1),    # top
        (12, 5),
        (14, 9),
        (14, 13),
        (12, 16),  # bottom right
        (9, 17),   # bottom center
        (6, 16),   # bottom left
        (4, 13),
        (4, 9),
        (6, 5),
    ]
    draw.polygon(points, fill=(255, 255, 255, 255))
    # Inner dark area (gives flame depth)
    inner = [
        (9, 8),
        (11, 11),
        (11, 14),
        (9, 15),
        (7, 14),
        (7, 11),
    ]
    draw.polygon(inner, fill=(0, 0, 0, 0))
    return img

# Generate all icons
icons = {
    "ic_heart": icon_heart(),
    "ic_bolt": icon_bolt(),
    "ic_shoe": icon_shoe(),
    "ic_stairs": icon_stairs(),
    "ic_flame": icon_flame(),
}

for name, img in icons.items():
    path = f"../resources/drawables/{name}.png"
    img.save(path)
    print(f"Generated {path}")
