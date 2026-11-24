extends "res://armory/view.gd"
const LEFT_BODY = preload("res://transit/knight_left.webp")
const LEFT_GRIPS = preload("res://transit/grips.json")
var looks_left := false

func pose(aim: Vector2, movement: Vector2, action: StringName, phase: float, delta: float) -> void:
	if absf(aim.x) > 0.12:
		looks_left = aim.x < 0
	# The walk clock tracks forward motion in either illustrated direction.
	var gait := Vector2(-movement.x,movement.y) if looks_left else movement
	super.pose(aim,gait,action,phase,delta)

func _draw() -> void:
	if not looks_left:
		super._draw()
		return
	draw_set_transform(Vector2(2,2),0,Vector2(30,7))
	draw_circle(Vector2.ZERO,1,Color(0.10,0.08,0.11,0.29),true,-1,true)
	var points: Array = LEFT_GRIPS.data[frame]
	var right_angles: Array = SOCKETS.data[frame]
	var shoulder_socket := Vector2(points[2],points[3])-PIVOT
	var hand := Vector2(points[0],points[1])-PIVOT
	draw_set_transform(recoil+shoulder_socket,0,Vector2(-1,1))
	draw_texture_rect(shoulder.texture,Rect2(-shoulder.anchor,shoulder.display_size),false)
	draw_set_transform(recoil+hand,-deg_to_rad(right_angles[4]),Vector2(-1,1))
	draw_texture_rect(weapon.texture,Rect2(-weapon.anchor,weapon.display_size),false)
	# The far fist and blade sit behind the near shield in this facing.
	draw_set_transform(recoil)
	draw_texture_rect_region(LEFT_BODY,Rect2(-PIVOT,CELL),Rect2(Vector2(frame%4,frame/4)*CELL,CELL))
