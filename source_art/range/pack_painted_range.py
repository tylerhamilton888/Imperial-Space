"""Register the illustrated hall and fixtures to the existing range collisions.

Run with Pillow 10+ from any directory. The lossless ImageGen masters are saved
beside this script. The earlier Blender set is the physical registration study.
The brass lane inlays are painted into the deck. Raised props are sorted
individually at their feet in Godot, while contact shadows stay on the ground.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent
RUNTIME = HERE.parents[1] / "game/art/range"
LANCZOS = Image.Resampling.LANCZOS

def register_hall(source: Image.Image) -> Image.Image:
    # Source cross sections give (source y, inside-left x, inside-right x).
    # Straighten the painted curbs onto the simulation's rectangular perimeter.
    # The extra 120 px above world zero retain the full height of the arsenal.
    rows = [(0, 0, 114, 1490), (250, 270, 114, 1490),
            (950, 871, 49, 1562), (1080, 971, 49, 1562)]
    world_x = (0, 100, 1480, 1600)
    mesh = []
    for (y0, sy0, left0, right0), (y1, sy1, left1, right1) in zip(rows, rows[1:]):
        upper = (0, left0, right0, source.width)
        lower = (0, left1, right1, source.width)
        for col in range(3):
            dest = (world_x[col], y0, world_x[col+1], y1)
            quad = (upper[col], sy0, lower[col], sy1,
                    lower[col+1], sy1, upper[col+1], sy0)
            mesh.append((dest, quad))
    return source.transform((1600, 1080), Image.Transform.MESH, mesh,
                            Image.Resampling.BICUBIC)

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
    # The inspection counter rests just behind the staff rail.
    pen.polygon([(345,248), (422,248), (435,257), (355,256)], fill=95)
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
    hall = register_hall(Image.open(HERE/"arsenal_forecourt.webp").convert("RGB"))
    ground = hall.crop((0, 120, 1600, 1080))
    add_ground_shadows(ground)
    hall.paste(ground, (0, 120))
    for row in range(2):
        for column in range(2):
            x,y = column*800,row*540
            hall.crop((x,y,x+800,y+540)).save(
                RUNTIME/f"deck_{column}_{row}.webp",quality=93,method=6)
    props = Image.open(HERE/"arsenal_fixtures.webp")
    cover = (149,44,2026,365)
    fixture(props,cover,(164,53),(180,87),(8,30),"north_cover")
    fixture(props,cover,(154,52),(170,87),(8,31),"south_cover")
    fixture(props,(109,453,2065,695),(140,35),(159,61),(10,22),"crew_rail")

    desk = Image.open(HERE/"inspection_desk.webp")
    fixture(desk,(42,42,1720,842),(88,43),(94,49),(3,3),"inspection_desk")

if __name__ == "__main__":
    main()
