extends Node2D
## Directional plates share one pivot at the feet. Combat collision is owned by the actor.

const GRIPS = preload("res://art/raider/grips.json")
const DENSITY := 1.5
const CARRY = preload("res://art/painted/medium_sword_carry.webp")
const SWORD = preload("res://art/painted/medium_sword.webp")
const STRAFE = preload("res://art/movement/medium_strafe.webp")
const DATA := preload("res://art/actors/poses.json")
const SHEETS := {
	&"crusader": [preload("res://art/actors/crusader_0.webp"), preload("res://art/actors/crusader_1.webp"),
		preload("res://art/actors/crusader_2.webp"), preload("res://art/actors/crusader_3.webp")],
	&"raider": [preload("res://art/actors/raider_0.webp"), preload("res://art/actors/raider_1.webp"),
		preload("res://art/actors/raider_2.webp")],
	&"gunner": [preload("res://art/actors/gunner_0.webp"), preload("res://art/actors/gunner_1.webp")],
	&"dummy": [preload("res://art/actors/dummy_0.webp")],
	&"soldier": [preload("res://art/actors/soldier_0.webp")],
}

@export_enum("crusader", "raider", "gunner", "dummy", "soldier") var role: String = "crusader"
var facing := Vector2.DOWN
var travel := 0.0
var sword_readied := false
var return_stroke := false
var action: StringName = &"idle"
var phase := 0.0
var feedback := 0.0
var _recoil := Vector2.ZERO
var _stride := 0.0
var _strafing := false
var _reverse_stride := false
@onready var _cast_shadow := Sprite2D.new()


func _ready() -> void:
	# Ground shadows sit beneath every actor and piece of cover. Project the
	# active pose from its boot pivot so a moving cloak casts a moving shadow.
	_cast_shadow.centered = false
	_cast_shadow.region_enabled = true
	_cast_shadow.region_filter_clip_enabled = true
	_cast_shadow.z_index = -2
	_cast_shadow.self_modulate = Color(0.06, 0.07, 0.10, 0.26)
	_cast_shadow.transform = Transform2D(
		Vector2(1.0, 0.0) / DENSITY,
		Vector2(-0.42, -0.20) / DENSITY,
		Vector2.ZERO
	)
	add_child(_cast_shadow)


func pose(aim: Vector2, movement: Vector2, state: StringName, progress: float, _delta: float) -> void:
	facing = aim
	travel = clampf(movement.length() / 190.0, 0.0, 1.0)
	action = state
	phase = progress
	var lateral := aim.cross(movement.normalized())
	_strafing = role == "crusader" and absf(lateral) >= 0.70
	_reverse_stride = lateral < 0 if _strafing else movement.dot(aim) < 0
	queue_redraw()

func kick(direction: Vector2, strength: float) -> void:
	_recoil = direction.normalized() * strength
	queue_redraw()

func _process(delta: float) -> void:
	if not _recoil.is_zero_approx():
		_recoil = _recoil.move_toward(Vector2.ZERO, delta * 38.0)
		queue_redraw()
	if travel > 0.01:
		var direction := -1.0 if _reverse_stride else 1.0
		_stride = fposmod(_stride + delta * travel * direction * 2.15, 1.0)
		queue_redraw()
	if feedback > 0.0:
		feedback = maxf(0.0, feedback - delta * 7.0)
		queue_redraw()

func _heading() -> int:
	return posmod(roundi(facing.angle() / (TAU / 8.0)), 8)

func muzzle_offset() -> Vector2:
	var point: Array = DATA.data[role].muzzle[_heading()]
	return Vector2(point[0], point[1])

func _pose_row() -> int:
	var poses: Dictionary = DATA.data[role].poses
	var id := action
	if id == &"idle" and travel > 0.01:
		id = &"walk"
	if not poses.has(id):
		id = &"idle"
	var pose_range: Array = poses[id]
	var progress := _stride if id == &"walk" else phase
	return int(pose_range[0]) + clampi(floori(progress * int(pose_range[1])), 0, int(pose_range[1]) - 1)

func cleaver_transform() -> Transform2D:
	var socket: Array = GRIPS.data[_pose_row()][_heading()]
	return Transform2D(deg_to_rad(socket[2]),Vector2(socket[0],socket[1])/DENSITY + _recoil * 0.24)

func _draw() -> void:
	if not SHEETS.has(role):
		return
	var row := _pose_row()
	var id := &"walk" if action == &"idle" and travel > 0.01 else action
	var progress := phase
	var dimensions := Vector2(16.0, 6.0) if role == "crusader" else Vector2(13.5, 5.0)
	draw_set_transform(Vector2(0, 1), 0, dimensions)
	draw_circle(Vector2.ZERO, 1, Color(0.025, 0.03, 0.04, 0.28), true, -1.0, true)
	draw_circle(Vector2.ZERO, 0.68, Color(0.025, 0.03, 0.04, 0.22), true, -1.0, true)
	draw_set_transform(Vector2.ZERO)
	var cell_data: Array = DATA.data[role].cell
	var pivot_data: Array = DATA.data[role].pivot
	var cell := Vector2(cell_data[0], cell_data[1])
	var pivot := Vector2(pivot_data[0], pivot_data[1])
	var source := Rect2(Vector2(_heading(), row % 8) * cell, cell)
	var sprite: Texture2D = SHEETS[role][floori(row / 8.0)]
	if role == "crusader" and id == &"melee" and _heading() not in [2,6]:
		# Windup, transfer, extension and low finish have separate foot and
		# cloak outlines. Extension begins on the resolver's first contact tick.
		var key := 0
		if return_stroke:
			if progress < 3.0/7.0:
				key = 3
			elif progress < 6.0/7.0:
				key = 2
			elif progress < 0.94:
				key = 1
		elif progress >= 6.0/7.0:
			key = 3
		elif progress >= 3.0/7.0:
			key = 2
		elif progress >= 0.17:
			key = 1
		sprite = SWORD
		source.position.y = key * cell.y
	elif role == "crusader" and sword_readied and id in [&"walk",&"idle"]:
		sprite = CARRY
		source.position.y = floori(_stride*8.0)*cell.y if travel>0.01 else 0.0
	elif _strafing and travel > 0.01 and id in [&"walk", &"fire"]:
		sprite = STRAFE
		source.position.y = floori(_stride * 8.0) * cell.y
	_cast_shadow.texture = sprite
	_cast_shadow.region_rect = source
	_cast_shadow.offset = -pivot
	var tint := Color.WHITE.lerp(Color(1.23,1.16,1.07),feedback)
	tint.a = 1.0
	# Shear about the boot pivot: the torso absorbs the blow while the feet
	# and their collision stay planted. Vertical recoil compresses the pose.
	var transform := Transform2D(Vector2.RIGHT, Vector2(-_recoil.x / 90.0, 1.0 - _recoil.y / 110.0), Vector2.ZERO)
	if role == "raider":
		transform = Transform2D(0.0,_recoil * 0.24)
	draw_set_transform_matrix(transform)
	draw_texture_rect_region(sprite, Rect2(-pivot / DENSITY, cell / DENSITY), source, tint)

## Leave a brief, collision-free silhouette after the combat actor is retired.
## Its owning encounter removes it immediately on clear or reset.
func leave_fallen_pose(ground: Node2D, feet: Vector2) -> void:
	var poses: Dictionary = DATA.data[role].poses
	if not poses.has(&"dead"):
		return
	var row: int = poses[&"dead"][0]
	var size_data: Array = DATA.data[role].cell
	var pivot: Array = DATA.data[role].pivot
	var cell := Vector2(size_data[0], size_data[1])
	var remains := Sprite2D.new()
	remains.texture = SHEETS[role][floori(row / 8.0)]
	remains.centered = false
	remains.region_enabled = true
	remains.region_filter_clip_enabled = true
	remains.region_rect = Rect2(Vector2(_heading(), row % 8)*cell, cell)
	remains.offset = -Vector2(pivot[0], pivot[1])
	remains.scale = Vector2.ONE / DENSITY
	ground.add_child(remains)
	remains.global_position = feet
	remains.add_to_group(&"fallen_actors")
	var fade := remains.create_tween()
	fade.tween_interval(1.5)
	fade.tween_property(remains,"modulate:a",0.0,0.5)
	fade.tween_callback(remains.queue_free)
