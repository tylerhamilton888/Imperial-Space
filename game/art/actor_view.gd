extends Node2D
## Directional plates share one pivot at the feet. Combat collision is owned by the actor.

const DENSITY := 1.5
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
var action: StringName = &"idle"
var phase := 0.0
var feedback := 0.0
var _stride := 0.0
var _reverse_stride := false

func pose(aim: Vector2, movement: Vector2, state: StringName, progress: float, _delta: float) -> void:
	facing = aim
	travel = clampf(movement.length() / 190.0, 0.0, 1.0)
	action = state
	phase = progress
	_reverse_stride = movement.dot(aim) < 0
	queue_redraw()

func _process(delta: float) -> void:
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

func _draw() -> void:
	if not SHEETS.has(role):
		return
	var poses: Dictionary = DATA.data[role].poses
	var id := action
	if id == &"idle" and travel > 0.01:
		id = &"walk"
	if not poses.has(id):
		id = &"idle"
	var pose_range: Array = poses[id]
	var progress := _stride if id == &"walk" else phase
	var row := int(pose_range[0]) + clampi(floori(progress * int(pose_range[1])), 0, int(pose_range[1]) - 1)
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
	var tint := Color.WHITE * (1.0 + 0.65 * feedback)
	tint.a = 1.0
	draw_texture_rect_region(sprite, Rect2(-pivot / DENSITY, cell / DENSITY), source, tint)
