"""Register the illustrated hall and fixtures to the existing range collisions.

Run with Pillow 10+ from any directory. The native ImageGen paintings are saved
beside this script. The earlier Blender set is the physical registration study.
The two brass course markings are painted into the deck. Raised props are sorted
individually at their feet in Godot, while contact shadows stay on the ground.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent
RUNTIME = HERE.parents[1] / "game/art/range"
LANCZOS = Image.Resampling.LANCZOS

def register_hall(source: Image.Image) -> Image.Image:
    # Edges of the rear/side bulkheads and front service trench on the painting.
    # Anchor the center of the sparring ring to its original gameplay location.
    strips_x = [(0, 0), (140, 100), (437, 438), (1490, 1480), (1619, 1600)]
    strips_y = [(0, 0), (197, 130), (486, 487), (809, 830), (971, 960)]
    result = Image.new("RGB", (1600, 960))
    for (sx, x), (sx1, x1) in zip(strips_x, strips_x[1:]):
        for (sy, y), (sy1, y1) in zip(strips_y, strips_y[1:]):
            tile = source.crop((sx, sy, sx1, sy1)).resize((x1-x, y1-y), LANCZOS)
            result.paste(tile, (x,y))
    return result

def add_ground_shadows(hall: Image.Image) -> None:
    # Warm lights are high and to the left. Do not let shadows travel with
    # the sort pivot or appear in front of an actor who is behind the prop.
    for x,y,width in [(780,282,160), (1090,622,150)]:
        mask = Image.new("L", hall.size)
        pen = ImageDraw.Draw(mask)
        pen.polygon([(x+4,y+7), (x+width-2,y+5), (x+width+13,y+31),
                     (x+width+8,y+39), (x+12,y+36)], 96)
        hall.paste((21,17,34), mask=mask.filter(ImageFilter.GaussianBlur(3)))
        contact = Image.new("L", hall.size)
        ImageDraw.Draw(contact).ellipse((x+1,y+24,x+width+2,y+33), 115)
        hall.paste((18,14,30), mask=contact.filter(ImageFilter.GaussianBlur(1.3)))
    mask = Image.new("L", hall.size)
    pen = ImageDraw.Draw(mask)
    pen.line([(300,279),(432,279)], fill=82, width=4)
    for x in (293,356,418):
        pen.line([(x,269),(x+10,279)], fill=80, width=4)
    hall.paste((25,21,38), mask=mask.filter(ImageFilter.GaussianBlur(1.9)))

def fixture(source: Image.Image, bounds: tuple, size: tuple,
            canvas: tuple, anchor: tuple, name: str) -> None:
    image = source.crop(bounds)
    # Premultiplied resize keeps opaque gold edges clean at a small game size.
    image = image.convert("RGBa").resize(size, LANCZOS).convert("RGBA")
    output = Image.new("RGBA",canvas)
    output.alpha_composite(image,anchor)
    output.save(RUNTIME/f"{name}.webp",lossless=True,method=6)

def main() -> None:
    hall = register_hall(Image.open(HERE/"painted_hall.png").convert("RGB"))
    add_ground_shadows(hall)
    for row in range(2):
        for column in range(2):
            x,y = column*800,row*480
            hall.crop((x,y,x+800,y+480)).save(
                RUNTIME/f"deck_{column}_{row}.webp",quality=93,method=6)
    props = Image.open(HERE/"painted_fixtures.png")
    cover = (244,14,1881,328)
    fixture(props,cover,(164,63),(180,87),(8,20),"north_cover")
    fixture(props,cover,(154,63),(170,87),(8,20),"south_cover")
    fixture(props,(244,443,1881,712),(140,46),(159,61),(10,11),"crew_rail")

if __name__ == "__main__":
    main()
