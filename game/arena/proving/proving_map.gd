extends "res://arena/range_map.gd"

signal objective_changed
const Gate = preload("res://arena/proving/breach_gate.gd")
var outline := PackedVector2Array([Vector2(28,351),Vector2(811,187),Vector2(1248,248),
	Vector2(1248,491),Vector2(713,626),Vector2(521,626),Vector2(28,465)])
const FLOOR_BOUNDS := Rect2(28,187,1220,439)
const APERTURE := Rect2(655,395,86,18)
const FIXTURES: Array[Rect2] = [
	Rect2(613,386,42,22), Rect2(741,402,43,22),
	Rect2(220,347,56,14), Rect2(321,315,56,14), Rect2(996,461,62,21)]
const NAMES := ["WestJamb","EastJamb","TargetOne","TargetTwo","RangeTerminal"]

@onready var gate: Gate = $Gate
@onready var breakables: Array[Gate] = [gate,$WestWing,$EastWing]
var routes := preload("res://actors/enemies/ground_routes.gd").new()
var crossed := false
var previous_feet := Vector2.ZERO
var tracking_started := false

func _ready() -> void:
	add_to_group("arena_terrain")
	$ScaleGrid.visible = grid_visible
	var body := StaticBody2D.new()
	var edges := CollisionPolygon2D.new()
	edges.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	edges.polygon = outline
	body.add_child(edges)
	$Solids.add_child(body)
	for i in FIXTURES.size():
		if NAMES[i] not in ["TargetOne", "TargetTwo"]:
			_add_solid(NAMES[i], FIXTURES[i])
	add_child(routes)
	for fixture in breakables:
		fixture.opened.connect(_rebuild_routes)
	gate.integrity_changed.connect(func(): objective_changed.emit())
	_rebuild_routes()

func _standing_solids() -> Array[Rect2]:
	var solids: Array[Rect2] = FIXTURES.duplicate()
	for fixture in breakables:
		if fixture.is_open:
			continue
		var shape := fixture.get_child(0) as CollisionShape2D
		var bounds := shape.shape.get_rect()
		solids.append(Rect2(fixture.position+shape.position+bounds.position,bounds.size))
	return solids

func _rebuild_routes() -> void:
	routes.configure(FLOOR_BOUNDS,_standing_solids(),outline)

func is_valid_spawn(pos: Vector2, radius: float = 22.0) -> bool:
	if not Geometry2D.is_point_in_polygon(pos, outline):
		return false
	for i in outline.size():
		if Geometry2D.get_closest_point_to_segment(pos, outline[i], outline[(i+1)%outline.size()]).distance_to(pos) < radius:
			return false
	for fixture in _standing_solids():
		if fixture.grow(radius).has_point(pos):
			return false
	return true

func track_passage(feet: Vector2) -> void:
	var line_y := APERTURE.get_center().y
	if tracking_started and gate.is_open and not crossed and previous_feet.y >= line_y and feet.y < line_y:
		var x_at_line := lerpf(previous_feet.x, feet.x, (previous_feet.y-line_y)/(previous_feet.y-feet.y))
		if x_at_line > APERTURE.position.x and x_at_line < APERTURE.end.x:
			crossed = true
			objective_changed.emit()
	previous_feet = feet
	tracking_started = true
