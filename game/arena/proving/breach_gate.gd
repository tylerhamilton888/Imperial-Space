extends StaticBody2D
## The center shutter is a damageable ground body. Its two masonry jambs are
## separate permanent solids, so opening it releases the aperture alone.
signal opened
signal integrity_changed

const Vitality = preload("res://combat/vitality.gd")
const Feedback = preload("res://combat/feedback.gd")
const INTACT = preload("res://art/proving/wall_intact.webp")
const BROKEN = preload("res://art/proving/wall_breached.webp")
const CAPACITY := 96
var vitality := Vitality.new(CAPACITY)
var is_open := false
var burst_age := -1.0
var impact_left := 0.0

func _ready() -> void:
	add_to_group("aim_fixtures")
	set_process(false)
	queue_redraw()

func get_aim_bounds() -> Rect2:
	return Rect2(-43, -111, 80, 102)

func receive_hit(source: Node2D, attack_id: int, amount: int, _kind: StringName, _direction: Vector2) -> StringName:
	var result := vitality.apply(source, attack_id, amount)
	if result != &"hit" and result != &"killed":
		return result
	impact_left = 0.13
	set_process(true)
	Feedback.play(self, &"hit", global_position + Vector2(0,-55), global_position + Vector2(0,-55))
	if result == &"killed":
		is_open = true
		collision_layer = 0
		remove_from_group("aim_fixtures")
		burst_age = 0.0
		opened.emit()
	integrity_changed.emit()
	queue_redraw()
	return result

func _process(delta: float) -> void:
	impact_left = maxf(0, impact_left - delta)
	if is_open:
		burst_age += delta
	queue_redraw()
	set_process(impact_left > 0 or (is_open and burst_age < 0.65))

func _draw() -> void:
	var tint := Color.WHITE.lerp(Color(1.6,1.4,1.1), impact_left / 0.13)
	draw_texture(BROKEN if is_open else INTACT, Vector2(-108,-151), tint)
	if not is_open:
		var bar := Rect2(-25, -162, 50, 5)
		draw_rect(bar.grow(2), Color("#282119"))
		bar.size.x *= float(vitality.health) / CAPACITY
		draw_rect(bar, Color("#f5bd56"))
	elif burst_age < 0.65:
		var t := burst_age / 0.65
		for i in 12:
			var start := Vector2(-32 + (i%4)*18, -90 + (i/4)*24)
			var velocity := Vector2(sin(i*2.6)*48, -35 - (i%3)*17)
			var pos := start + velocity * t + Vector2(0, 124*t*t)
			draw_rect(Rect2(pos, Vector2(5+i%3, 4)), Color(0.53, 0.44, 0.33, 1.0-t))
