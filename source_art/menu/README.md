# Title illustration

The title is an original generated painting of an Imperial shipyard, commissioned for this project using the right side of visual reference 01 as an illustration guide. The full-resolution source is a lossless WebP. The live labels and controls are drawn by the game.

The art brief placed a brass-trimmed ivory cruiser above an inhabited coastal industrial city, with indigo in the open left sky for the title, amber lamps and crimson banners. A pale turquoise gas giant provides the horizon. The brief specified ink-edged painted shapes, bold light/shadow separation and an uncluttered ship silhouette.

Bake from the repository root with Python and Pillow.

```python
from PIL import Image, ImageOps

with Image.open("source_art/menu/imperial_shipyard.webp") as painting:
    frame = ImageOps.fit(painting, (1024, 576), method=Image.Resampling.LANCZOS)
    frame.save("game/art/menu/orbital_watch.jpg", quality=94, subsampling=0, optimize=True)
```
