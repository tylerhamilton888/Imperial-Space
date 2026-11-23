extends StaticBody2D
## A reusable range target rings and tips on its carriage when struck.
const Feedback = preload("res://combat/feedback.gd")
var hits := 0
var last_attack := -1
var last_source := 0
var recoil := 0.0

func _ready() -> void:
	add_to_group("aim_fixtures")
	set_process(false)

func get_aim_bounds() -> Rect2:
	return Rect2(-13, -69, 32, 60)

func receive_hit(source: Node2D, serial: int, _amount: int, _kind: StringName, _direction: Vector2) -> StringName:
	if serial == last_attack and source.get_instance_id() == last_source:
		return &"duplicate"
	last_attack = serial
	last_source = source.get_instance_id()
	hits += 1
	recoil = 1.0
	set_process(true)
	var center := global_position + Vector2(3,-43)
	Feedback.play(self, &"parried", center, center)
	return &"hit"

func _process(delta: float) -> void:
	recoil = maxf(0.0, recoil - delta * 3.5)
	$Painting/Art.rotation = sin(recoil * TAU) * recoil * 0.09
	$Painting/Art.modulate = Color.WHITE.lerp(Color(1.6,1.45,1.1), recoil)
	set_process(recoil > 0.0)
