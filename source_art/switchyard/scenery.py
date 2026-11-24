"""Separate station architecture from the ground and register the boarding objects."""
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[1]/'game/transit/court'
# Scene offsets are the bounding-box origins of the masks in the 1280 x 720 painting.
LANDMARKS = {
    'canopy': [(0,0),(663,0),(0,373)],
    'west_pier': [(743,0),(949,0),(945,31),(951,81),(952,110),(891,149),(767,109),(756,93),(762,69),(785,51),(772,37)],
    'east_pier': [(1114,0),(1280,0),(1280,210),(1195,193),(1135,181),(1135,159),(1145,145),(1146,100),(1138,75),(1151,67),(1150,34),(1140,14)],
}

def bake_floor():
    court=Image.open(HERE/'court.webp').resize((1280,720),Image.Resampling.LANCZOS).convert('RGB')
    ground=court.copy()
    # Restored stone under the removable scenery. Fold the clean floor sample at
    # joins so moving a component in the editor exposes continuous paving.
    sample=court.crop((606,276,854,415))
    patch=Image.new('RGB',court.size)
    for row in range(6):
        for col in range(6):
            piece=sample.transpose(Image.Transpose.FLIP_LEFT_RIGHT) if col%2 else sample
            if row%2: piece=piece.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
            patch.paste(piece,(col*sample.width,row*sample.height))
    def lift(name,mask):
        box=mask.getbbox()
        part=court.crop(box).convert('RGBA')
        part.putalpha(mask.crop(box))
        part.save(OUT/(name+'.webp'),quality=94)
        ground.paste(patch,(0,0),mask)
        print(name,box)
    for name, outline in LANDMARKS.items():
        mask=Image.new('L',court.size)
        ImageDraw.Draw(mask).polygon(outline,fill=255)
        lift(name,mask)
    # Preserve the open areas between branches when the player walks behind them.
    rgb=np.asarray(court).astype(float)
    y,x=np.indices((720,1280))
    r,g,b=rgb.transpose(2,0,1)
    canopy=(x>1043)&(y>182)&(y<438)&(g>b*1.5)&((g>r*.95)|(b<g*.42))
    mask=Image.fromarray(np.uint8(canopy)*255)
    draw=ImageDraw.Draw(mask)
    draw.polygon([(1178,314),(1214,343),(1229,334),(1240,292),(1261,303),(1250,342),(1221,381),(1217,413),(1234,436),(1182,446),(1198,409),(1207,386),(1198,355),(1171,339)],fill=255)
    draw.polygon([(1069,477),(1084,465),(1096,438),(1168,407),(1250,389),(1279,387),(1280,495),(1157,540),(1069,506)],fill=255)
    lift('planter',mask)
    for i in range(2):
        ground.crop((640*i,0,640*(i+1),720)).save(OUT/f'paving_{i}.webp',quality=92)

def bake_queue():
    from bake import foreground, resize
    passengers=foreground(Image.open(HERE/'travelers.webp'),False)
    sheet=Image.new('RGBA',(240,180))
    for row in range(2):
        for col in range(3):
            tile=passengers.crop((col*512,row*512,(col+1)*512,(row+1)*512))
            bounds=tile.getchannel('A').getbbox()
            tile=tile.crop(bounds)
            height=69 if row==0 else 72
            tile=resize(tile,(round(tile.width*height/tile.height),height))
            sheet.alpha_composite(tile,(col*80+(80-tile.width)//2,row*90+80-height))
    sheet.save(OUT/'travelers.webp',quality=95)
    barrier=foreground(Image.open(HERE/'barrier.webp'),False)
    for i in range(4):
        x=(i%2)*642
        y=(i//2)*612
        # The two lower frames register to the same base as the intact gate.
        tile=barrier.crop((x+10,y+12,x+637,y+568))
        resize(tile,(145,99)).save(OUT/f'barrier_{i}.webp',quality=94)

if __name__=='__main__':
    bake_floor()
    bake_queue()
