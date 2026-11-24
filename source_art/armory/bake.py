"""Register the right-handed movement, strike and guard poses and export each swappable item once."""
from pathlib import Path
from PIL import Image, ImageDraw
import json

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[1] / "game/armory"
# Source pixels: ground, right fist, right shoulder, weapon rotation from its resting diagonal.
KEYS = [
    ((235,419),(216,196),(190,115),-66), ((683,419),(658,190),(635,111),-66),
    ((1126,421),(1115,205),(1090,117),-66), ((1570,418),(1552,194),(1528,111),-66),
    ((238,864),(175,486),(192,550),-166), ((677,864),(658,550),(642,550),-129),
    ((1110,864),(1250,551),(1124,553),-44), ((1564,864),(1568,650),(1528,555),12),
]
SCALE = 0.405
CELL = (256,208)
PIVOT = (128,181)

def fit(im, size):
    return im.convert("RGBa").resize(size, Image.Resampling.LANCZOS).convert("RGBA")


def add_idle_guard(plates, hands, sockets):
    # A separate painting holds the fist at the breastbone. Register its feet
    # to the same point as the gait before drawing equipment from the sockets.
    source = Image.open(HERE/"guard.webp").convert("RGBA")
    feet = (705,1019)
    density = 0.170
    offset = tuple(PIVOT[i]-round(feet[i]*density) for i in range(2))
    def local(x,y):
        return (offset[0]+round(x*density),offset[1]+round(y*density))
    frame = Image.new("RGBA",CELL)
    frame.alpha_composite(fit(source,tuple(round(s*density) for s in source.size)),offset)
    mask = Image.new("L",CELL)
    outline = [(734,401),(752,386),(783,384),(805,393),(809,409),
               (803,447),(785,465),(754,466),(735,450),(727,433)]
    ImageDraw.Draw(mask).polygon([local(x,y) for x,y in outline],fill=255)
    knuckles = Image.new("RGBA",CELL)
    knuckles.paste(frame,(0,0),mask)
    plates.paste(frame,(0,416))
    hands.paste(knuckles,(0,416))
    sockets.append([*local(771,425),*local(635,304),-99])

def main():
    source = Image.open(HERE/"poses.webp").convert("RGBA")
    plates = Image.new("RGBA",(1024,624))
    hands = Image.new("RGBA",plates.size)
    sockets = []
    for index,(feet,fist,shoulder,angle) in enumerate(KEYS):
        col, row = index % 4, index // 4
        left, top = round(col*source.width/4), round(row*source.height/2)
        tile = source.crop((left,top,round((col+1)*source.width/4),round((row+1)*source.height/2)))
        art = fit(tile,tuple(round(s*SCALE) for s in tile.size))
        offset = (PIVOT[0]-round((feet[0]-left)*SCALE), PIVOT[1]-round((feet[1]-top)*SCALE))
        frame = Image.new("RGBA",CELL)
        frame.alpha_composite(art,offset)
        def local(point):
            return tuple(PIVOT[i]+round((point[i]-feet[i])*SCALE) for i in range(2))
        grip = local(fist)
        mask = Image.new("L",CELL)
        pen = ImageDraw.Draw(mask)
        x,y=grip
        pen.ellipse((x-6,y-5,x+6,y+5),fill=255)
        if index in (4,5):
            elbow = local((136,539) if index == 4 else (606,582))
            pen.line((elbow,grip),fill=255,width=11)
        knuckles = Image.new("RGBA",CELL)
        knuckles.paste(frame,(0,0),mask)
        at = (col*256,row*208)
        plates.paste(frame,at)
        hands.paste(knuckles,at)
        sockets.append([*grip,*local(shoulder),angle])
    add_idle_guard(plates,hands,sockets)
    plates.save(OUT/"body.webp",quality=95,method=6)
    hands.save(OUT/"hands.png")
    (OUT/"sockets.json").write_text(json.dumps(sockets)+"\n")
    gear = Image.open(HERE/"equipment.webp").convert("RGBA")
    for name,box,size in [
        ("ivory",(90,118,609,586),(31,28)),
        ("winged",(783,119,1369,631),(39,34)),
        ("hammer",(1479,54,2106,670),(73,72)),
    ]:
        fit(gear.crop(box),size).save(OUT/(name+".png"))

if __name__ == "__main__":
    main()
