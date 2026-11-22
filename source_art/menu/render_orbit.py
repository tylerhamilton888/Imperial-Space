"""Bake the original orbital view for the Imperial Space title screen."""
from pathlib import Path
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
W, H = 1024, 576
rng = np.random.default_rng(45)
y, x = np.mgrid[:H, :W]

def field(rows, cols):
    noise = rng.integers(0, 255, (rows, cols), dtype=np.uint8)
    return np.asarray(Image.fromarray(noise).resize((W, H), Image.Resampling.BICUBIC)) / 255

mist = field(8, 12) * .5 + field(29, 54) * .32 + field(131, 239) * .18
sky = np.zeros((H, W, 3)) + [6, 13, 21]
sky += np.exp(-((y - 470 + x*.33)/125)**2)[:, :, None] * mist[:, :, None]**2 * [17, 39, 53]
stars = rng.random((H, W)) > .996
sky += stars[:, :, None] * rng.uniform(.12, .8, (H, W, 1)) * [155, 164, 167]

def sphere(arr, cx, cy, radius, palette, glow, small=False):
    nx, ny = (x-cx)/radius, (y-cy)/radius
    d = np.sqrt(nx*nx+ny*ny)
    inside = d <= 1
    nz = np.sqrt(np.maximum(0, 1-d*d))
    light = np.maximum(0, -.63*nx-.71*ny+.19*nz)
    surface = field(13, 19)*.42 + field(42, 76)*.25 + field(140, 260)*.18 + field(270, 450)*.15
    bands = np.cos(ny*40 + nx*5 + np.sin(nx*12)*.7 + surface*4)
    clouds = np.clip((surface+.09*bands-.42)*3,0,1) * np.sqrt(nz)
    base = np.array(palette) + clouds[:, :, None]*[65,75,68]
    values = np.array([8,17,25]) + base * (light**.8)[:, :, None]
    rim = np.exp(-np.maximum(0,1-d)*(30 if small else 62))*light
    values += rim[:, :, None]*glow
    halo = np.exp(-abs(d-1)*(45 if small else 54))*light
    arr[~inside] += (halo[:, :, None]*glow*.9)[~inside]
    arr[inside] = values[inside]

sphere(sky, 878, 43, 36, [98,98,86], np.array([48,55,59]), True)
sphere(sky, 905, 611, 465, [41,73,82], np.array([110,145,150]))
im = Image.fromarray(np.uint8(np.clip(sky,0,255)))
# An original cruiser in three-quarter profile. Hull systems run along the keel.
S = 3
hull = Image.new('RGBA', (W*S,H*S))
draw = ImageDraw.Draw(hull)
def at(u,v):
    return int(S*(773+u*.97+v*.29)), int(S*(198-u*.32+v*.9))
def poly(points, color):
    draw.polygon([at(*p) for p in points], fill=color)
def line(points, color, width=1):
    draw.line([at(*p) for p in points], fill=color, width=S*width)
for yy in (11,18,24):
    poly([(-138, yy-3),(-191,yy),(-138,yy+2)], (97,178,191,70))
    line([(-154,yy),(-137,yy)], '#c4eff1')
poly([(-138,-2),(-108,-13),(-62,-13),(-44,-25),(-13,-26),(-7,-19),(56,-20),(74,-15),(142,-13),(159,-18),(151,-4),(107,14),(46,22),(-85,34),(-134,27)], '#1a2932')
poly([(-136,-1),(-105,-11),(-58,-11),(-45,-22),(-12,-23),(-5,-16),(61,-17),(75,-12),(141,-10),(152,-14),(116,1),(65,7),(-81,17),(-136,12)], '#8b9691')
poly([(-134,12),(-84,17),(66,7),(116,1),(152,-14),(145,-2),(76,17),(-75,28),(-133,23)], '#405157')
poly([(-128,11),(-77,14),(57,4),(90,-1),(95,3),(-73,19),(-129,16)], '#cf9b5c')
poly([(-102,0),(-85,-11),(-39,-12),(-26,-20),(-7,-18),(-14,-8),(-54,-2),(-59,3)], '#d0c6a8')
poly([(-64,-9),(-50,-15),(-44,-27),(-19,-30),(-9,-24),(-20,-12)], '#45585b')
poly([(-44,-27),(-37,-35),(-23,-37),(-17,-30)], '#b6b6a3')
poly([(-40,-34),(-39,-41),(-35,-42),(-33,-35)], '#929e98')
for u in range(-105,95,9):
    poly([(u,6-u*.055),(u+5,6-u*.055),(u+6,8-u*.055),(u+1,8-u*.055)], '#c9c4aa')
for u in range(-85,74,7):
    yy = 21-u*.082
    line([(u,yy),(u+2,yy)], '#e3a562')
for u in (-119,-98,-72,3,29,52,78,103):
    line([(u,-8),(u+4,-4),(u-2,2)], '#46545a')
for u in (-1,20,41):
    poly([(u,-11),(u+4,-16),(u+11,-16),(u+13,-11)], '#324450')
    line([(u+7,-16),(u+20,-18)], '#bfc1af')
im = Image.alpha_composite(im.convert('RGBA'), hull.resize((W,H), Image.Resampling.LANCZOS))
# Grade the command side down to preserve the type and the stars behind it.
a = np.asarray(im.convert('RGB')).copy()
shade = np.clip((x-230)/430, 0, 1)*.88+.12
a = a*shade[:,:,None] + np.array([7,17,24])*(1-shade[:,:,None])
out = ROOT/'game/art/menu/orbital_watch.jpg'
Image.fromarray(np.uint8(a)).save(out, quality=92, subsampling=0, optimize=True)
