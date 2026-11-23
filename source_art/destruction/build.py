"""Bake registered shutter states and loose fixture paint from the runtime masters."""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

ART = Path(__file__).resolve().parents[2] / "game/art"
OUT = ART / "destruction"
OUT.mkdir(exist_ok=True)
wall = Image.open(ART / "proving/wall_intact.webp").convert("RGBA")
open_wall = Image.open(ART / "proving/wall_breached.webp").convert("RGBA")

# Tears follow the perspective of the panel seams. The illuminated lip faces up.
tears = [
    [(73,86),(83,86),(88,89),(95,87),(103,91),(99,94),(91,92),(88,95),(83,90)],
    [(63,95),(72,94),(81,92),(85,88),(91,91),(95,87),(101,89),(107,86),
     (122,89),(115,95),(124,96),(121,103),(107,99),(101,103),(92,99),(86,109),
     (80,106),(74,110),(76,101),(67,102)],
    [(93,108),(101,105),(110,106),(123,101),(125,106),(115,110),(119,112),
     (108,111),(98,117),(102,111)]
]
for stage, name in [(1, "shutter_scored"), (3, "shutter_torn")]:
    mask = Image.new("L", wall.size)
    d = ImageDraw.Draw(mask)
    for tear in tears[:stage]:
        d.polygon(tear, fill=255)
    outer = mask.filter(ImageFilter.MaxFilter(5))
    edge = ImageChops.subtract(outer, mask)
    struck = Image.composite(Image.new("RGBA",wall.size,"#514136"),wall,edge)
    bright = ImageChops.subtract(ImageChops.offset(mask,0,1),mask)
    struck.paste((206,165,115,255),mask=bright)
    struck.paste(open_wall,mask=mask)
    pen = ImageDraw.Draw(struck)
    pen.line([(68,80),(75,84),(79,83),(84,87)], fill="#554338", width=1)
    if stage == 3:
        pen.line([(65,111),(77,106),(81,108),(86,99)], fill="#d09a69", width=1)
        # A bent slat catches light while the torn edge below it sits in shadow.
        pen.polygon([(64,96),(80,93),(85,89),(90,92),(82,99),(69,101)],fill="#393638")
        pen.polygon([(64,96),(80,93),(85,89),(88,91),(80,96),(68,99)],fill="#887968")
        pen.line([(64,96),(80,93),(85,89)],fill="#cfb595")
        pen.polygon([(111,103),(123,100),(119,111),(115,119),(114,111)],fill="#504941")
        pen.line([(123,101),(119,111),(115,119)],fill="#b79c7b")
        pen.line([(104,91),(112,86),(116,86),(123,81)],fill="#302b2a",width=2)
    struck.save(OUT / (name+".webp"), lossless=True, method=6)

# Pick loose metal, capstone and hazard stripe from the shutter's own paint.
chips = Image.new("RGBA",(96,32))
for i,(box,outline) in enumerate([
    ((62,91,87,110), [(0,4),(18,3),(24,7),(18,14),(5,18),(1,14)]),
    ((24,48,48,70), [(2,2),(15,0),(23,6),(19,15),(9,21),(1,12)]),
    ((61,120,90,139), [(0,1),(28,6),(23,15),(8,14),(2,9)])
]):
    sample = wall.crop(box)
    cut = Image.new("L",sample.size)
    ImageDraw.Draw(cut).polygon(outline,fill=255)
    sample.putalpha(ImageChops.multiply(cut,sample.getchannel("A")))
    chips.alpha_composite(sample,(32*i+(32-sample.width)//2,(32-sample.height)//2))
chips.save(OUT/"fixture_fragments.webp",lossless=True)

# Waist-high cover breaks along the joints between its facing and stone cap.
rail = Image.open(ART / "range/north_cover.webp").convert("RGBA")
cracked = rail.copy()
pen = ImageDraw.Draw(cracked)
for crack in [[(52,40),(54,45),(51,49),(57,55),(54,61),(59,68),(57,76)],
              [(93,36),(90,41),(93,47),(88,50)],
              [(134,43),(132,47),(136,54),(130,60),(134,65)]]:
    pen.line([(x+1,y) for x,y in crack],fill="#a69478",width=2)
    pen.line(crack,fill="#382e24",width=2)
pen.polygon([(48,40),(57,40),(54,45),(52,44)],fill="#82715e")
cracked.save(OUT/"cover_cracked.webp",lossless=True)
fractured = cracked.copy()
mask = Image.new("L",rail.size,255)
pen = ImageDraw.Draw(mask)
pen.polygon([(53,33),(97,31),(94,42),(90,45),(87,52),(83,50),(78,59),
             (73,61),(69,69),(62,64),(56,67),(53,61),(54,53),(49,50),(54,46)],fill=0)
alpha = ImageChops.multiply(mask,cracked.getchannel("A"))
lip = ImageChops.multiply(alpha,ImageOps.invert(mask.filter(ImageFilter.MinFilter(5))))
fractured.paste((146,125,98,255),mask=lip)
fractured.putalpha(alpha)
fractured.save(OUT/"cover_spalled.webp",lossless=True)
# Retain the broken base. Two fallen sections of facing keep the crest and posts
# identifiable even after the remaining heap becomes traversable.
rubble = Image.new("RGBA",rail.size)
rubble.alpha_composite(rail.crop((8,73,171,82)).resize((157,6)),(11,76))
for box, size, angle, xy in [((10,32,24,71),(30,8),-6,(12,72)),
                            ((25,51,71,70),(35,9),8,(32,67)),
                            ((75,35,103,73),(25,12),-13,(79,67)),
                            ((107,50,154,70),(38,8),-6,(112,72)),
                            ((158,31,171,73),(23,7),14,(140,68))]:
    f = rail.crop(box).resize(size,Image.Resampling.LANCZOS).rotate(angle,Image.Resampling.BICUBIC,expand=True)
    rubble.alpha_composite(f,xy)
rubble.save(OUT/"cover_rubble.webp",lossless=True)
