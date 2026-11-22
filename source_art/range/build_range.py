"""Bake the proving ground with Blender 4.3+ in background mode.

Usage: blender -b -P source_art/range/build_range.py -- /tmp/imperial-range
Then run split_range.py on the output folder to produce runtime WebP tiles.
Projection units are ground-plane pixels. Walls and props use physical height.
"""
import math
import random
import sys
from collections import defaultdict
from pathlib import Path

import bpy
from mathutils import Vector

OUT = Path(sys.argv[sys.argv.index("--") + 1])
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
rng = random.Random(1703)
SIN = 0.68
COS = math.sqrt(1 - SIN**2)
shells = defaultdict(lambda: ([], []))
layer = "Deck"

def material(name, color, metal=0.1, rough=0.62, grain=0.11, emission=0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    tree = mat.node_tree
    shader = tree.nodes.get("Principled BSDF")
    # Artist inputs use sRGB swatches. Shader input is scene linear.
    rgb = tuple(((int(color[i:i+2], 16) / 255 + .055) / 1.055)**2.4 for i in (0, 2, 4))
    shader.inputs["Base Color"].default_value = (*rgb, 1)
    shader.inputs["Roughness"].default_value = rough
    shader.inputs["Metallic"].default_value = metal
    if grain:
        pos = tree.nodes.new("ShaderNodeNewGeometry")
        noise = tree.nodes.new("ShaderNodeTexNoise")
        noise.inputs["Scale"].default_value = 0.15
        noise.inputs["Detail"].default_value = 2.8
        tree.links.new(pos.outputs["Position"], noise.inputs["Vector"])
        ramp = tree.nodes.new("ShaderNodeValToRGB")
        for end, gain in zip(ramp.color_ramp.elements, (1-grain, 1+grain)):
            end.color = (*[min(1, c*gain) for c in rgb], 1)
        tree.links.new(noise.outputs["Fac"], ramp.inputs[0])
        tree.links.new(ramp.outputs[0], shader.inputs["Base Color"])
    if emission:
        shader.inputs["Emission Color"].default_value = (*rgb, 1)
        shader.inputs["Emission Strength"].default_value = emission
    return mat

seam = material("Deep gasket", "19282F")
deck = [material("Basalt composite %d" % i, c, .18) for i,c in enumerate(
    ("455359","49565A","46545A","4B575A","4B585D","495458","48565B","465257"))]
slate = material("Blue black steel", "263B45", .5)
teal = material("Enamel blue", "345767", .4)
rim = material("Machined edges", "71868B", .55)
mid = material("Battleship iron", "475D66", .55)
dark = material("Graphite", "20292D", .45)
pale = material("Ceramic", "B7B3A2", .15)
bronze = material("Oxidised brass", "947349", .52)
brass = material("Imperial brass", "CDA966", .55)
paint = material("Range lines", "817C64", .06, .75)
paint_blue = material("Range blue", "77939B", .12)
range_surface = material("Fireproof range coating", "3F5157", .16, .72, .23)
ring_wedges = [material("Resilient sparring tile %d" % i, c, .12, .68, .19)
              for i,c in enumerate(("48504D","4A524F","4C5450","48524F"))]
faded = material("Worn graphite marking", "545C59", .12)
crimson = material("Oxide red", "7D3836", .2)
cloth = material("Crimson standard", "9E383B", .02, .9)
cloth_dark = material("Standard turned fold", "62272F", .02, .9)
amber = material("Tungsten", "FFCB7F", .0,.4,0,3)
icy = material("Instrument lamp", "A3E4EB", .0,.4,0,2.0)

def coord(x,y,z=0):
    return (x-800, (480-y)/SIN, z)

def mesh(points, faces, mat, bevel=0):
    vs, fs = shells[(layer,mat.name,bevel)]
    offset = len(vs)
    vs.extend(points)
    fs.extend(tuple(offset+i for i in f) for f in faces)

def box(x,y,w,h,z,t,mat,bevel=0):
    floor = [(x,y+h),(x+w,y+h),(x+w,y),(x,y)]
    pts = [coord(xx,yy,zz) for zz in (z,z+t) for xx,yy in floor]
    mesh(pts, [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)], mat, bevel)

def patch(points,mat,z=.12):
    mesh([coord(x,y,z) for x,y in reversed(points)], [tuple(range(len(points)))], mat)

def strip(x1,y1,x2,y2,width,mat,z=.2):
    dx,dy=x2-x1,(y2-y1)/SIN
    length=math.hypot(dx,dy)
    nx,ny=-dy/length*width/2, dx/length*width/2*SIN
    patch([(x1+nx,y1+ny),(x2+nx,y2+ny),(x2-nx,y2-ny),(x1-nx,y1-ny)],mat,z)

def arc(x,y,r,start,end,width,mat):
    for i in range(64):
        a=math.radians(start+(end-start)*i/64)
        b=math.radians(start+(end-start)*(i+1)/64)
        patch([(x+rr*math.cos(t),y+rr*math.sin(t)*SIN)
               for rr,t in [(r,a),(r,b),(r-width,b),(r-width,a)]],mat,.32)

def raised_mark(points,mat):
    mesh([coord(*p) for p in points], [tuple(range(len(points)))], mat)

def fastener(x,y,z,mat=bronze):
    patch([(x+2,y),(x+1,y+1.2),(x-1,y+1.2),(x-2,y),(x-1,y-1.2),(x+1,y-1.2)],mat,z)

def stencil(words,x,y,size,mat,wall=False):
    curve=bpy.data.curves.new(words,"FONT")
    curve.body=words
    curve.size=size
    curve.space_character=1.08
    ob=bpy.data.objects.new(words,curve)
    scene.collection.objects.link(ob)
    ob.location=coord(x,y,.55)
    ob.rotation_euler.x=math.pi/2 if wall else 0
    ob.data.materials.append(mat)
    ob["range_layer"]=layer
    return ob

# Slab joints, service trenches and central floor markings are flush walkable surfaces.
box(-75,-150,1750,1280,-10,9,seam)
for row in range(-2,14):
    yy=48+row*72
    for col in range(-1,11):
        xx=18+col*168+(row%2)*84
        box(xx,yy,167.1,71.2,-1,1, rng.choice(deck),.48)
        for px,py in ((8,7),(159,65)):
            fastener(xx+px,yy+py,.048,slate)
        if rng.random()<.15:
            strip(xx+14,yy+65,xx+36,yy+65,.7,faded,.06)
# Twin perimeter trench channels.
for x in (115,1448):
    box(x,144,17,676,-.1,.25,dark)
    for y in range(148,817,10):
        box(x+1,y,15,3,.23,1.2,mid,.35)
for y in (146,801):
    box(132,y,1316,8,.02,.2,dark)
    for x in range(139,1442,18):
        strip(x,y+1,x+8,y+7,2.3,mid,.4)
# Replaceable gun-deck panels form a long clipped rectangle. Paint terminates
# at each joint so the firing lane still reads as part of the ship's deck.
for i in range(8):
    x=702+i*85
    inset_a=18 if i==0 else 0
    inset_b=18 if i==7 else 0
    patch([(x+inset_a,344),(x+83-inset_b,344),(x+83,356),(x+83,533),
           (x+83-inset_b,543),(x+inset_a,543),(x,531),(x,356)],range_surface,.11)
    for yy in (352,534):
        fastener(x+27,yy,.19,slate)
        fastener(x+61,yy,.19,slate)
# Long gun deck with firing line, subdued lanes and numbered intervals.
for y in (338,548):
    strip(695,y,1384,y,2.4,paint_blue)
    strip(695,y+5,1384,y+5,.9,paint_blue)
for x in range(718,1389,67):
    for y,sign in ((340,1),(548,-1)):
        strip(x,y,x,y+7*sign,2.2,paint_blue,.36)
for yy in (365,403,441,479,517):
    strip(714,yy,719,yy,2.6,paint)
for x,num in ((735,"05"),(1003,"10"),(1271,"15")):
    stencil(num,x,332,15,paint_blue)
for x in (930,1090,1230):
    for dx,dy in ((-20,-11),(20,-11),(-20,11),(20,11)):
        strip(x+dx,445+dy,x+dx*.57,445+dy,2,paint_blue)
        strip(x+dx,445+dy,x+dx,445+dy*.4,2,paint_blue)
stencil("RIFLE LANE",1194,528,24,paint_blue)
# Radial shock mats sit flush with the floor. Leave narrow expansion joints
# and control contrast so a fallen actor and blade anticipation remain legible.
for i in range(16):
    a,b=(2*math.pi*(i+s)/16 for s in (.012,.988))
    points=[(438+rr*math.cos(t),487+rr*SIN*math.sin(t))
            for rr,t in ((52,a),(181,a),(181,(a+b)/2),(181,b),(52,b))]
    patch(points,ring_wedges[i%4],.14)
patch([(438+51*math.cos(i*math.pi/24),487+51*SIN*math.sin(i*math.pi/24))
       for i in range(48)],ring_wedges[1],.14)
# Inlaid sparring ring with four precisely aligned entrances.
for a in (0,90,180,270):
    arc(438,487,184,a+5,a+85,3.5,paint)
    arc(438,487,173,a+15,a+75,.85,paint)
    for da in (-12,0,12):
        f=math.radians(a+da)
        strip(438+188*math.cos(f),487+188*SIN*math.sin(f),
              438+196*math.cos(f),487+196*SIN*math.sin(f),3,paint)
for side in (-1,1):
    strip(438+side*15,487,438+side*37,487,2.3,paint)
    strip(438,487+side*10,438,487+side*20,2.3,paint)
stencil("SPARRING",383,573,25,paint)
# Diagnostic barrier bay, physical cover is drawn separately for correct y sorting.
for x,y in ((780,282),(1090,622)):
    for corner,sign in ((x-8,1),(x+168,-1)):
        strip(corner,y+33,corner+sign*14,y+33,3,paint)
        strip(corner,y+33,corner,y+24,3,paint)

# Rear armored bulkhead, wainscot, bolted modular coffers and structural end piers.
box(34,64,1526,54,-12,208,slate,5)
box(34,107,1526,12,2,19,dark,2)
box(39,114,1516,9,1,6,bronze,1)
for x in range(49,1550,125):
    box(x,105,116,14,19,138,mid,3)
    box(x+6,119,104,4,30,112,slate,2)
    box(x+13,123,90,2,39,85,teal,1)
    box(x+18,125,80,2,130,4,bronze,1)
    for xx in (x+12,x+99):
        for z in (33,135):
            box(xx,125,3,1,z,3,rim,.5)
    box(x-7,104,12,22,3,165,dark,2)
    box(x-6,124,9,3,38,113,rim,1)
# Personnel airlock and guards, built at ordinary human height.
dx=366
box(dx-63,117,126,13,1,137,dark,3)
box(dx-55,126,110,6,4,125,bronze,3)
box(dx-49,132,98,4,5,116,dark,2)
for door_x in (dx-46,dx+1):
    box(door_x,136,45,1,5,112,mid,1)
    box(door_x+3,137,39,1,14,62,slate,1)
    box(door_x+3,137,39,1,88,15,teal,1)
    box(door_x+7,139,31,1,96,4,icy,.4)
box(dx-63,133,126,7,127,10,slate,2)
box(dx-36,139,72,1,130,4,amber)
box(dx-56,132,112,8,0,3,pale,1)
# Back firing traps: ceramic slats, deep inset between them, a brass lintel.
for x in (976,1101,1226,1351):
    box(x-44,125,89,8,28,113,dark,1)
    for z in range(38,134,13):
        box(x-40,132,81,4,z,8,mid,1.6)
    box(x-43,132,88,6,138,5,brass,1)
# Original heraldic plate: a three-rayed rising star on an oxblood hanging standard.
for x in (224,720,1474):
    box(x-23,128,46,6,63,106,cloth_dark,1)
    raised_mark([(x-19,136,169),(x+19,136,169),(x+18,136,83),
                 (x,136,62),(x-18,136,83)],cloth)
    for side in (-1,1):
        raised_mark([(x+side*16,137,132),(x+side*9,137,111),
                     (x+side*4,137,105),(x+side*9,137,128)],brass)
    raised_mark([(x,137,148),(x+3,137,124),(x,137,99),(x-3,137,124)],pale)
    box(x-31,135,62,4,165,5,brass,1)
# Buttress feet, local warm utility lamps and twin suspended conductor rails.
for x in (105,553,845,1443):
    box(x-28,97,56,32,0,38,slate,4)
    box(x-17,105,34,21,36,146,mid,4)
    box(x-10,125,20,4,52,107,dark,1)
    box(x-7,130,14,2,68,65,bronze,.7)
    box(x-12,132,24,4,142,10,dark,1)
    box(x-9,136,18,2,144,5,amber)
# Side cutaway walls and training backstop east.
for sx in (47,1484):
    box(sx,119,55,711,-10,30,slate,2)
    box(sx+3,123,49,702,20,6,mid,2)
    for y in range(133,819,113):
        box(sx-1,y,57,13,-2,36,bronze,2)
        box(sx+2,y+3,51,7,33,3,rim,1)
for y in (342,444,546):
    box(1487,y-32,18,66,25,58,teal,2)
    box(1485,y-29,7,59,35,38,mid,1)
# Near boundary: a deck service pit, armored rim and a pipe run, tucked below play.
box(-60,846,1740,170,0,2,dark)
for x in range(29,1600,91):
    box(x,853,84,77,1,7,slate,1)
    for xx in range(x+5,x+80,8): box(xx,860,3,58,8,1.5,mid)
box(45,830,1500,13,0,11,mid,2)
box(47,831,1496,3,10,2,bronze,.6)
for x in (171,667,1163):
    for off in range(0,70,13): strip(x+off,792,x+off+9,800,4.0,paint)
stencil("SERVICE TRENCH",760,791,13,paint)

# Props use a second transparent plate. Their camera-independent shadows stay on the floor.
def armored_cover(x,y,w):
    box(x,y,w,30,0,7,dark,3)
    box(x+4,y+3,w-8,25,6,35,slate,3)
    # The spaced ceramic facing and high armored lip distinguish these blast
    # shields from weapon chests, including when the player moves behind one.
    for left in (x+9,x+w/2+3):
        box(left,y+23,w/2-13,5,12,26,teal,2)
        box(left+5,y+27,w/2-23,2,13,22,pale,1.5)
        box(left+6,y+29,w/2-25,1,17,3,crimson)
        for xx in (left+7,left+w/2-20):
            box(xx,y+30,2,1,29,2,dark)
    box(x+3,y+2,w-6,23,40,6,mid,2)
    box(x+4,y+18,w-8,6,45,6,pale,1.5)
    for xx in (x+11,x+w-19):
        box(xx,y+4,7,19,46,6,bronze,1.5)
    box(x+8,y+4,w-16,3,46,1,bronze)
    for xx in (x+1,x+w/2-4,x+w-9):
        box(xx,y+1,8,28,6,40,bronze,1.4)
        box(xx+1,y+5,6,4,46,1.2,brass)
    for xx in (x+13,x+w-22):
        box(xx,y+25,9,4,32,5,icy,1)
layer="NorthCover"
armored_cover(780,282,160)
layer="SouthCover"
armored_cover(1090,622,150)
layer="CrewRail"
for xx in (293,356,418):
    box(xx-4,263,8,9,0,5,slate,1)
    box(xx-2.8,265,5.6,4.8,4,39,bronze,1)
box(287,264,137,6,42,5,brass,1.7)
box(290,266,131,3,20,3,mid,.7)

# Emit a compact mesh per material, bevel only armor edges and plate corners.
for (group,matname,bevel),(vertices,faces) in shells.items():
    data=bpy.data.meshes.new(matname)
    data.from_pydata(vertices,[],faces)
    data.update()
    obj=bpy.data.objects.new(group+" / "+matname,data)
    scene.collection.objects.link(obj)
    data.materials.append(bpy.data.materials[matname])
    obj["range_layer"]=group
    if bevel:
        mod=obj.modifiers.new("Rolled edges","BEVEL")
        mod.width=bevel
        mod.segments=2
        mod=obj.modifiers.new("Weighted normals","WEIGHTED_NORMAL")
        mod.keep_sharp=True

world=bpy.data.worlds.new("High bay ambient")
scene.world=world
world.use_nodes=True
world.node_tree.nodes["Background"].inputs[0].default_value=(.46,.62,.78,1)
world.node_tree.nodes["Background"].inputs[1].default_value=.49
def light(name,kind,location,target,color,energy,size):
    dat=bpy.data.lights.new(name,kind)
    ob=bpy.data.objects.new(name,dat)
    scene.collection.objects.link(ob)
    ob.location=location
    ob.rotation_euler=(Vector(target)-ob.location).to_track_quat("-Z","Y").to_euler()
    dat.color=color
    dat.energy=energy
    if kind=="SUN": dat.angle=size
    else: dat.shape="DISK"; dat.size=size
light("Port windows","SUN",(-600,420,920),(0,0,0),(1,.87,.70),2.25,.14)
light("Cool shutter","AREA",(530,310,410),(200,0,0),(.40,.75,1),2400000,610)
light("Bay lamps","AREA",(-470,120,250),(-390,130,0),(1,.56,.22),900000,250)
camera=bpy.data.cameras.new("Fixed ground projection")
camera.type="ORTHO"
camera.ortho_scale=1600
camera.clip_end=9000
ob=bpy.data.objects.new("Camera",camera)
scene.collection.objects.link(ob)
ob.location=(0,-COS*3500,SIN*3500)
ob.rotation_euler=(-ob.location).to_track_quat("-Z","Y").to_euler()
scene.camera=ob
scene.render.engine="CYCLES"
scene.cycles.samples=24
scene.cycles.use_denoising=False
scene.cycles.max_bounces=4
scene.render.resolution_x=1600
scene.render.resolution_y=960
scene.render.resolution_percentage=100
scene.render.image_settings.color_mode="RGBA"
scene.render.film_transparent=True
scene.view_settings.view_transform="AgX"
for mode in ("deck","props"):
    for obj in scene.objects:
        grp=obj.get("range_layer")
        if grp: obj.visible_camera=(grp=="Deck")==(mode=="deck")
    scene.render.filepath=str(OUT/(mode+".png"))
    bpy.ops.render.render(write_still=True)
