"""Pack the painted knight into eight foot-registered gameplay headings.

Requires Python, Pillow, NumPy and SciPy. Run from any directory.
The contact stride uses independently posed far/near legs, with the mantle above.
All visible surfaces originate in the RGBA paintings.
"""
import json
import math
from functools import lru_cache
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[2] / 'game/art/actors'
SIZE = (256, 208)
PIVOT = (128, 181)
DENSITY = 1.5
HEIGHT = 151
# Facing directions are east, southeast, south, southwest, west, northwest, north, northeast.
VIEWS = ('side', 'front', 'south', 'front', 'side', 'back', 'north', 'back')
REFLECT = (False, False, False, True, True, True, False, False)
COLUMNS = {'front': 0, 'side': 1, 'back': 2}
SEQUENCE = [('idle',1),('walk',8),('fire',2),('melee',7),('guard',1),('parry',1),
            ('reload',1),('heal',1),('dodge',4),('stagger',1),('dead',1)]

# Hand-picked hip/ground pivots, unoccluded helmet crown and gun lip in master pixels.
# X origin follows the weight-bearing pelvis instead of the outer boot midpoint.
READY = {'front':(267,463,14, (473,155)), 'side':(246,459,15,(449,142)),
         'back':(261,455,15,(416,86)), 'south':(312,593,16,(317,255)),
         'north':(313,592,17,(320,100))}
STEPS = {'front':(259,459,17), 'side':(260,455,17), 'back':(256,454,18)}
SWORD = {'front':(269,463,28), 'side':(267,463,28), 'back':(263,463,24)}
CHAMBER = {'front':(263,462,53), 'side':(270,460,52), 'back':(269,459,52)}
STRIKE = {'front':(245,442,47), 'side':(228,441,45), 'back':(238,442,46)}
# Rear and front leg joints: hip, knee and ankle centers on the contact painting.
LEGS = {
    'front': [((222,233),(189,329),(138,403)), ((288,231),(342,315),(374,416))],
    'side': [((241,240),(194,330),(108,407)), ((265,235),(313,312),(350,417))],
    'back': [((220,255),(175,331),(101,420)), ((274,233),(325,313),(352,408))]
}

def alpha_clean(im):
    a=np.asarray(im.getchannel('A')).copy()
    a[a<8]=0
    a[a>248]=255
    im.putalpha(Image.fromarray(a))
    return im

@lru_cache(None)
def master(name):
    return alpha_clean(Image.open(HERE/(name+'.png')).convert('RGBA'))

def component(im):
    # Exclude disconnected flecks and any neighboring cape edge across a cut.
    arr=np.asarray(im.getchannel('A')).copy()
    labels,count=ndimage.label(arr>24)
    if not count:return im
    largest=1+np.argmax(np.bincount(labels.reshape(-1))[1:])
    mask=ndimage.binary_dilation(labels==largest,iterations=3)
    im.putalpha(Image.fromarray(np.where(mask,arr,0).astype('uint8')))
    return im

@lru_cache(None)
def crop(name, view, row):
    if name=='axial':
        col=0 if view=='south' else 1
        w=master(name).width//2
        h=master(name).height//2
    else:
        col=COLUMNS[view];w=h=512
    y0=row*h
    if name=='ready' and row:
        # Three upward sword tips occupy the gutter just above the lower row.
        y0-=21
    im=master(name).crop((col*w,y0,(col+1)*w,(row+1)*h))
    return component(im)

def put(im, origin, scale, offset=(0,0), xscale=1):
    scaled=(max(1,round(im.width*scale*xscale)), max(1,round(im.height*scale)))
    tile=Image.new('RGBA',SIZE)
    xy=(round(PIVOT[0] - origin[0]*scale*xscale+offset[0]),round(PIVOT[1]-origin[1]*scale+offset[1]))
    tile.alpha_composite(im.resize(scaled,Image.Resampling.LANCZOS), xy)
    return tile

def local_warp(im, dx, dy):
    # Inverse lookup on premultiplied RGBA strips avoids colored halos at cloth edges.
    sy,sx=np.mgrid[:im.height,:im.width].astype('float32')
    src=np.asarray(im.convert('RGBa'))
    coords=[sy-dy,sx-dx]
    out=np.stack([ndimage.map_coordinates(src[:,:,i],coords,order=1,mode='constant',prefilter=False) for i in range(4)],axis=2)
    return Image.fromarray(out,'RGBa').convert('RGBA')

def torso(im, horizontal, lift=0.):
    y,x=np.mgrid[:im.height,:im.width]
    w=np.clip((PIVOT[1]-y)/100,0,1)**.85
    return local_warp(im,w*horizontal,w*lift)

def motion_sway(im, wave, front, dorsal=False):
    y,x=np.mgrid[:im.height,:im.width]
    u=(x-PIVOT[0])/50; lower=np.clip((y-102)/76,0,1)
    cloak=np.clip((y-64)/96,0,1)*np.clip((abs(u)-.10)*1.65,0,1)
    if front:
        # Knees alternately shorten/extend under the pelvis, keeping head upright.
        lead=np.tanh(u*3)
        leg_y=lead*wave*6.7*lower
        leg_x=-lead*wave*1.7*lower
    else:
        leg_x=leg_y=0.
    bob=np.clip((PIVOT[1]-y)/75,0,1)*(abs(wave)-.5)*1.6
    return local_warp(im,leg_x+wave*(2.9 if dorsal else 1.8)*cloak,leg_y+bob)

def rotate_part(pic, angle, center):
    return pic.rotate(-angle,Image.Resampling.BICUBIC,center=center)

# Lower silhouette rotoscopes at a y=190 crop. Transparent pixels outside each
# outline stay transparent. The cloak, its narrow underside and the tabard lie
# in front of the far leg, even when the two boots exchange positions.
CLOTH = {
 'front': [
   [(0,-3),(197,-3),(192,31),(183,81),(178,103),(164,127),(155,151),(143,172),(117,182),(104,182),(95,205),(91,224),(82,225),(58,213),(49,191),(0,192)],
   [(254,30),(268,29),(299,28),(284,109),(290,131),(289,157),(273,156),(259,185),(241,211),(229,174),(231,163)]],
 'side': [[(0,-2),(215,-2),(214,38),(209,73),(204,103),(187,131),(174,141),(154,154),(135,176),(117,195),(97,180),(84,192),(75,200),(59,196),(39,178),(0,177)],
          [(215,96),(241,83),(234,130),(226,156),(205,158)]],
 'back': [[(0,-2),(260,-2),(256,46),(251,90),(239,127),(234,164),(211,169),(202,172),(183,208),(170,240),(150,224),(125,198),(108,188),(101,185),(87,195),(80,190),(71,174),(58,174),(45,159),(35,151),(0,151)]]
}

@lru_cache(None)
def leg_layers(view):
    art=crop('stride',view,0)
    alpha=np.array(art.getchannel('A'),dtype=float)
    cloth=Image.new('L',art.size)
    brush=ImageDraw.Draw(cloth)
    for contour in CLOTH[view]:
        brush.polygon([(x,y+190) for x,y in contour],fill=255)
    yy,xx=np.mgrid[:art.height,:art.width]
    upper=np.clip((yy-213)/21,0.,1.)
    leg_alpha=alpha*upper*(1-np.array(cloth.filter(ImageFilter.GaussianBlur(.65)))/255)
    # The boot silhouettes are separated by empty space below the knee.
    # That deliberate division also assigns the dark rim pixels to their limb.
    divider={'front':274,'side':247,'back':262}[view]
    parts=[leg_alpha*(xx<divider),leg_alpha*(xx>=divider),alpha-leg_alpha]
    layers=[]
    for opacity in parts:
        layer=art.copy()
        layer.putalpha(Image.fromarray(np.uint8(opacity)))
        layers.append(layer)
    return tuple(layers)

@lru_cache(None)
def walking(view, frame):
    wave=math.cos(frame*math.tau/8)
    if view in ('south','north'):
        return motion_sway(ready(view),wave,True,view=='north')
    far,near,top=leg_layers(view)
    result=Image.new('RGBA',top.size)
    t=(1-wave)*.5
    for which,layer in enumerate([far,near]):
        hip,knee,ankle=LEGS[view][which]
        # Both painted legs traverse the hip. A lifted ankle and bending knee
        # distinguish the returning stride from the planted stride.
        swing=(-47 if which==0 else 48)*t
        lift=max(0.,math.sin((frame/8 + which*.5)*math.tau))
        y,x=np.mgrid[:layer.height,:layer.width]
        shin=np.clip((y-knee[1])/max(1,ankle[1]-knee[1]),0,1)
        step=local_warp(layer,-lift*9*shin, -lift*22*shin)
        # The long greave follows the hip, but the boot stays level as the
        # center of pressure rolls from heel to toe. Overlap at its cuff.
        cuff=ankle[1]-lift*22
        opacity=np.asarray(step.getchannel('A'),dtype=float)
        upper=step.copy(); boot=step.copy()
        upper.putalpha(Image.fromarray(np.uint8(opacity*np.clip((cuff+8-y)/8,0,1))))
        boot.putalpha(Image.fromarray(np.uint8(opacity*np.clip((y-cuff+6)/7,0,1))))
        result.alpha_composite(rotate_part(upper,swing,hip))
        angle=math.radians(swing);cs=math.cos(angle);sn=math.sin(angle)
        dx,dy=ankle[0]-hip[0]-lift*9,cuff-hip[1]
        socket=(hip[0]+cs*dx-sn*dy, hip[1]+sn*dx+cs*dy)
        turned=rotate_part(boot,swing,hip)
        result.alpha_composite(rotate_part(turned,-swing*.88,socket))
    y,x=np.mgrid[:top.height,:top.width]
    tail=np.clip((y-173)/180,0,1)*np.clip((250-x)/122,0,1)
    result.alpha_composite(local_warp(top,math.sin(frame*math.tau/8)*9*tail,-abs(wave)*4*tail))
    ox,oy,head=STEPS[view]
    return put(result,(ox,oy),HEIGHT/(oy-head),offset=(0,1.3-abs(wave)*1.3))

@lru_cache(None)
def ready(view):
    x,y,head,_=READY[view]
    art=crop('axial',view,0) if view in ('south','north') else crop('ready',view,0)
    return put(art,(x,y),HEIGHT/(y-head))

def blade(view, stage):
    if stage=='guard':
        if view in ('south','north'):
            x,y,h,_=READY[view]
            return put(crop('axial',view,1),(x,598),HEIGHT/(y-h))
        x,y,h=SWORD[view]
        # Lower ready row includes a 21px gutter above the normal tile.
        return put(crop('ready',view,1),(x,y+21),HEIGHT/(y-h))
    lateral={'south':'front','north':'back'}.get(view,view)
    coords, row=(CHAMBER,0) if stage=='chamber' else (STRIKE,1)
    x,y,h=coords[lateral]
    # Lunge brings the helmet down a little. Keep the brushwork at the same scale
    # as the ready state rather than resizing a crouching figure taller.
    return put(crop('sword',lateral,row),(x,y),(.338 if row else .353))

def low(view, prone):
    lateral={'south':'front','north':'back'}.get(view,view)
    art=crop('low',lateral,int(prone))
    if prone:
        return put(art,(263,366),.315,offset=(0,0))
    offsets={'front':(262,460),'side':(270,454),'back':(262,458)}
    return put(art,offsets[lateral],.315)

def frame_for(view, action, index):
    if action=='walk':return walking(view,index)
    if action=='guard':return blade(view,'guard')
    if action=='parry':return torso(blade(view,'guard'),3.2,-2)
    if action=='melee':
        stage=['guard','chamber','chamber','strike','strike','strike','guard'][index]
        motion=[(0,0),(-2,0),(-4,-.5),(4.3,2),(6,1.5),(2,2),(0,1)][index]
        return torso(blade(view,stage),*motion)
    if action=='dead':return low(view,True)
    if action=='dodge':
        return torso(low(view,False),[0,4,6,2][index],[0,2,2,1][index])
    base=ready(view)
    if action=='stagger':return torso(base,-6.2,1.6)
    if action=='fire':return torso(base,-3.6 if index==0 else -1.3,-1)
    if action in ('reload','heal'):
        # Drop the weapon and shoulders while leaving the boots on their marks.
        y,x=np.mgrid[:base.height,:base.width]
        arms=np.exp(-((y-93)/26)**2)*np.clip((x-80)/54,0,1)
        return local_warp(base,-arms*(4.3 if action=='heal' else 1.8),arms*7)
    return base

def main():
    rows=[(action,n) for action,count in SEQUENCE for n in range(count)]
    muzzles=[]
    for col,view in enumerate(VIEWS):
        x,y,h,pt=READY[view]
        k=HEIGHT/(y-h)/DENSITY
        muzzles.append([round((pt[0]-x)*k*(-1 if REFLECT[col] else 1),2), round((pt[1]-y)*k,2)])
    for page,start in enumerate(range(0,len(rows),8)):
        batch=rows[start:start+8]
        sheet=Image.new('RGBA',(8*SIZE[0],len(batch)*SIZE[1]))
        for row,(action,n) in enumerate(batch):
            for col,view in enumerate(VIEWS):
                cell=frame_for(view,action,n)
                if REFLECT[col]:
                    cell=cell.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
                box=cell.getchannel('A').point(lambda a:255 if a>25 else 0).getbbox()
                if box is None or min(box[0],box[1],SIZE[0]-box[2],SIZE[1]-box[3])<1:
                    raise ValueError(f'Clipped painted pose {action}/{n}/{view}: {box}')
                sheet.paste(cell,(SIZE[0]*col,SIZE[1]*row))
        path=OUT/f'crusader_{page}.webp'
        staged=path.with_suffix('.tmp')
        sheet.save(staged,format='WEBP',quality=94,method=6)
        staged.replace(path)
        print(f'crusader_{page}: {sheet.size}', flush=True)
    metadata=OUT/'poses.json'
    all_poses=json.loads(metadata.read_text())
    start=0; poses={}
    for pose,count in SEQUENCE:
        poses[pose]=[start,count];start+=count
    all_poses['crusader'].update(poses=poses,cell=list(SIZE),pivot=list(PIVOT),muzzle=muzzles)
    metadata.write_text(json.dumps(all_poses,indent=2)+'\n')

if __name__=='__main__':main()
