"""Build the three painted range combatants. Run beside the original source PNGs.

Each illustrated turnaround has a measured ground anchor. Gait frames bend lower
limbs about the hips and knees. The raider's raised and extended cuts and
gunner's aiming stance come from separate painted poses.
"""
from pathlib import Path
import json
import math
import numpy as np
from scipy import ndimage as nd
from PIL import Image, ImageEnhance, ImageOps

SOURCE = Path(__file__).resolve().parent
TARGET = SOURCE.parents[2] / "game" / "art" / "actors"
SCALE = {"raider": .50, "gunner": .315, "soldier": .132}
CELL = {"raider": (256,194), "gunner": (204,174), "soldier": (204,174)}
PIVOT = {"raider": (128,163), "gunner": (102,143), "soldier": (102,143)}
# The anchor lies between the planted feet; the blade is deliberately excluded.
# Normalized to the extracted silhouette's bounds, including the weapon.
PINS = {
 "raider": [[(.51,.93),(.48,.92),(.43,.94),(.43,.95),(.43,.94)],
            [(.47,.95),(.49,.96),(.52,.96),(.37,.96),(.55,.95)],
            [(.48,.91),(.28,.93),(.21,.96),(.15,.96),(.17,.96)]],
 "gunner": [[(.51,.97),(.39,.97),(.36,.96),(.25,.96),(.49,.97)],
            [(.50,.97),(.39,.97),(.31,.97),(.33,.97),(.50,.97)]],
 "soldier": [[(.38,.98),(.40,.98),(.50,.98)]],
}
# Five campaign headings photographed in each turnaround. Opposite-facing
# diagonals use the same paint, mirrored about the actor's ground anchor.
VIEWS = [(2,False),(1,False),(0,False),(1,True),(2,True),(3,True),(4,False),(3,False)]
PAINT_MUZZLES = [(129,309),(411,292),(660,284),(868,265),(1001,246)]

def extract(role):
    src = np.array(Image.open(SOURCE / f"{role}_source.png").convert("RGBA"))
    if role == "raider":
        # This generated plate has an almost white matte, including its alpha
        # channel. Derive alpha from color, retaining bright blade details.
        tone = src[:,:,:3].min(axis=2).astype(float)
        mask = tone < 222
    else:
        mask = src[:,:,3] > 75
    labels, _ = nd.label(mask)
    sizes = np.bincount(labels.ravel())
    bounds = [r for i,r in enumerate(nd.find_objects(labels)) if sizes[i+1] > 2000]
    columns = 3 if role == "soldier" else 5
    bands = [sorted(bounds[i:i+columns], key=lambda r:r[1].start)
             for i in range(0,len(bounds),columns)]
    out, muzzles = [], []
    for row, rects in enumerate(bands):
        frames = []
        for col, (ys,xs) in enumerate(rects):
            x0,x1,y0,y1=xs.start,xs.stop,ys.start,ys.stop
            area=src[ys,xs].copy()
            if role == "raider":
                ink=area[:,:,:3].min(axis=2).astype(float)
                alpha=np.clip((235.0-ink)/20.0,0.0,1.0)
                # Plane white must never become visible on dark floor edges.
                fraction=alpha[:,:,None]
                area[:,:,:3]=np.clip((area[:,:,:3]-245.0*(1.0-fraction))/np.maximum(.01,fraction),0,255)
                area[:,:,3]=np.uint8(255*alpha)
            else:
                area[:,:,3]=np.uint8(np.clip((area[:,:,3].astype(float)-14)*255/232,0,255))
            local=Image.fromarray(area)
            local=ImageEnhance.Color(local).enhance(1.24 if role!="soldier" else 1.12)
            local=ImageEnhance.Brightness(local).enhance(1.09)
            a=local.getchannel("A")
            local=ImageEnhance.Contrast(local.convert("RGB")).enhance(1.04).convert("RGBA")
            local.putalpha(a)
            scale=SCALE[role]
            # The slash extends towards the camera in the followthrough. A little
            # horizontal foreshortening preserves the tip within a 2K-wide page.
            horizontal=.88 if role=="raider" and row==2 and col>=2 else 1.0
            resized=local.resize((round(local.width*scale*horizontal),round(local.height*scale)),Image.Resampling.LANCZOS)
            px,py=PIVOT[role]
            ax,ay=PINS[role][row][col]
            offset=(round(px-resized.width*ax),round(py-resized.height*ay))
            canvas=Image.new("RGBA",CELL[role])
            canvas.alpha_composite(resized,offset)
            if role=="gunner" and row==1:
                mx,my=PAINT_MUZZLES[col]
                mx=mx*1983/1100
                my=my*1983/1100
                muzzles.append([round(((mx-x0)*scale+offset[0]-px)/1.5,1),
                                round(((my-y0)*scale+offset[1]-py)/1.5,1)])
            frames.append(canvas)
        out.append(frames)
    return out,muzzles

def puppet(img, heading, pivot, stride=0.0, lift=0.0, body_shift=0.0, lean=0.0):
    # Inverse displacement field in premultiplied color. Leg motion increases
    # progressively below the hips; both boots receive opposing travel.
    src=np.asarray(img.convert("RGBa"))
    height,width=src.shape[:2]
    x,y=np.meshgrid(np.arange(width),np.arange(height))
    px,py=pivot
    foot=np.clip((y-(py-62.0))/61,0,1)
    weight=foot*foot*(3.0-2.0*foot)
    side=np.tanh((x-px)/7)
    branch=side*stride
    dx=branch*weight*(8.5*abs(math.cos(heading))+2.2)
    dy=branch*weight*math.sin(heading)*7.0
    dy-=np.maximum(0,-side*stride)*weight*3.7
    torso=(1-weight)
    dx+=body_shift*torso+lean*np.clip((py-y)/108,0,1)
    dy+=lift*torso
    coords=np.array([y-dy,x-dx])
    channels=[nd.map_coordinates(src[:,:,i],coords,order=1,mode="constant",cval=0,prefilter=False) for i in range(4)]
    return Image.fromarray(np.stack(channels,axis=2),mode="RGBa").convert("RGBA")

def draw(role,base,column,action,frame,count):
    view,flipped=VIEWS[column]
    if role=="soldier": view=(0,0,1,2,2)[view]
    idx=0
    if role=="raider":
        if action=="windup": idx=1
        if action=="melee": idx=1 if frame==0 else 2
    if role=="gunner" and action in ("windup","fire"): idx=1
    img=base[idx][view]
    if flipped: img=ImageOps.mirror(img)
    pivot=PIVOT[role]
    heading=column*math.tau/8
    if action=="walk":
        theta=frame*math.tau/count
        return puppet(img,heading,pivot,stride=math.sin(theta),lift=-2.3*abs(math.sin(theta)),body_shift=1.6*math.cos(theta))
    if action=="windup" and role=="raider":
        return puppet(img,heading,pivot,lift=-frame*1.4,lean=-math.cos(heading)*(1+frame)*2.0)
    if action=="melee":
        t=frame/max(1,count-1)
        return puppet(img,heading,pivot,lift=2.2*math.sin(t*math.pi),lean=5.0*math.cos(heading)*math.sin(t*math.pi))
    if action=="fire" or action=="stagger":
        return puppet(img,heading,pivot,lift=1.0,lean=-6.0*math.cos(heading))
    if action=="dead":
        tipped=img.rotate(73 if not flipped else -73,resample=Image.Resampling.BICUBIC,expand=True)
        tipped=tipped.crop(tipped.getbbox())
        tipped=tipped.resize((tipped.width,round(tipped.height*.69)),Image.Resampling.LANCZOS)
        p=Image.new("RGBA",img.size)
        p.alpha_composite(tipped,(pivot[0]-tipped.width//2,pivot[1]-tipped.height+4))
        return p
    return img

def build_target():
    # The fixed device faces the firing lane in every scenario. Reuse one
    # painted view for each direction in the shared actor atlas format.
    raw=Image.open(SOURCE/"dummy_source.png").convert("RGBA")
    alpha=raw.getchannel("A").point(lambda a: round(max(0,min(1,(a-18)/224))*255))
    raw.putalpha(alpha)
    shape=raw.crop(alpha.getbbox())
    pixels=103
    shape=shape.resize((round(shape.width*pixels/shape.height),pixels),Image.Resampling.LANCZOS)
    cell=Image.new("RGBA",(204,174))
    cell.alpha_composite(shape,(102-shape.width//2,143-pixels+3))
    atlas=Image.new("RGBA",(204*8,174))
    for index in range(8):
        atlas.alpha_composite(cell,(204*index,0))
    atlas.save(TARGET/"dummy_0.webp",quality=92,method=5)


def main():
    build_target()
    desc_path=TARGET/"poses.json"
    desc=json.loads(desc_path.read_text())
    for role in ("gunner","soldier"):
        base, muzzles=extract(role)
        cw,ch=CELL[role]
        pages={}
        for action,(row,count) in desc[role]["poses"].items():
            for time in range(count):
                page=(row+time)//8
                if page not in pages:
                    rows=min(8,max(start+n for start,n in desc[role]["poses"].values())-page*8)
                    pages[page]=Image.new("RGBA",(cw*8,ch*rows))
                for direction in range(8):
                    sprite=draw(role,base,direction,action,time,count)
                    pages[page].alpha_composite(sprite,(direction*cw,(row+time)%8*ch))
        for page, atlas in pages.items():
            atlas.save(TARGET/f"{role}_{page}.webp",quality=91,method=5)
        if role=="gunner":
            desc[role]["muzzle"]=[[-muzzles[v][0] if f else muzzles[v][0],muzzles[v][1]] for v,f in VIEWS]
    desc_path.write_text(json.dumps(desc,indent=2)+"\n")

if __name__=="__main__":
    main()
