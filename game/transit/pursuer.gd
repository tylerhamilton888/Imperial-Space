extends "res://actors/enemies/enemy.gd"
var operator: Node2D
var knight: Node2D
var provoked := 0.0
var retreating := false
var entry := Vector2.ZERO

func _behavior(delta: float) -> void:
	if retreating:
		if position.distance_to(entry) < 7.0:
			queue_free()
			return
		facing = position.direction_to(entry)
		velocity = facing * profile.move_speed
		move_and_slide()
		_change_state(&"approach")
		return
	provoked = maxf(0,provoked-delta)
	# Honor committed blows. A Knight who intercepts or wounds a raider
	# can pull its attention away from the exposed switch operator.
	if state not in [&"windup",&"recover",&"stagger"]:
		var desired := knight if provoked > 0 or position.distance_to(knight.position)<115 else operator
		if _target != desired:
			_target = desired
			_sense_delay = 0
			_path_delay = 0
	# The raiders know the location of the switch even when boarding rails
	# break their line of sight. The ordinary strike still requires sight.
	if _target == operator:
		_last_known = operator.position
		_memory = SPOT_MEMORY
	super._behavior(delta)

func receive_hit(source: Node2D, attack_id: int, damage: int, kind: StringName, incoming: Vector2) -> StringName:
	var result := super.receive_hit(source,attack_id,damage,kind,incoming)
	if result == &"hit" and source == knight:
		provoked = 2.4
	return result
