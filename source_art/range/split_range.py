"""Converts the two Blender passes into four deck plates and independent props."""
import sys
from pathlib import Path
from PIL import Image

source, dest = map(Path, sys.argv[1:])
dest.mkdir(parents=True, exist_ok=True)
deck = Image.open(source / "deck.png").convert("RGBA")
for row in range(2):
    for column in range(2):
        x, y = column*800, row*480
        plate = deck.crop((x,y,x+800,y+480))
        plate.save(dest / f"deck_{column}_{row}.webp", quality=92, method=6)
props = Image.open(source / "props.png")
for name, roi in [
    ("north_cover",(770,230,950,317)),
    ("south_cover",(1080,570,1250,657)),
    ("crew_rail",(276,216,435,277))
]:
    props.crop(roi).save(dest / f"{name}.webp",lossless=True,method=6)
