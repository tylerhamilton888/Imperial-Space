extends Node
## A zone owns one traversal grid. Search uses only the caller's last observed goal.

const CELL := 24.0
const CLEARANCE := 16.0
var _grid := AStarGrid2D.new()
var _obstacles: Array[Rect2] = []
var _solid_footprints: Array[Rect2] = []

func _ready() -> void:
	add_to_group(&"combat_navigation")

func configure(walk_bounds: Rect2, obstacles: Array[Rect2]) -> void:
	_grid.clear()
	var bounds := walk_bounds.grow(-CLEARANCE)
	var columns := maxi(1, floori(bounds.size.x / CELL))
	var rows := maxi(1, floori(bounds.size.y / CELL))
	_grid.region = Rect2i(0, 0, columns, rows)
	_grid.cell_size = Vector2(CELL, CELL)
	_grid.offset = bounds.position + Vector2(CELL, CELL) * 0.5
	_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_grid.update()
	_obstacles.clear()
	_solid_footprints.assign(obstacles)
	for obstacle in obstacles:
		_obstacles.append(obstacle.grow(CLEARANCE + 2.0))
	for row in range(rows):
		for column in range(columns):
			var cell := Vector2i(column, row)
			var center := _grid.get_point_position(cell)
			for obstacle in _obstacles:
				# Block every cell footprint touching an expanded wall. This also
				# covers thin rails which could otherwise fall between grid centers.
				if obstacle.grow(CELL * 0.5).has_point(center):
					_grid.set_point_solid(cell)
					break

func _can_walk_segment(start: Vector2, finish: Vector2) -> bool:
	return _clear_segment(start, finish, _obstacles)

func _clear_segment(start: Vector2, finish: Vector2, walls: Array[Rect2]) -> bool:
	var extent := Rect2(start, Vector2.ZERO).expand(finish)
	for wall in walls:
		if not wall.intersects(extent, true):
			continue
		if wall.has_point(start) or wall.has_point(finish):
			return false
		var a := wall.position
		var b := Vector2(wall.end.x, wall.position.y)
		var c := wall.end
		var d := Vector2(wall.position.x, wall.end.y)
		for edge: Array in [[a,b],[b,c],[c,d],[d,a]]:
			if Geometry2D.segment_intersects_segment(start, finish, edge[0], edge[1]) != null:
				return false
	return true

func _nearest_cell(point: Vector2) -> Vector2i:
	var center := Vector2i(((point - _grid.offset) / CELL).round()).clamp(
		Vector2i.ZERO, _grid.region.size - Vector2i.ONE)
	if not _grid.is_point_solid(center):
		return center
	var closest := Vector2i(-1, -1)
	var best_distance := INF
	for y in range(maxi(0, center.y - 3), mini(_grid.region.size.y, center.y + 4)):
		for x in range(maxi(0, center.x - 3), mini(_grid.region.size.x, center.x + 4)):
			var cell := Vector2i(x,y)
			if _grid.is_point_solid(cell):
				continue
			var pos := _grid.get_point_position(cell)
			var distance := pos.distance_squared_to(point)
			# Reach actors pressed against a wall by routing up to the closest
			# clear square on their side, even if their feet enter the nav margin.
			if distance < best_distance and _clear_segment(point, pos, _solid_footprints):
				closest = cell
				best_distance = distance
	return closest

func route(start: Vector2, goal: Vector2) -> PackedVector2Array:
	if _can_walk_segment(start, goal):
		return PackedVector2Array([goal])
	var path := PackedVector2Array()
	var first := _nearest_cell(start)
	var last := _nearest_cell(goal)
	if first.x < 0 or last.x < 0:
		return path
	var grid_path := _grid.get_point_path(first, last)
	if grid_path.is_empty():
		return path
	# Skip intermediate squares while the actor has full clearance to a later point.
	var anchor := start
	for index in range(1, grid_path.size()):
		if not _can_walk_segment(anchor, grid_path[index]):
			anchor = grid_path[index - 1]
			path.append(anchor)
	path.append(grid_path[-1])
	if _can_walk_segment(grid_path[-1], goal):
		path.append(goal)
	return path
