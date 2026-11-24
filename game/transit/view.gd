extends Node2D

const BODY = preload("res://transit/court/knight.webp")
const MOUNTS = preload("res://transit/court/mounts.json")
const ITEM = preload("res://armory/item.gd")
const WEAPON = preload("res://armory/weapon.gd")
const IVORY = preload("res://armory/plate.tres")
const CELL := Vector2(200,202)
const PIVOT := Vector2(100,182)
const READY_ANGLES := [-54,-55,-71,-124,-128,-128,-108,-58]
const BLADE_AXIS := 48.0
const WALK := [1,0,3,0]
var weapon: WEAPON = preload("res://armory/sword.tres")
var shoulder: ITEM = IVORY
var heading := 7
var frame := 0
var stride := 0.0
var blade_angle := 0.0
var recoil := Vector2.ZERO
var body_shift := Vector2.ZERO
var feedback := 0.0
var return_stroke := false
var sword_readied := true

func kick(direction: Vector2, strength: float) -> void:
	recoil = direction * strength

func pose(aim: Vector2, movement: Vector2, action: StringName, phase: float, delta: float) -> void:
	heading = posmod(roundi(aim.angle() / (TAU/8.0)),8)
	frame = 0
	body_shift = Vector2.ZERO
	var ready := float(READY_ANGLES[heading])
	var edge := Vector2.from_angle(heading * TAU/8.0)
	blade_angle = deg_to_rad(ready)
	if action == &"melee":
		var side := -1.0 if heading in [3,4,5] else 1.0
		if return_stroke: side = -side
		var windup := deg_to_rad(ready - side * 30)
		var contact := edge.angle() + side * 0.12
		if phase < 3.0/7.0:
			var t := phase / (3.0/7.0)
			blade_angle = lerp_angle(blade_angle,windup,t)
			body_shift = -edge * 3.0*t
		elif phase < 6.0/7.0:
			frame = 2
			blade_angle = lerp_angle(contact-side*.20,contact+side*.15,(phase-3.0/7.0)*7.0/3.0)
			body_shift = edge * 3.0
		else:
			var t := (phase-6.0/7.0)*7.0
			frame = 2 if t < .45 else 0
			blade_angle = lerp_angle(contact+side*.15,deg_to_rad(ready),t)
	elif movement.length_squared() > 1.0:
		var backwards := -1.0 if movement.dot(aim) < 0 else 1.0
		stride = fposmod(stride + movement.length()*delta*backwards/91.0,1.0)
		frame = WALK[floori(stride*4)]
	elif action in [&"guard",&"parry"]:
		body_shift = -edge*2.0
		blade_angle += .24
	recoil = recoil.move_toward(Vector2.ZERO,delta*28.0)
	feedback = maxf(feedback-delta*6.0,0.0)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(4,0),-.12,Vector2(24,7))
	draw_circle(Vector2.ZERO,1,Color(.08,.09,.15,.31),true,-1,true)
	var pose_offset := (recoil + body_shift)*2
	var src := Rect2(Vector2(heading,frame)*CELL,CELL)
	var points: Array = MOUNTS.data[frame][heading]
	var grip := Vector2(points[0],points[1])
	var tint := Color.WHITE.lerp(Color(1.35,1.27,1.12),feedback)
	if heading in [5,6,7]: _blade(grip,pose_offset)
	draw_set_transform(pose_offset*.5,0,Vector2(.5,.5))
	draw_texture_rect_region(BODY,Rect2(-PIVOT,CELL),src,tint)
	if shoulder != IVORY:
		var socket := Vector2(points[2],points[3])
		draw_texture_rect(shoulder.texture,Rect2(socket-shoulder.anchor,shoulder.display_size),false)
	if heading not in [5,6,7]:
		_blade(grip,pose_offset)
		draw_set_transform(pose_offset*.5,0,Vector2(.5,.5))
		var patch := Rect2(grip-Vector2(4,5),Vector2(8,10))
		draw_texture_rect_region(BODY,patch,Rect2(src.position+PIVOT+patch.position,patch.size),tint)

func _blade(grip: Vector2, offset: Vector2) -> void:
	draw_set_transform((grip+offset)*.5,blade_angle-deg_to_rad(BLADE_AXIS),Vector2(.62,.62))
	draw_texture_rect(weapon.texture,Rect2(-weapon.anchor,weapon.display_size),false)
