extends RefCounted
## All queries take ground-plane points. Drawing a raised muzzle never moves the
## collision origin beyond a thin section of cover.

static func first_hit(shooter: CollisionObject2D, from: Vector2, to: Vector2, mask: int) -> Dictionary:
	if from.is_equal_approx(to):
		return {}
	var query := PhysicsRayQueryParameters2D.create(from, to, mask, [shooter.get_rid()])
	query.hit_from_inside = true
	return shooter.get_world_2d().direct_space_state.intersect_ray(query)

static func melee_targets(attacker: CollisionObject2D, aim: Vector2, reach: float, half_angle: float, target_mask: int) -> Array[Node2D]:
	var disk := CircleShape2D.new()
	disk.radius = reach
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = disk
	query.transform.origin = attacker.global_position
	query.collision_mask = target_mask
	var contacts := attacker.get_world_2d().direct_space_state.intersect_shape(query, 32)
	var targets: Array[Node2D] = []
	for entry: Dictionary in contacts:
		var target := entry.collider as Node2D
		if target == null or not target.has_method("receive_hit"):
			continue
		var direction := attacker.global_position.direction_to(target.global_position)
		if not direction.is_zero_approx() and aim.dot(direction) < cos(half_angle):
			continue
		if first_hit(attacker, attacker.global_position, target.global_position, 1).is_empty():
			targets.append(target)
	return targets
