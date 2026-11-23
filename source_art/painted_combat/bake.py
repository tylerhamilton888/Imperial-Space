"""Register painted keys to common foot, coping and threshold anchors."""
from pathlib import Path
import numpy as np
from scipy import ndimage as nd
from PIL import Image, ImageDraw, ImageOps, ImageFilter

SOURCE = Path(__file__).resolve().parent
TARGET = SOURCE.parents[1] / "game/art/painted"
TARGET.mkdir(exist_ok=True)
RESAMPLE = Image.Resampling.LANCZOS


def cutouts(name):
    image = Image.open(SOURCE / f"{name}.webp").convert("RGBA")
    alpha = np.array(image.getchannel("A"))
    labels, _ = nd.label(alpha > 48)
    sizes = np.bincount(labels.ravel())
    found = []
    for i, bounds in enumerate(nd.find_objects(labels)):
        if sizes[i+1] < 13000:
            continue
        ys, xs = bounds
        l, t = max(0,xs.start-3), max(0,ys.start-3)
        r, b = min(image.width,xs.stop+3), min(image.height,ys.stop+3)
        part = image.crop((l,t,r,b))
        own = nd.binary_dilation(labels[t:b,l:r] == i+1,iterations=2)
        part.putalpha(Image.fromarray(np.where(own,alpha[t:b,l:r],0).astype('uint8')))
        found.append((l,t,part))
    found.sort(key=lambda frame:frame[1])
    count=len(found)//2
    return (sorted(found[:count],key=lambda frame:frame[0]) +
            sorted(found[count:],key=lambda frame:frame[0]))


def scaled(image, factor):
    return image.resize(tuple(round(v*factor) for v in image.size),RESAMPLE)


def save(image, name):
    image.save(TARGET / (name+".webp"), quality=90,method=6)


# Sword contact shares the original 256 x 208 actor cell and boot registration.
# Six headings select the front/back plates; the straight N/S strokes retain
# their existing artwork. Mirrored frames use the same registered boot midpoint.
swing = Image.new("RGBA",(2048,4*208))
keys = cutouts("hero")
centers = [198,622,1041,1484,203,614,1048,1484]
for h in [0,1,3,4,5,7]:
    for key in range(4):
        i = (4 if h in (5,7) else 0)+key
        l,t,part = keys[i]
        cell = Image.new("RGBA",(256,208))
        # Pose scale follows the helmet, not the sword extending overhead.
        factor = .419 if i<4 else .401
        # At extension the attacker has stepped into his reach. Keep the front
        # boot planted through recovery (the torso and cloak swing through it).
        anchor = centers[i] + (11 if key>=2 else 0)
        pic = scaled(part,factor)
        cell.alpha_composite(pic,(128-round((anchor-l)*factor),181-pic.height+3))
        if h in (3,4,5):
            cell=ImageOps.mirror(cell)
        swing.alpha_composite(cell,(256*h,208*key))
save(swing,"medium_sword")

# Front and back views have different body overlap. For the blade kill only,
# clip the far gauntlet where it is visible beyond the upper arm. In the last
# two keys the shoulder hides that limb as the near fist takes the ground.
falls=Image.new("RGBA",(4*176,4*150))
for i,(left,top,part) in enumerate(cutouts("fallen")):
    for sever in range(2):
        body=part.copy()
        if sever and i in (0,1):
            contour=([(278,222),(307,202),(346,222),(344,318),(255,318),(255,277)]
                     if i==0 else [(625,314),(649,301),(679,322),(678,399),(595,400),(596,357)])
            mask=body.getchannel("A")
            ImageDraw.Draw(mask).polygon([(x-left,y-top) for x,y in contour], fill=0)
            body.putalpha(mask)
        pic=scaled(body,.315)
        # Keep the center of gravity over a planted or braced support point.
        x=88-pic.width//2
        y=140-pic.height
        falls.alpha_composite(pic,(i%4*176+x,(i//4+2*sever)*150+y))
save(falls,"raider_fall")

# Keep the rubble registration in place when tall objects lose their crowns.
for i,(l,t,part) in enumerate(cutouts("cover")):
    cell=Image.new("RGBA",(264,120))
    pic=scaled(part,.3)
    cell.alpha_composite(pic,(12+round((l-(887 if i%2 else 0)-37)*.3),
                              100+round((t-(444 if i>=2 else 0)-381)*.3)))
    save(cell,"barricade_"+str(i))

for i,(l,t,part) in enumerate(cutouts("gate")):
    # Use the lamp housings and inner rails to register the opening, even after
    # the rubble extends the external bounds in the last frame.
    ox=613 if i%2 else 0
    oy=558 if i>=2 else 0
    source=Image.new("RGBA",(650,620))
    source.alpha_composite(part,(l-ox,t-oy))
    # Replace the small winged maker's crest with a plain brass keystone.
    crest=ImageDraw.Draw(source)
    crest.polygon([(256,184),(325,194),(320,218),(262,207)],fill="#473426")
    crest.line([(256,184),(325,194)],fill="#b08a55",width=3)
    crest.ellipse((282,193,297,206),outline="#c69851",width=3)
    crest.line([(290,188),(290,213)],fill="#bf8c48",width=2)
    cell=Image.new("RGBA",(212,177))
    # The two jambs and their collision footprints persist during the breach.
    for x0,x1,u0,u1 in [(0,207,0,63),(207,421,63,143),(421,650,143,212)]:
        strip=source.crop((x0,0,x1,620)).resize((u1-u0,177),RESAMPLE)
        cell.alpha_composite(strip,(u0,0))
    save(cell,"shutter_"+str(i))

# Keep the sword visible while the player repositions after a cut. Advance the
# near and far boots in opposite phases, with less movement above the belt.
from sys import path as module_path
module_path.insert(0,str(SOURCE.parent/"actors/crusader"))
from pack import local_warp
carry=Image.new("RGBA",(2048,1664))
old=Image.open(TARGET.parents[1]/"art/actors/crusader_1.webp").convert("RGBA")
yy,xx=np.mgrid[:208,:256]
leg=np.clip((yy-110)/64,0,1)
side=np.tanh((xx-128)/8)
for h in range(8):
    if h in (2,6):
        base=old.crop((h*256,3*208,(h+1)*256,4*208))
    else:
        base=swing.crop((h*256,0,(h+1)*256,208))
    theta=h*np.pi/4
    for frame in range(8):
        phase=frame*np.pi/4
        travel=side*np.sin(phase)*leg
        lift=np.maximum(0,-side*np.cos(phase))*leg
        dx=travel*11*np.cos(theta)
        dy=travel*8*np.sin(theta)-5*lift
        dy+=1.65*np.cos(phase*2)*(1-leg)
        cell=local_warp(base,dx,dy)
        carry.alpha_composite(cell,(h*256,frame*208))
save(carry,"medium_sword_carry")
