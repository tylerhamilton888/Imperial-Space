"""Pack the owner-selected references and the new scene paintings for Godot."""
import json
from pathlib import Path
from shutil import copyfile

from PIL import Image, ImageOps

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
KITS = ROOT / "art_studies/kits"
MASTERS = HERE / "masters"
LANCZOS = Image.Resampling.LANCZOS


def store(image, folder, name):
    folder.mkdir(parents=True, exist_ok=True)
    image.save(folder / (name + ".webp"), quality=92, method=6, exact=True)


def pack_background(zone):
    image = Image.open(MASTERS / (zone + ".webp")).convert("RGB")
    canvas = ImageOps.fit(image, (1280, 720), method=LANCZOS)
    for row in range(2):
        for col in range(2):
            box = (col*640, row*360, (col+1)*640, (row+1)*360)
            store(canvas.crop(box), KITS / zone, f"plate_{col}_{row}")


def pack_objects():
    definitions = json.loads((HERE / "objects.json").read_text())
    for sheet, objects in definitions.items():
        source = Image.open(MASTERS / (sheet + ".webp")).convert("RGBA")
        for obj in objects:
            frame = source.crop(obj["crop"])
            # Premultiplication keeps transparent pixels out of colored edge samples.
            resized = frame.convert("RGBa").resize(tuple(obj["size"]), LANCZOS).convert("RGBA")
            store(resized, KITS / obj["group"], obj["name"])


def cut_reference(board, box):
    meta = json.loads((ROOT / "reference_art/source_manifest.json").read_text())
    info = next(item for item in meta if item["derivative"] == board)
    ref = Image.open(ROOT / "reference_art" / board)
    sx = ref.width / info["source_dimensions"][0]
    sy = ref.height / info["source_dimensions"][1]
    return ref.crop(tuple(round(v * (sx if i % 2 == 0 else sy)) for i, v in enumerate(box)))


def pack_interface():
    # Extract only the painted interiors. Keybinds, panel edges and text are live controls.
    for board, icons in [
        ("08_karth_vale_wide.jpg", [(589,"rifle"),(675,"sword"),(761,"dodge"),
                                    (847,"guard"),(933,"grenade"),(1019,"medical")]),
        ("10_proving_ground_heavy.jpg", [(525,"cannon"),(613,"hammer"),(876,"impact")]),
    ]:
        for x, name in icons:
            icon = cut_reference(board, (x,834,x+61,888))
            store(icon.resize((64,56), LANCZOS), KITS / "interface", name)
    portrait = cut_reference("09_cruiser_bridge.jpg", (49,667,308,883))
    store(portrait, KITS / "interface", "captain_vale")


def pack_scale_figures():
    source = ROOT / "game/art/actors"
    definitions = json.loads((source / "poses.json").read_text())
    dest = ROOT / "art_studies/review/scale"
    dest.mkdir(parents=True, exist_ok=True)
    copyfile(ROOT / "game/art/range/north_cover.webp", dest / "cover.webp")
    for role, heading in [("crusader",7),("gunner",3),("raider",3),("soldier",7)]:
        w, h = definitions[role]["cell"]
        plate = Image.open(source / f"{role}_0.webp")
        store(plate.crop((heading*w,0,(heading+1)*w,h)),dest,role)


if __name__ == "__main__":
    for key in ("proving","district","bridge"):
        pack_background(key)
    pack_objects()
    pack_interface()
    pack_scale_figures()
