"""Bake Imperial Space's original directional actor plates. Python 3, numpy, Pillow, cc."""
import ctypes
import json
import math
import subprocess
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

HERE = Path(__file__).resolve().parent
OUTPUT = HERE.parents[1] / 'game/art/actors'
W, H = 204, 174
PIVOT = (102, 143)
DENSITY = 1.5
SS = 2
SKY = np.array((0.04, -0.12, 0.99))
KEY = np.array((-0.58, 0.24, 0.78))
KEY /= np.linalg.norm(KEY)
VIEW = np.array((0.0, 0.866, 0.50))
HALF = KEY + VIEW
HALF /= np.linalg.norm(HALF)
# Character local coordinates: x across, y forward, z above the sole.
OCT = [(-.70,1),(.70,1),(1,.58),(1,-.54),(.67,-1),(-.67,-1),(-1,-.54),(-1,.58)]
ROUND = [(math.sin(i*math.pi/5), math.cos(i*math.pi/5)) for i in range(10)]

# Material, linear-looking authored enamel/metal ramp, highlight strength.
MATS = {
    'steel': ('#9aa8af', .62), 'light': ('#c7ced0', .68),
    'silver': ('#e8e1ce', .7), 'black': ('#24313d', .28),
    'blue': ('#41596e', .42), 'dark': ('#18232f', .18),
    'gold': ('#be8c4d', .72), 'brightgold': ('#e3b16b', .7),
    'cape': ('#a42e40', .07), 'velvet': ('#642138', .08), 'red': ('#c0514e', .11),
    'leather': ('#5c4440', .08), 'visor': ('#17212a', .66), 'ice': ('#a5edeb', .0),
    'hide': ('#985f50', .07), 'skinlit': ('#b97f65', .15), 'umber': ('#755144', .10),
    'rust': ('#b25e37', .42), 'bone': ('#dac9a6', .22), 'amber': ('#ffb969', .04),
    'teal': ('#38606c', .29), 'range': ('#d6944f', .26),
}
RGB = {nm:np.array(list(bytes.fromhex(val[0][1:])),dtype=float) for nm,val in MATS.items()}

def v(x,y,z): return np.array((x,y,z),dtype=float)
def unit(a): return a / max(np.linalg.norm(a), 1e-6)

class Model:
    def __init__(self):
        self.faces=[]; self.colors=[]; self.info={}
    def face(self, points, m):
        a=np.asarray(points)
        for n in range(1,len(a)-1):
            self.faces.append(a[[0,n,n+1]])
            self.colors.append(m)
    def section(self, levels, mat, profile=OCT):
        """Tapered, chamfered castings defined by cross sections from bottom up."""
        rings=[np.array([v(x+px*rx,y+py*ry,z) for px,py in profile]) for x,y,z,rx,ry in levels]
        self.face(rings[0],mat)
        for j in range(len(rings)-1):
            for i in range(len(profile)):
                k=(i+1)%len(profile)
                self.face([rings[j][k],rings[j][i],rings[j+1][i],rings[j+1][k]],mat)
        self.face(rings[-1][::-1],mat)
    def plate(self, c, size, mat, bevel=.7):
        x,y,z=c; w,d,h=size
        b=min(bevel,w*.25,d*.27,h*.33)
        self.section([(x,y,z-h/2,w/2-b,d/2-b),(x,y,z-h/2+b,w/2,d/2),
                      (x,y,z+h/2-b,w/2,d/2),(x,y,z+h/2,w/2-b,d/2-b)],mat)
    def tube(self, a,b,r1,r2,mat,n=8, flatten=1):
        a,b=np.asarray(a),np.asarray(b)
        axis=unit(b-a); ref=v(0,0,1) if abs(axis[2])<.9 else v(0,1,0)
        u=unit(np.cross(axis,ref)); t=np.cross(axis,u)*flatten
        rim=[math.cos(i*2*math.pi/n)*u+math.sin(i*2*math.pi/n)*t for i in range(n)]
        lo=[a+o*r1 for o in rim]; hi=[b+o*r2 for o in rim]
        self.face(lo[::-1],mat); self.face(hi,mat)
        for i in range(n):
            j=(i+1)%n
            self.face((lo[i],lo[j],hi[j],hi[i]),mat)

def overlay(model, base, outline, mat, thickness=1):
    """Emboss a hand-drawn chest, face, or shoulder plate on a forward surface."""
    x,y,z=base
    face=[v(x+a,y+b,z+c) for a,b,c in outline]
    model.face(face,mat)
    if thickness>0:
        back=[p-v(0,thickness,0) for p in face]
        for i in range(len(face)):
            j=(i+1)%len(face);model.face([back[i],back[j],face[j],face[i]],mat)

def cloak(m, bob, gait, flank, rearlean):
    # Heavy mantle breaks into six folds below rear collar; gold trim follows each fold.
    top=[]; low=[]; middle=[]; hem=[]
    for i in range(9):
        t=(i-4)/4; fold=math.cos(i*math.pi)
        top.append(v(15*t, -4-3*(1-t*t), 73+bob-3*t*t))
        middle.append(v(18*t+flank*.6, -8-6*(1-t*t)+fold*1.2-rearlean, 46+bob))
        low.append(v(22*t+flank, -11-8*(1-t*t)+fold*2.2-rearlean*1.7+gait*1.5,
                     13+4*(t*t)+fold+gait*t*1.5+bob))
        hem.append(low[-1]+(middle[-1]-low[-1])*.060)
    for i in range(8):
        color='cape' if i%2==0 else 'velvet'
        for a,b,mat in [(top,middle,color),(middle,hem,color),(hem,low,'gold')]:
            m.face((a[i],a[i+1],b[i+1],b[i]),mat)
        # Double stripe just above hem.
        l=low[i];r=low[i+1]
        m.face([l+(middle[i]-l)*.11, r+(middle[i+1]-r)*.11,
                r+(middle[i+1]-r)*.128, l+(middle[i]-l)*.128], 'red')
    # Raised bronze clasp and shoulder cowl connect front to the fully drawn back.
    for s in (-1,1):
        m.tube(v(s*11,-4,73+bob),v(s*11,6.1,69+bob),2.6,2,'cape',6)
        m.plate(v(s*11,6.5,69+bob),(3.2,2.1,3.2),'brightgold')

def gun(m, grip, fore, gunner=False, ordinary=False):
    # Receiver and barrel share the hand sockets, including through recoil/reload.
    axis=unit(fore); right=unit(np.cross(axis,v(0,0,1))); up=unit(np.cross(right,axis))
    def p(x,y,z): return grip+x*right+y*axis+z*up
    def rec(x,y,z,w,l,h,mat):
        rings=[]
        for yy,shrink in [(y-l/2, .7),(y-l/2+.6, 1.),(y+l/2-.6,1.),(y+l/2,.8)]:
            rings.append([p(x+xx*w*.5*shrink,yy,z+zz*h*.5*shrink) for xx,zz in OCT])
        m.face(rings[0],mat)
        for i in range(3):
            for k in range(8):
                j=(k+1)%8;m.face([rings[i][k],rings[i][j],rings[i+1][j],rings[i+1][k]],mat)
        m.face(rings[-1],mat)
    barrel=30 if gunner else 23
    rec(0,-5,1,3.6,13,4.8,'black')
    rec(0,4,1.7,4.4,14,5.3,'steel' if not gunner else 'rust')
    rec(0,1,4.9,1.85,9,1.15,'gold' if not gunner else 'bone')
    rec(0,6,-2.4,3.1,4.2,5,'black')
    rec(0,13,1.9,3.7,8,4,'blue' if not gunner else 'dark')
    m.tube(p(0,16,2),p(0,barrel,2),1.35,1.25,'black',8)
    rec(0,barrel,2,3.4,4,3.6,'steel')
    for y in [10.5,13.5,16.5]:
        rec(0,y,2.1,3.8,.75,3.8,'light' if not gunner else 'gold')
    m.info['muzzle']=p(0,barrel+2,2)
    return p(0,10,-.7)

def blade(m, grip, direction, alien=False):
    axis=unit(direction)
    side=unit(np.cross(axis,v(.1,1,0)))
    if np.linalg.norm(side)<.1: side=v(1,0,0)
    normal=unit(np.cross(axis,side))
    def p(y,w=0,d=0): return grip+axis*y+side*w+normal*d
    hilt='umber' if alien else 'black';g='bone' if alien else 'gold'
    m.tube(p(-3),p(4.8),1.2,1.3,hilt)
    m.tube(p(-3),p(-4.5),1.7,1,g)
    m.tube(p(5,-4),p(5,4),.9,.9,g)
    base=6; length=27 if alien else 35
    tip=p(length,3.8 if alien else 0)
    lo=p(base,-1.9);mid=p(base,0,1.1);hi=p(base,1.9)
    waist=p(length*.74,2.8 if alien else 1.45)
    m.face([lo,mid,tip], 'steel');m.face([mid,hi,waist,tip], 'silver')
    m.face([lo,p(base,0,-.8),tip], 'light')

def boot_leg(m, side, foot, hip, alien=False, ordinary=False):
    s=side; x,y,z=foot
    shin='black' if alien else 'blue'; metal='rust' if alien else 'steel'
    knee=(hip+foot)*.5+v(0,2.5,1)
    calf=(knee+foot)*.5; thigh=(hip+knee)*.5
    m.tube(hip,knee+v(0,0,1),5.4,3.8,'hide' if alien else 'dark')
    m.tube(hip-v(0,0,4),thigh-v(0,0,3),5.7,4.8,shin,8)
    m.tube(knee,foot+v(0,0,4),3.9,3.0,'hide' if alien else 'black')
    m.section([(x,y+1.3,z+1,4.3,6.4),(x,y+1.1,z+2.4,4.6,7),
               (x,y+.4,z+5,4.2,6.1),(x,y-1,z+8,3.1,3.3)],shin)
    m.plate(v(x,y+3.6,z+3.7),(7.8,6,3.1),metal)
    m.tube(foot+v(0,1.5,7),knee-v(0,0,2),3.15,4.15,metal)
    m.tube(foot+v(0,3.4,8),knee+v(0,2,-1),1.45,2.05,'light' if not alien else 'umber',5)
    m.plate(knee+v(0,2.7,0),(8,5.7,7.2),shin,1.25)
    m.tube(knee+v(-2.9,5.25,1.2),knee+v(3,5.25,1.2),.53,.53,'gold')
    if not alien:
        m.tube(thigh+v(0,3,4),knee+v(0,2,3),3.05,2.55,'steel',6)
    else:
        m.tube(v(x+s*2,y+4,z+2),v(x+s*3,y+9,z+.5),1.6,0,'bone',5)

def arm(m, shoulder, elbow, wrist, alien, trim=True):
    m.tube(shoulder,elbow,5.0,3.7,'hide' if alien else 'dark',8)
    m.tube(shoulder+(elbow-shoulder)*.25,shoulder+(elbow-shoulder)*.69,
           4.95,4.0,'skinlit' if alien else 'blue',7)
    m.tube(elbow,wrist,3.9,2.45,'umber' if alien else 'black')
    m.tube(elbow+(wrist-elbow)*.12,elbow+(wrist-elbow)*.74,
           4.5,3.35,'rust' if alien else 'steel')
    if trim:m.tube(elbow+(wrist-elbow)*.69,elbow+(wrist-elbow)*.77,3.72,3.72,'gold')
    m.plate(wrist,(5.5,5.1,4.7),'umber' if alien else 'black',1)
def helmet(m, base):
    x,y,z=base
    m.section([(x,y,z-2,4.6,4.5),(x,y,z+.5,6.0,6.4),(x,y,z+7.7,6.8,6.7),
               (x,y-.6,z+12.1,5.7,5.7),(x,y-1.2,z+14.1,3.2,3.8)], 'steel')
    # Severe split cheek mask with an enclosed brow and engraved median ridge.
    for s in (-1,1):
        overlay(m,base+v(0,1.45,0),[(s*.65,6.5,7.5),(s*5.7,5.7,8.8),(s*5.0,6.2,5.1),(s*1,7.3,4.3)],'visor')
        overlay(m,base+v(0,1.45,0),[(s*1,7.38,6.9),(s*5.15,6.34,7.8),(s*4.75,6.35,6.95),(s*1.2,7.46,6.1)],'ice',.1)
        overlay(m,base+v(0,1.45,0),[(s*.6,7.3,5.4),(s*4.9,6.1,6),(s*5.1,5.85,2),
                        (s*2.1,6.4,-.8),(s*.6,7.5,1.3)],'silver')
        overlay(m,base+v(0,1.45,0),[(s*.55,7.25,8.5),(s*5.8,5.9,9.3),(s*5.7,6,8.7),
                        (s*.5,7.5,7.7)],'gold',.4)
        m.plate(base+v(s*6.05,-.8,5.5),(1.7,4,5.8),'dark')
    m.tube(base+v(0,6.9,2),base+v(0,6.8,11.4),.75,1.0,'brightgold',5)
    m.tube(base+v(0,5.9,11.7),base+v(0,-3.3,14.05),1.15,1,'gold',5)
    for xoff in [-3,0,3]:
        m.plate(base+v(xoff,-5.95,4.6),(1,1.2,4.6),'black')

def crusader(m, pose, t):
    gait=math.sin(t*math.tau) if pose=='walk' else 0
    walking=pose=='walk'
    bob=abs(gait)*1.6 if walking else 0
    dodge=math.sin(t*math.pi) if pose=='dodge' else 0
    melee=pose=='melee'
    guard=pose in ('guard','parry')
    stagger=pose=='stagger'
    # Bending at hips and knees preserves an armored gait without sliding planted feet.
    bob-=dodge*13 + (3 if guard else 0)
    lean=(3 if guard else 0)+dodge*8-(3 if stagger else 0)
    if melee: lean+=4*math.sin(t*math.pi)
    for s in (-1,1):
        track=gait*s
        foot=v(s*(7.65+dodge*2),track*10.7+s*2.7, 4.8*max(0,-s*math.cos(t*math.tau)) if walking else 0)
        hip=v(s*6.4,lean*.4,43+bob)
        boot_leg(m,s,foot,hip)
    o=lambda x,y,z:(x,y+lean,z+bob)
    cloak(m,bob,gait,dodge*8+(2*math.sin(t*math.pi) if melee else 0),dodge*2+abs(gait))
    m.section([(*o(0,0,36),10,5.5),(*o(0,-.3,43),10.4,6),(*o(0,0,47),8,5.4)],'dark')
    m.section([(*o(0,0,43),8.8,6),(*o(0,0,51),8.8,6.1),(*o(0,-.4,58),12.6,7.3),
               (*o(0,-.7,65),15.3,7.9),(*o(0,-.7,71),13.2,6.8),(*o(0,0,74),7,5)],'blue')
    for z in [46.5,49.3,52.2]:
        overlay(m,v(*o(0,0,z)),[(-7,4.7,1),(0,6.9,-.6),(7,4.7,1),(6.4,5.5,2.5),
                                (0,7.1,1.5),(-6.5,5.5,2.5)],'steel')
    for s in (-1,1):
        overlay(m,v(*o(0,2.0,0)),[(s*.2,5.6,70),(s*11,4.2,70.1),(s*13.6,3.5,65.3),
                                (s*9.3,6.3,60.5),(s*.2,8.55,58.1)],'steel')
        overlay(m,v(*o(0,2.0,0)),[(s*.6,8.6,59.2),(s*10.4,6.4,62),(s*11.7,5.9,63.2),
                                (s*9.8,6.6,61.4),(s*.6,8.8,58.0)],'gold',.25)
        m.plate(v(*o(s*8.7,2.7,39.5)),(4.8,6.8,8),'blue')
    for s in (-1,1):
        overlay(m,v(*o(0,2,0)),[(s*.7,8.7,59.5),(s*8.0,7.4,61.5),(s*11.75,6,64),
                                 (s*10.1,7.1,65),(s*.7,9.0,61.4)],'brightgold',.3)
        overlay(m,v(*o(0,1.7,0)),[(s*7.5,7.2,66.2),(s*9.5,6.2,68.4),(s*7.1,6.8,68.1)],'light',.15)
    m.plate(v(*o(0,10.3,63)),(2.1,1.6,7.5),'brightgold',.5)
    m.plate(v(*o(0,0,43.8)),(20,12,3.4),'leather')
    m.plate(v(*o(0,6.17,44.2)),(5,1.7,3.4),'gold',.45)
    # An asymmetric heraldic fall stays off both boots.
    overlay(m,v(*o(0,0,0)),[(-4.5,6.1,42.8),(3.3,6.45,42.8),(2.8,7.9,24),
                            (-1,8.1,19),(-4.1,7.6,23)],'cape')
    overlay(m,v(*o(0,0,0)),[(-3.8,7.2,41),(-3.0,7.3,41),(-2.4,8.25,24),
                            (-1,8.3,22),(-3.1,8.15,23)],'gold',.2)
    m.section([(*o(0,-.6,70),8.2,5.7),(*o(0,-1.4,75.4),8.7,6.7),
               (*o(0,-1.5,76.8),8.3,6.4)],'black')
    for s in (-1,1):
        # Sculpted shoulders, with horizontal overlapping bands rather than spheres.
        m.section([(*o(s*14.9,-.5,64.4),4.9,6.2),(*o(s*15,-.5,66.5),6.3,7.6),
                   (*o(s*14.8,-.6,71.1),6.3,7.1),(*o(s*13.5,-.6,73.4),4.4,4.5)],'steel')
        m.section([(*o(s*15.1,0,65.3),6,7.15),(*o(s*15.1,0,66.2),6.35,7.5)],'gold')
    base=v(*o(0,0,75.4))
    helmet(m,base)
    grip=v(*o(-9,11,55))
    fore=v(.04,1,.02)
    if pose=='fire':
        grip+=v(0,-2.9,1.3);fore+=v(0,0,.13)
    if pose=='reload' or pose=='heal':
        grip+=v(3,0,-3);fore=v(.65,.31,.63)
    if melee or guard:
        if guard:
            grip=v(*o(-6,13,54.8)); blade_dir=v(.48,.26,.87)
            lead=v(*o(8,12,60))
            if pose=='parry': blade_dir=v(.79,.4,.48)
        else:
            # A compact high chamber, leading hand crossing the body, outside recovery.
            keys=[(0,(-9,5,63),(-.56,-.22,.86)),(.22,(-14,4,65),(-.80,-.20,.49)),
                  (.39,(-14,14,64),(-.65,.65,.30)),(.56,(-1,23,59),(.46,.85,.08)),
                  (.74,(9,14,52),(.92,.24,-.22)),(1,(-8,9,55),(.32,.46,.76))]
            for i in range(1,len(keys)):
                if t<=keys[i][0]+.0001:
                    a,b=keys[i-1:i+1];f=(t-a[0])/(b[0]-a[0])
                    grip=np.array(a[1])*(1-f)+np.array(b[1])*f+v(0,lean,bob)
                    blade_dir=np.array(a[2])*(1-f)+np.array(b[2])*f
                    break
            lead=v(*o(7,9,60))
        blade(m,grip,blade_dir)
    else:
        lead=gun(m,grip,fore)
        if pose=='reload': lead=v(*o(2,10,48))
        if pose=='heal': lead=v(*o(1,4,60))
    arm(m,v(*o(-15,0,66)),v(*o(-17,2.5,54.8)),grip,False)
    arm(m,v(*o(15,0,66)),v(*o(15,6,55)),lead,False)

def alien(m,role,pose,t):
    gait=math.sin(t*math.tau) if pose=='walk' else 0
    b=abs(gait)*1.5-(3 if pose=='windup' else 0)
    shoulder=64 if role=='raider' else 60
    for s in (-1,1):
        pos=v(s*8.4,s*(1.8+gait*9),3*max(0,-s*math.cos(t*math.tau)) if pose=='walk' else 0)
        boot_leg(m,s,pos,v(s*7.3,-1,36+b),True)
    m.section([(0,0,31+b,11,7),(0,-2,37+b,10,6),(0,-3.3,45+b,9,7),(0,-2.5,53+b,13,8.7),
               (0,-2,shoulder-2+b,17,8.8),(0,0,shoulder+2+b,12.5,7)],'hide',ROUND)
    for s in [-1,1]:
        m.section([(s*10,1,46+b,2.4,4.2),(s*10.7,1,54+b,4.1,5.2),(s*10.9,0,62+b,4,4)],'skinlit',ROUND)
    m.plate(v(0,-6,46+b),(15,6,15),'dark')
    m.plate(v(0,0,36+b),(22,13,3.5),'leather')
    overlay(m,v(0,0,b),[(-8,4.2,37),(5.5,6.5,38),(4.6,6.4,30),(-2,7,25),(-5,6,30)],'umber')
    # Asymmetric scavenged metal harness across the bare torso.
    overlay(m,v(0,0,b),[(-13,2.8,62),(-9,4.7,65),(11.2,3.9,44),(7.6,5.8,42)],'leather')
    m.plate(v(2,7,53+b),(5.8,2.4,4.7),'gold',.7)
    for s in [-1,1]:
        trans=s==-1 if role=='raider' else s==1
        p=v(s*16,-1,shoulder+b)
        m.section([(p[0],p[1],p[2]-7,5,6),(p[0],p[1],p[2]-3,7.2,8.1),
                   (p[0]-s,p[1]-1,p[2]+2,5.8,6.7),(p[0]-s*2,p[1]-1,p[2]+3.3,3.4,3.5)],
                  'rust' if trans else 'skinlit',ROUND)
        if trans:
            for j in [-1,1]:
                m.tube(p+v(s*3,j*3,1),p+v(s*8,j*5-2,9+j*1.5),1.9,0,'bone',5)
            m.tube(p+v(-3,7,-2.8),p+v(3,7.1,-2),1,1,'bone')
    # Forward-projecting divided jaw, inset amber eyes, bony brow and occipital plates.
    h=v(0,4,shoulder+2+b)
    m.section([(0,h[1]+1,h[2]-1,5.5,5),(0,h[1]+.3,h[2]+4,7.9,6.4),
               (0,h[1],h[2]+9.1,7.6,6.7),(0,h[1]-1,h[2]+12.3,5.3,4.7)],'hide',ROUND)
    m.section([(0,h[1]+4.9,h[2]-.5,5,3.8),(0,h[1]+6.5,h[2]+1.8,6,4.4),
               (0,h[1]+6,h[2]+4.6,5.4,4.2)],'umber')
    for s in (-1,1):
        m.tube(h+v(s*1,5.8,7.9),h+v(s*7,3,9.4),1.8,1.4,'bone',6)
        m.plate(h+v(s*3.7,5.8,6.1),(3.9,2.9,1.6),'amber',.25)
        m.tube(h+v(s*4.2,8.4,1.9),h+v(s*5.6,9.2,6),1.3,.15,'bone',5)
    if role=='raider':
        for s in (-1,1):
            m.tube(h+v(s*5,-3,9.5),h+v(s*6,-8,14),2.3,1.15,'umber',6)
            m.tube(h+v(s*6,-8,14),h+v(s*7,-9,16.5),1.15,.15,'bone',6)
        attack=pose in ('windup','melee')
        if not attack: grip=v(-18,9,41+b);d=v(-.8,.4,.55)
        elif pose=='windup': grip=v(-20,2,62+b+6*t);d=v(-.64,-.5,.60)
        else: grip=v(-18+24*t,16,63+b-18*t);d=v(-.7+1.8*t,.8,.4-.8*t)
        blade(m,grip,d,True)
        lead=v(17,13,46+b+gait*2)
    else:
        m.plate(h+v(-2,-2,10.7),(14,11,4.1),'rust',1.25)
        m.plate(h+v(-4.7,4.2,6.3),(6.2,4.1,4.2),'black')
        m.plate(h+v(-4.7,6.55,6.3),(3.8,1,2.1),'amber')
        grip=v(-9,10-(2 if pose=='fire' else 0),49+b)
        lead=gun(m,grip,v(.02,1,.15 if pose=='fire' else .02),True)
    arm(m,v(-16,-1,shoulder+b),v(-19,2,49+b),grip,True)
    arm(m,v(16,-1,shoulder+b),v(19,4,49+b),lead,True)
def fixture(m, role):
    if role=='dummy':
        m.plate(v(0,0,2),(28,17,4),'black')
        m.plate(v(0,0,4),(22,13,3),'steel')
        m.tube(v(0,0,4),v(0,0,49),2.6,2.6,'gold')
        m.plate(v(0,0,33),(8,6,8),'black')
        m.section([(0,0,32,7,3),(0,0,37,10,4.5),(0,0,50,14,4.5),
                   (0,0,58,10.5,4),(0,0,59,6,3)],'range')
        m.plate(v(0,0,64),(11.2,7.8,11),'steel',1.8)
        for radius,offset,mat in [(7,.1,'black'),(5.8,.32,'bone'),(4.3,.54,'range'),(2.0,.76,'black')]:
            m.tube(v(0,4.6+offset,47),v(0,4.74+offset,47),radius,radius,mat,12)
        m.plate(v(0,4.28,64),(8,1.3,2.3),'black')
        return
    # Service-uniformed defender: unadorned compact body, ordinary human proportions.
    for s in [-1,1]:
        foot=v(s*5,s*.8,0);knee=v(s*4.6,.8,14)
        m.plate(foot+v(0,1.5,2.2),(6.5,10,4.2),'dark')
        m.tube(foot+v(0,0,4),knee,2.8,3.5,'black')
        m.tube(knee,v(s*4.3,0,30),3.5,4.3,'teal')
    m.section([(0,0,28,6.5,4.1),(0,0,34,7.2,4.5),(0,-.2,43,9.2,5.2),(0,0,48,9.3,4.8),
               (0,0,50,5.3,3.4)],'teal')
    m.plate(v(0,.2,31.5),(15,9,2.6),'leather')
    m.section([(0,0,49,3.8,4),(0,0,53,4.7,4.8),(0,-.4,59,4.6,4.5)],'skinlit')
    m.section([(0,-.3,54.5,5.6,5.6),(0,-.7,58,5.8,5.4),(0,-.8,61.2,3.8,4)],'teal')
    m.plate(v(0,4.6,54.7),(8.6,1.6,2),'dark')
    grip=v(-6,6,39);lead=gun(m,grip,v(.52,.65,.10))
    for s,hand in [(-1,grip),(1,lead)]:
        e=v(s*10,2,37)
        m.tube(v(s*8.1,0,47),e,3.2,2.5,'teal')
        m.tube(e,hand,2.5,1.8,'teal')
        m.plate(hand,(3.6,3.7,3.5),'black')

SEQUENCES={
 'crusader':[('idle',1),('walk',8),('fire',2),('melee',7),('guard',1),('parry',1),('reload',1),
             ('heal',1),('dodge',4),('stagger',1),('dead',1)],
 'raider':[('idle',1),('walk',8),('windup',2),('melee',5),('stagger',1),('dead',1)],
 'gunner':[('idle',1),('walk',8),('windup',1),('fire',1),('stagger',1),('dead',1)],
 'soldier':[('idle',1)], 'dummy':[('idle',1)]
}

def load_raster(tempdir):
    so=Path(tempdir)/'raster.so'
    subprocess.run(['cc','-O3','-shared','-fPIC',str(HERE/'raster.c'),'-lm','-o',str(so)],check=True)
    f=ctypes.CDLL(str(so)).triangles
    ptr=ctypes.c_void_p
    f.argtypes=[ptr,ptr,ctypes.c_int,ctypes.c_int,ctypes.c_int,ptr,ptr]
    return f

def orientation(i):
    # Gameplay aim is on the ground plane, whose depth axis is foreshortened.
    a=i*math.tau/8
    theta=math.atan2(math.cos(a), math.sin(a)/.5)
    cs,sn=math.cos(theta),math.sin(theta)
    return np.array([[cs,-sn,0.],[sn,cs,0.],[0.,0.,1.]])

def image_frame(model, turn, role, pose, raster):
    shape=np.array(model.faces)
    # Lean and fall affect the full assembled character, including weapon and cloth.
    if pose=='dead':
        ang=.96;yy=shape[:,:,1].copy();zz=shape[:,:,2].copy()
        shape[:,:,1]=yy*math.cos(ang)-zz*math.sin(ang)*.65
        shape[:,:,2]=yy*math.sin(ang)+zz*math.cos(ang)*.52+5
    if pose=='stagger':
        shape[:,:,1]-=shape[:,:,2]*.095
    # Face directions are re-lit in camera coordinates even on mirrored headings.
    shape=shape@turn
    normal=np.cross(shape[:,1]-shape[:,0],shape[:,2]-shape[:,0])
    normal/=np.maximum(np.linalg.norm(normal,axis=1,keepdims=True),1e-5)
    normal[(normal@VIEW)<0]*=-1
    shade=.49+.46*np.maximum(0,normal@KEY)+.16*np.maximum(0,normal@SKY)
    spec=np.power(np.maximum(normal@HALF,0),16)
    mat=np.array([RGB[k] for k in model.colors])
    metal=np.array([MATS[k][1] for k in model.colors])
    lit=mat*shade[:,None]+(spec*metal)[:,None]*np.array([114,106,91])
    lit+=(1-np.maximum(0,normal@KEY))[:,None]*np.array([0.,2.,5.])
    colors=np.ascontiguousarray(np.clip(lit,0,255).astype('uint8'))
    projection=np.array([[1,0,0],[0,.5,.8660254],[0,-.8660254,.5]])
    screen=shape@projection
    screen[:,:,0]=(PIVOT[0]+screen[:,:,0]*DENSITY)*SS
    screen[:,:,1]=(PIVOT[1]+screen[:,:,1]*DENSITY)*SS
    xyz=np.ascontiguousarray(screen,dtype='float32')
    w,h=W*SS,H*SS
    buf=np.zeros((h,w,4),np.uint8)
    depth=np.full((h,w),-1000,dtype='float32')
    raster(xyz.ctypes.data,colors.ctypes.data,len(shape),w,h,buf.ctypes.data,depth.ctypes.data)
    # A narrow ambient-contact shadow where several armor layers meet.
    blocker=np.maximum.reduce([np.roll(depth,4,axis=0)-depth,np.roll(depth,4,axis=1)-depth,
                               np.roll(np.roll(depth,3,axis=0),2,axis=1)-depth])
    ao=.21*np.clip((blocker-3)/8,0,1)
    buf[:,:,:3]=(buf[:,:,:3]*(1-ao[:,:,None])).astype('uint8')
    im=Image.fromarray(buf).resize((W,H),Image.Resampling.LANCZOS)
    muzzle=model.info.get('muzzle',v(0,0,55))@turn@projection
    return im, [round(muzzle[j],1) for j in range(2)]

def bake():
    import argparse
    args=argparse.ArgumentParser()
    args.add_argument('roles',nargs='*',default=list(SEQUENCES))
    selected=args.parse_args().roles
    OUTPUT.mkdir(exist_ok=True,parents=True)
    with tempfile.TemporaryDirectory() as td:
        raster=load_raster(td)
        all_meta={}
        for role in selected:
            spec=SEQUENCES[role];total=sum(count for _,count in spec)
            meta={};muzzles=[]
            for index in range((total+7)//8):
                height=min(total-index*8,8)*H
                sheet=Image.new('RGBA',(W*8,height))
                for action,count in spec:
                    start=sum(n for key,n in spec[:[k for k,n in spec].index(action)])
                    meta[action]=[start,count]
                    for local in range(count):
                        row=start+local
                        if row//8!=index: continue
                        t=(local/count if action=='walk' else local/max(1,count-1))
                        if action=='fire' and local==1: action_model='idle'
                        else: action_model=action
                        if action=='dodge': t=.15+.7*t
                        m=Model()
                        if role=='crusader': crusader(m,action_model,t)
                        elif role in ('raider','gunner'): alien(m,role,action_model,t)
                        else: fixture(m,role)
                        for i in range(8):
                            im,muzzle=image_frame(m,orientation(i),role,action,raster)
                            sheet.paste(im,(W*i,H*(row%8)))
                            if row==0: muzzles.append(muzzle)
                sheet.save(OUTPUT/f'{role}_{index}.webp',lossless=False,quality=92,method=5)
            all_meta[role]={'poses':meta,'muzzle':muzzles}
            print(role,total,flush=True)
        p=OUTPUT/'poses.json'
        current=json.loads(p.read_text()) if p.exists() else {}
        current.update(all_meta)
        p.write_text(json.dumps(current,indent=2)+'\n')

if __name__=='__main__': bake()
