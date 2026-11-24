extends Node2D
const BODY = preload("res://armory/body.webp")
const HANDS = preload("res://armory/hands.png")
const SOCKETS = preload("res://armory/sockets.json")
const PIVOT := Vector2(128,181)
const CELL := Vector2(256,208)
const Item = preload("res://armory/item.gd")
const Weapon = preload("res://armory/weapon.gd")
var weapon: Weapon = preload("res://armory/sword.tres")
var shoulder: Item = preload("res://armory/plate.tres")
var frame := 0
var stride := 0.0
var return_stroke := false
var sword_readied := true
var feedback := 0.0
var recoil := Vector2.ZERO

func kick(direction: Vector2, strength: float) -> void:
	recoil = direction * strength

func pose(_aim: Vector2, velocity: Vector2, action: StringName, phase: float, delta: float) -> void:
	if action == &"melee":
		if phase < 0.17:
			frame = 4
		elif phase < 3.0/7.0:
			frame = 5
		elif phase < 6.0/7.0:
			frame = 6
		else:
			frame = 7
	elif velocity.length_squared() > 1:
		var backwards := -1.0 if velocity.x < 0 else 1.0
		stride = fposmod(stride + velocity.length() * delta * backwards / 104.0, 1.0)
		frame = floori(stride*4)
	else:
		frame = 7
	recoil = recoil.move_toward(Vector2.ZERO, delta*25)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(2,2),0,Vector2(30,7))
	draw_circle(Vector2.ZERO,1,Color(0.10,0.08,0.11,0.29),true,-1,true)
	draw_set_transform(recoil)
	var src := Rect2(Vector2(frame%4,frame/4)*CELL,CELL)
	var body_rect := Rect2(-PIVOT,CELL)
	draw_texture_rect_region(BODY,body_rect,src)
	var points: Array = SOCKETS.data[frame]
	var socket := Vector2(points[2],points[3])-PIVOT
	draw_texture_rect(shoulder.texture,Rect2(socket-shoulder.anchor,shoulder.display_size),false)
	var grip := Vector2(points[0],points[1])-PIVOT
	var angle := float(points[4])
	if weapon.pose_angles.size() == SOCKETS.data.size():
		angle += weapon.pose_angles[frame]
	draw_set_transform(recoil + grip,deg_to_rad(angle))
	draw_texture_rect(weapon.texture,Rect2(-weapon.anchor,weapon.display_size),false)
	draw_set_transform(recoil)
	draw_texture_rect_region(HANDS,body_rect,src)
