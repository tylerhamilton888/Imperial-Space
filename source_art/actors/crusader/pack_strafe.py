"""Bake a braced lateral step in each aim direction from the ready paintings."""
import math
from pathlib import Path

import numpy as np
from PIL import Image

from pack import PIVOT, REFLECT, SIZE, VIEWS, local_warp, ready


def step(painting, heading, frame):
    y, x = np.mgrid[:painting.height, :painting.width]
    # The far and near boot alternate planting and clearing the ground. Let
    # the motion fade above the hips so the sightline stays on the target.
    legs = np.clip((y - 104) / 67, 0, 1)
    leg_side = np.tanh((x - PIVOT[0]) / 6)
    phase = math.tau * frame / 8
    angle = heading * math.tau / 8
    stride = leg_side * math.cos(phase) * legs
    lift = np.maximum(0, leg_side * math.sin(phase)) * legs
    cloth = np.clip((y - 76) / 75, 0, 1) * np.clip((abs(x - PIVOT[0]) - 19) / 24, 0, 1)
    dx = -math.sin(angle) * 13 * stride + 2.3 * math.sin(phase) * cloth
    dy = math.cos(angle) * 8 * stride - lift * 6
    dy -= 1.9 * abs(math.sin(phase)) * (1 - legs)
    return local_warp(painting, dx, dy)


def main():
    w, h = SIZE
    sheet = Image.new("RGBA", (8*w, 8*h))
    for heading, view in enumerate(VIEWS):
        painting = ready(view)
        if REFLECT[heading]:
            painting = painting.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        for frame in range(8):
            cell = step(painting, heading, frame)
            bounds = cell.getchannel("A").point(lambda a: 255 if a > 25 else 0).getbbox()
            if min(bounds[0], bounds[1], w-bounds[2], h-bounds[3]) < 1:
                raise ValueError((heading, frame, bounds))
            sheet.paste(cell, (w*heading, h*frame))
    dest = Path(__file__).resolve().parents[3] / "game/art/movement/medium_strafe.webp"
    dest.parent.mkdir(exist_ok=True)
    sheet.save(dest, format="WEBP", quality=91, method=6)


if __name__ == "__main__":
    main()
