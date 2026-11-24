extends CharacterBody2D
signal boarded
const SHEET = preload("res://transit/court/travelers.webp")
@export_range(0,1) var appearance := 0
var route := PackedVector2Array()
var distance_walked := 0.0
var step := 0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CircleShape2D.new()
	shape.radius = 5
	var foot := CollisionShape2D.new()
	foot.shape = shape
	add_child(foot)

func release(waypoint: Vector2, door: Vector2) -> void:
	route = PackedVector2Array([waypoint,door])

func wait_here() -> void:
	route.clear()
	velocity = Vector2.ZERO
	step = 0
	queue_redraw()

func _physics_process(delta: float) -> void:
	if route.is_empty(): return
	var offset := route[0] - global_position
	velocity = offset.limit_length(109.0*delta)/delta
	move_and_slide()
	distance_walked += get_position_delta().length()
	step = 1 + floori(distance_walked/15.0)%2
	queue_redraw()
	if global_position.distance_to(route[0]) < 2:
		route.remove_at(0)
		if route.is_empty():
			hide()
			set_physics_process(false)
			boarded.emit()

func _draw() -> void:
	draw_set_transform(Vector2(2,0),0,Vector2(13,4))
	draw_circle(Vector2.ZERO,1,Color(.07,.09,.11,.26),true,-1,true)
	draw_set_transform(Vector2.ZERO)
	draw_texture_rect_region(SHEET,Rect2(-40,-80,80,90),Rect2(step*80,appearance*90,80,90))
