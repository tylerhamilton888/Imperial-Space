"""Pack the station, streetcar, lever operator and left-facing Knight artwork."""
from pathlib import Path
import json
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[1] / "game/transit"

def fit(im, size):
    return im.convert("RGBa").resize(size,Image.Resampling.LANCZOS).convert("RGBA")

def main():
    station = Image.open(HERE/"station.webp").resize((1280,720),Image.Resampling.LANCZOS).convert("RGB")
    for i in range(2):
        station.crop((640*i,0,640*(i+1),720)).save(OUT/f"platform_{i}.webp",quality=92,method=5)
    # These platform lamps are in front of the rails when the car passes behind them.
    for name,points in [
        ("west_lamp",[(49,324),(55,319),(57,298),(52,285),(59,280),(63,271),(68,280),(77,286),(72,300),(71,323),(79,328),(57,340),(48,337)]),
        ("east_lamp",[(1191,324),(1204,320),(1205,302),(1200,282),(1207,280),(1212,270),(1217,282),(1227,286),(1221,301),(1219,321),(1227,327),(1224,338),(1191,339)])]:
        mask=Image.new("L",station.size)
        ImageDraw.Draw(mask).polygon(points,fill=255)
        patch=station.convert("RGBA")
        patch.putalpha(mask)
        patch.crop(mask.getbbox()).save(OUT/(name+".png"))
    car = Image.open(HERE/"car.webp")
    fit(car.crop((46,1,2128,701)),(486,164)).save(OUT/"car.webp",quality=94)
    worker=Image.open(HERE/"signalman.webp")
    sheet=Image.new("RGBA",(4*160,126))
    # Every state registers the immobile brass pivot of the switch.
    for i,x in enumerate([352,914,1457,2006]):
        box=(i*543,75,(i+1)*543,621)
        part=fit(worker.crop(box),(109,109))
        sheet.alpha_composite(part,(160*i+116-round((x-box[0])*.2),10))
    sheet.save(OUT/"signalman.webp",quality=93)
    master=Image.open(HERE/"knight_left.webp")
    # Each source frame uses its own horizontal bounds and boot pivot.
    keys=[
        ((0,0,412,411),169,394,95,170,132,103),
        ((413,0,827,411),608,394,514,160,559,105),
        ((830,0,1247,411),1005,394,933,173,957,102),
        ((0,415,414,830),183,818,95,575,134,505),
        ((414,415,829,830),589,810,512,465,531,511),
        ((831,415,1247,830),1009,812,960,553,950,520),
        ((0,833,414,1255),179,1241,35,934,141,932),
        ((415,833,830,1255),609,1241,494,1020,550,948),
        ((832,833,1247,1255),1000,1241,930,982,964,940)]
    atlas=Image.new("RGBA",(1024,624)); sockets=[]
    for i,(bounds,fx,fy,gx,gy,sx,sy) in enumerate(keys):
        tile=master.crop(bounds); k=.403
        tile=fit(tile,tuple(round(k*s) for s in tile.size))
        x=(i%4)*256+128-round((fx-bounds[0])*k)
        y=(i//4)*208+181-round((fy-bounds[1])*k)
        atlas.alpha_composite(tile,(x,y))
        sockets.append([128+round((gx-fx)*k),181+round((gy-fy)*k),128+round((sx-fx)*k),181+round((sy-fy)*k)])
    atlas.save(OUT/"knight_left.webp",quality=93,method=5)
    (OUT/"grips.json").write_text(json.dumps(sockets)+"\n")

if __name__=="__main__":
    main()
