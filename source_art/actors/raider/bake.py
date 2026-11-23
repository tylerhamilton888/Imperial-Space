"""Register original raider paintings, then place a rigid cleaver at each fist."""
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageOps
from scipy import ndimage as nd

HERE = Path(__file__).resolve().parent
ART = HERE.parents[2] / "game/art"
OUT = ART / "raider"
CELL = (256,194)
BOOT = (128,163)
LANCZOS = Image.Resampling.LANCZOS
VIEWS = [2,1,0,1,2,3,4,3]
MIRROR = {3,4,5}
# Grip center in each original painting. Feet and fists are registered
# independently. The fist anchors both the visible grip and its release point.
CARRY_HAND = [(67,405),(550,397),(1061,398),(1631,403),(2101,398)]
CARRY_FEET_X = [222,664,1054,1500,1949]
ATTACK_HAND = [(131,29),(789,165),(1111,306),(153,422),(803,551),(1144,698),
               (125,830),(821,927),(1197,1104)]
ATTACK_FEET_X = [203,590,1006,201,591,1005,200,584,995]


def objects(name, rows, columns, threshold=100):
    im=Image.open(HERE/(name+".webp")).convert("RGBA")
    a=np.asarray(im.getchannel("A"))
    labels,_=nd.label(a>threshold)
    counts=np.bincount(labels.ravel())
    found=[]
    for i,(ys,xs) in enumerate(nd.find_objects(labels)):
        if counts[i+1]<10000:
            continue
        x,y=max(0,xs.start-2),max(0,ys.start-2)
        region=np.s_[y:ys.stop+2,x:xs.stop+2]
        mask=nd.binary_dilation(labels[region]==i+1,iterations=2)
        pic=im.crop((x,y,x+mask.shape[1],y+mask.shape[0]))
        opacity=np.clip((a[region].astype(float)-threshold*.7)*255/(252-threshold*.7),0,255)
        pic.putalpha(Image.fromarray((opacity*mask).astype(np.uint8)))
        found.append((x,y,pic))
    assert len(found)==rows*columns,(name,len(found))
    found.sort(key=lambda o:o[1])
    return [o for j in range(rows) for o in sorted(found[j*columns:(j+1)*columns],key=lambda o:o[0])]


def scale(pic,factor):
    return pic.resize(tuple(max(1,round(i*factor)) for i in pic.size),LANCZOS)


def register(obj,feet_x,hand,factor):
    x,y,pic=obj
    body=Image.new("RGBA",CELL)
    dx=BOOT[0]-round((feet_x-x)*factor)
    scaled=scale(pic,factor)
    dy=BOOT[1]-scaled.height
    body.alpha_composite(scaled,(dx,dy))
    return body,(dx+round((hand[0]-x)*factor),dy+round((hand[1]-y)*factor))


def stride(body,hand,heading,frame):
    # Shift only the legs below the wrist. The weapon is not in this image.
    a=np.asarray(body.convert("RGBa"))
    yy,xx=np.mgrid[:a.shape[0],:a.shape[1]]
    t=math.tau*frame/8
    weight=np.clip((yy-(hand[1]+6))/max(12,BOOT[1]-hand[1]-6),0,1)
    side=np.tanh((xx-128)/6)
    walk=weight*side*math.sin(t)
    dx=walk*(7+3*abs(math.cos(heading)))
    dy=walk*math.sin(heading)*6-weight*np.maximum(0,side*math.cos(t))*4
    result=np.stack([nd.map_coordinates(a[:,:,i],[yy-dy,xx-dx],order=1,prefilter=False) for i in range(4)],axis=2)
    return Image.fromarray(result,"RGBa").convert("RGBA")


def build():
    OUT.mkdir(exist_ok=True)
    poses=objects("carry",1,5,172)
    strikes=objects("strike",3,3,168)
    parts=objects("parts",3,3)
    wounded=objects("sever",2,4)
    loose=Image.new("RGBA",(3*96,3*96))
    for i,(_,_,pic) in enumerate(parts):
        # Each part keeps its own scale across the rolling/ground views.
        factor=[.146,.117,.135][i//3]
        img=scale(pic,factor)
        loose.alpha_composite(img,(i%3*96+(96-img.width)//2,i//3*96+(96-img.height)//2))
    loose.save(OUT/"loose_parts.webp",quality=94,method=5)
    blade=scale(parts[0][2],.146)
    # The old weapon never enters the motion warp. The same cleaver painting
    # supplies the held blade and the first loose weapon view.
    weapon=Image.new("RGBA",CELL)
    weapon.alpha_composite(blade,(128-10,96-7))
    fall=Image.new("RGBA",(704,300))
    for i,(_,_,pic) in enumerate(wounded):
        img=scale(pic,.295)
        fall.alpha_composite(img,(176*(i%4)+(176-img.width)//2,150*(i//4)+140-img.height))
    fall.save(OUT/"wounded_fall.webp",quality=93,method=5)
    pages=[Image.new("RGBA",(2048,n*194)) for n in (8,8,2)]
    sockets=[]
    for row in range(18):
        records=[]
        for h,v in enumerate(VIEWS):
            theta=h*math.tau/8
            if row<=8 or row==16:
                body,grip=register(poses[v],CARRY_FEET_X[v],CARRY_HAND[v],.255)
                if 1<=row<=8:
                    body=stride(body,grip,theta,row-1)
                angle=[63,48,30,16,-12][v]
                if row==16:
                    angle-=15
            else:
                view=0 if v<2 else 1 if v==2 else 2
                # The contact key is selected at the strike timeout. Hold
                # preparation and recovery long enough to read at game scale.
                k=0 if row in (9,10,11,12) else 1 if row==13 else 2
                i=view*3+k
                f=[.34,.34,.31][view]
                body,grip=register(strikes[i],ATTACK_FEET_X[i],ATTACK_HAND[i],f)
                angle={9:-165,10:-146,11:-146,12:-155,13:4,14:42,15:62,17:62}[row]
                if v==4 and row==13:angle=-40
                if v==0 and row==13:angle=48
            layer=weapon.rotate(-angle,Image.Resampling.BICUBIC,center=(128,96))
            assembled=body.copy()
            assembled.alpha_composite(layer,(grip[0]-128,grip[1]-96))
            # Put the knuckles back over the grip without obscuring the blade.
            occlusion=Image.new("L",CELL)
            gx,gy=grip
            ImageDraw.Draw(occlusion).ellipse((gx-5,gy-5,gx+5,gy+5),fill=255)
            face=Image.new("RGBA",CELL)
            face.paste(body,(0,0),occlusion)
            assembled.alpha_composite(face)
            if h in MIRROR:
                assembled=ImageOps.mirror(assembled)
                gx=255-gx
                angle=180-angle
            records.append([gx-128,gy-163,angle])
            pages[row//8].alpha_composite(assembled,(h*256,row%8*194))
        sockets.append(records)
    for i,page in enumerate(pages):
        page.save(ART/f"actors/raider_{i}.webp",quality=91,method=5)
    (OUT/"grips.json").write_text(json.dumps(sockets,separators=(',',':'))+"\n")


if __name__=="__main__":
    build()
