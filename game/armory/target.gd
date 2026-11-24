extends StaticBody2D
signal struck(damage: int)
const Feedback = preload("res://combat/feedback.gd")
func receive_hit(_source: Node2D, _attack_id: int, damage: int, _kind: StringName, direction: Vector2) -> StringName:
	struck.emit(damage)
	var view := get_node("Paint") as Sprite2D
	var impact := create_tween()
	impact.tween_property(view,"position",direction*3,0.045)
	impact.tween_property(view,"position",Vector2.ZERO,0.12)
	Feedback.play(self,&"blade_hit",global_position+Vector2(0,-68),global_position+Vector2(0,-68))
	return &"hit"
