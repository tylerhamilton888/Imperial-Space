"""Register the eight painted facings to contact, fist and shoulder pivots."""
from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[1] / "game/transit/court"
CELL = (200, 202)
PIVOT = (100, 182)
# Absolute master coordinates. Each tuple registers the feet, grip and pauldron.
NEAR = [
 [(197,338,235,140,193,105),(548,331,554,144,518,109),(906,325,878,137,846,102),(1245,333,1197,129,1296,100)],
 [(201,687,248,498,197,463),(548,699,569,506,522,463),(911,696,897,505,852,463),(1258,693,1212,496,1300,457)],
 [(197,1050,297,836,209,815),(549,1055,558,867,528,828),(894,1058,849,865,845,825),(1257,1045,1154,846,1299,817)]]
FAR = [
 [(177,333,118,115,218,126),(536,327,486,99,509,128),(905,321,967,85,963,102),(1257,318,1346,116,1307,122)],
 [(171,661,117,474,213,481),(518,683,484,455,510,486),(910,688,959,435,960,459),(1260,687,1356,467,1315,477)],
 [(174,1031,53,826,220,839),(535,1049,440,779,485,818),(900,1042,972,768,960,807),(1274,1043,1382,789,1323,829)]]
STRIDE = [(220,406,292,182,226,138),(675,418,695,184,638,137),(1106,414,1095,178,1037,134),(1513,411,1491,172,1604,129),
          (197,841,143,561,218,590),(655,851,731,522,613,582),(1107,850,1174,529,1175,547),(1535,853,1633,556,1597,559)]

def resize(im, dims):
    return im.convert("RGBa").resize(dims, Image.Resampling.LANCZOS).convert("RGBA")

def foreground(im, white_sheet):
    data = np.asarray(im.convert("RGBA")).copy()
    if white_sheet:
        # Discard the pale layout and its cell borders; keep the helmet highlights.
        candidate = data[:, :, :3].min(axis=2) < 198
        labels, count = ndimage.label(candidate)
        if count == 0:
            raise ValueError("Empty sprite cell")
        sizes = np.bincount(labels.ravel())
        sizes[0] = 0
        mask = ndimage.binary_fill_holes(labels == sizes.argmax())
        data[:, :, 3] = 255 * mask
    else:
        alpha = data[:, :, 3].astype(float)
        data[:, :, 3] = np.clip((alpha - 60) * 255 / 177, 0, 255)
    return Image.fromarray(data)

def bake_knight():
    atlas = Image.new("RGBA", (8 * CELL[0], 4 * CELL[1]))
    mounts = [[None] * 8 for _ in range(4)]
    for name, records, offset in [("near",NEAR,0), ("far",FAR,4), ("stride",[STRIDE[:4],STRIDE[4:]],0)]:
        im = Image.open(HERE / (name + ".webp"))
        w, h = im.width / 4, im.height / len(records)
        sx = 0.535 * 362 / w
        sy = 0.465 * 362 / w
        for row, entries in enumerate(records):
            for col, (fx,fy,gx,gy,ax,ay) in enumerate(entries):
                left, top = round(col*w), round(row*h)
                tile = im.crop((left+4,top+4,round((col+1)*w)-4,round((row+1)*h)-4))
                tile = foreground(tile, name != "stride")
                tile = resize(tile, (round(tile.width*sx),round(tile.height*sy)))
                direction = col + (4*row if name=="stride" else offset)
                pose = 3 if name=="stride" else row
                dx = PIVOT[0] - round((fx-left-4)*sx)
                dy = PIVOT[1] - round((fy-top-4)*sy)
                frame = Image.new("RGBA", CELL)
                frame.alpha_composite(tile, (dx,dy))
                atlas.paste(frame,(direction*CELL[0],pose*CELL[1]))
                mounts[pose][direction] = [round((gx-fx)*sx),round((gy-fy)*sy),round((ax-fx)*sx),round((ay-fy)*sy)]
    atlas.save(OUT/"knight.webp",quality=95,method=5)
    (OUT/"mounts.json").write_text(json.dumps(mounts)+"\n")

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    from scenery import bake_floor, bake_queue
    bake_floor()
    bake_queue()
    car = foreground(Image.open(HERE/"car.webp"),False)
    car = car.crop(car.getchannel("A").getbbox())
    resize(car,(338,229)).save(OUT/"tram.webp",quality=93)
    worker = foreground(Image.open(HERE/"operator.webp"),False)
    sheet = Image.new("RGBA",(4*100,90))
    # Brass switch base stays fixed while the worker changes pose.
    for i,(fx,fy) in enumerate([(367,596),(952,600),(1484,600),(2025,596)]):
        left=i*543
        tile=worker.crop((left,0,left+543,724))
        tile=resize(tile,(75,100))
        sheet.alpha_composite(tile,(i*100+69-round((fx-left)*.138),77-round(fy*.138)))
    sheet.save(OUT/"operator.webp",quality=94)
    bake_knight()

if __name__ == "__main__":
    main()
