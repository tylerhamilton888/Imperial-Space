extends Node2D

# Feet, obstacles and routes share these projected ground-plane coordinates.
const WALK_BOUNDS := Rect2(100, 130, 1380, 700)
const OBSTACLES: Array[Rect2] = [
	Rect2(780, 282, 160, 30),
	Rect2(1090, 622, 150, 30),
	Rect2(287, 263, 137, 9),
	Rect2(350, 218, 22, 15),
]
const OBSTACLE_NAMES := ["NorthCover", "SouthCover", "CrewRail", "RangeOfficer"]

@export var grid_visible: bool = false:
	set(value):
		grid_visible = value
		if is_node_ready():
			$ScaleGrid.visible = value


func _ready() -> void:
	add_to_group("arena_terrain")
	$ScaleGrid.visible = grid_visible
	var left := WALK_BOUNDS.position.x
	var top := WALK_BOUNDS.position.y
	var right := WALK_BOUNDS.end.x
	var bottom := WALK_BOUNDS.end.y
	_add_solid("WestWall", Rect2(left-64, top-64, 64, WALK_BOUNDS.size.y+128))
	_add_solid("EastWall", Rect2(right, top-64, 64, WALK_BOUNDS.size.y+128))
	_add_solid("NorthWall", Rect2(left, top-64, WALK_BOUNDS.size.x, 64))
	_add_solid("SouthWall", Rect2(left, bottom, WALK_BOUNDS.size.x, 64))
	for i in OBSTACLES.size():
		_add_solid(OBSTACLE_NAMES[i], OBSTACLES[i])
	var routes := preload("res://actors/enemies/ground_routes.gd").new()
	routes.configure(WALK_BOUNDS, OBSTACLES)
	add_child(routes)


func is_valid_spawn(pos: Vector2, radius: float = 22.0) -> bool:
	var safe_bounds := WALK_BOUNDS.grow(-radius)
	if not safe_bounds.has_point(pos):
		return false
	for obstacle in OBSTACLES:
		if obstacle.grow(radius).has_point(pos):
			return false
	return true


func _add_solid(id: String, footprint: Rect2) -> void:
	var body := StaticBody2D.new()
	body.name = id
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = footprint.get_center()
	var shape := RectangleShape2D.new()
	shape.size = footprint.size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	$Solids.add_child(body)
