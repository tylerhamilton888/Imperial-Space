extends CharacterBody2D

signal died
signal crossfire_hit

const Profile = preload("res://actors/enemies/enemy_profile.gd")
const Vitality = preload("res://combat/vitality.gd")
const Query = preload("res://combat/combat_query.gd")
const Feedback = preload("res://combat/feedback.gd")
const Fragment = preload("res://combat/impact_fragment.gd")
const Routes = preload("res://actors/enemies/ground_routes.gd")
const View = preload("res://art/actor_view.gd")
const DUMMY: Profile = preload("res://actors/enemies/dummy.tres")
const RAIDER: Profile = preload("res://actors/enemies/raider.tres")
const GUNNER: Profile = preload("res://actors/enemies/gunner.tres")
const SENSE_INTERVAL := 0.12
const REPATH_INTERVAL := 0.28
const STAGGER_TIME := 0.37
const PARRY_STAGGER := 0.88
const DEATH_TIME := 0.32
const SPOT_MEMORY := 4.0
const HALF_SWEEP := 0.86
const ANKLE_TO_CHEST := Vector2(0, -45)
const GUN_WARNING := Color("#ff9764")
const BLADE_WARNING := Color("#ffe29b")

@export var role: StringName = &"raider"
@export var passive := false
@onready var _view: View = $View
var profile: Profile
var vitality: Vitality
var health: int:
	get: return vitality.health if vitality != null else 0
var max_health: int:
	get: return vitality.max_health if vitality != null else 0
var state: StringName = &"idle"
var facing := Vector2.DOWN
var _target: Node2D
var _navigation: Routes
var _can_see := false
var _last_known := Vector2.ZERO
var _memory := 0.0
var _sense_delay := 0.0
var _path_delay := 0.0
var _waypoints := PackedVector2Array()
var _elapsed := 0.0
var _duration := 0.0
var _strike_direction := Vector2.DOWN
var _telegraph_length := 0.0
var _attack_id := 0
var _flash := 0.0
var _impulse := Vector2.ZERO
var _impact_hold := 0.0
var _exposed := false
var _blade_cued := false
var _fall_direction := Vector2.ZERO
var _fall_started := false
var _sever_arm := false
var _last_grip := Transform2D.IDENTITY

func _ready() -> void:
	match role:
		&"raider": profile = RAIDER
		&"gunner": profile = GUNNER
		_: profile = DUMMY
	vitality = Vitality.new(profile.health)
	# Spread sight checks across physics ticks without consuming scenario RNG.
	_sense_delay = float(posmod(roundi(position.x + 3.0 * position.y), 7)) / 60.0
	_view.role = role
	add_to_group(&"enemies")
	if role != &"dummy":
		add_to_group(&"combatants")
	_update_art()

func _physics_process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta * 4.0)
	velocity = Vector2.ZERO
	if _impact_hold > 0.0:
		_impact_hold -= delta
		_update_art()
		return
	# Resolve displacement against arena solids, including jambs and cover.
	if state == &"dead" and not _fall_started and not _fall_direction.is_zero_approx():
		Fragment.fall_raider(get_parent(),global_position,facing,_fall_direction,_sever_arm,_last_grip,_view.scale.x)
		_view.hide()
		_fall_started = true
		_impulse = Vector2.ZERO
	if _impulse.length_squared() > 4.0:
		move_and_collide(_impulse * delta)
		_impulse = _impulse.move_toward(Vector2.ZERO, 1050.0 * delta)
	_elapsed += delta
	if state == &"dead":
		if _elapsed >= _duration:
			if not _fall_started:
				_view.leave_fallen_pose(get_parent(), global_position)
			queue_free()
	elif role != &"dummy" and not passive:
		_behavior(delta)
	elif state != &"idle":
		_change_state(&"idle")
	_update_art()

func _behavior(delta: float) -> void:
	if not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group(&"player") as Node2D
	if _target == null or _target.get("health") <= 0:
		_change_state(&"idle")
		_can_see = false
		_memory = 0.0
		return
	match state:
		&"windup":
			if role == &"raider" and not _blade_cued and _duration - _elapsed <= 0.20:
				_blade_cued = true
				var blade := global_position + _view.transform * _view.cleaver_transform() * Vector2(27,1)
				Feedback.play(self, &"blade_cue", blade, blade)
			if _elapsed >= _duration:
				_resolve_strike()
		&"recover", &"stagger":
			if _elapsed >= _duration:
				_change_state(&"idle")
				_sense_delay = 0.0
		_:
			_search_or_engage(delta)

func _search_or_engage(delta: float) -> void:
	_sense_delay -= delta
	_memory = maxf(_memory - delta, 0.0)
	if _sense_delay <= 0.0:
		_sense_delay = SENSE_INTERVAL
		var near := global_position.distance_squared_to(_target.global_position) <= profile.sight_range * profile.sight_range
		_can_see = near and _clear_sight(_target.global_position)
		if _can_see:
			_last_known = _target.global_position
			_memory = SPOT_MEMORY
	if _memory <= 0.0:
		_change_state(&"idle")
		return
	var toward := _last_known - global_position
	if _can_see and toward.length() <= profile.engage_range:
		if role == &"gunner":
			var lane := Query.first_hit(self, global_position, _target.global_position, 1 | 2 | 4)
			var blocker := lane.get("collider") as Node2D
			if blocker != null and blocker.is_in_group(&"enemies"):
				# Seek a clean shot before committing; a locked shot can be baited.
				var side := toward.normalized().orthogonal()
				if test_move(global_transform, side * 24.0):
					side = -side
				velocity = side * profile.move_speed * 0.65
				move_and_slide()
				facing = toward.normalized()
				_change_state(&"approach")
				return
		_strike_direction = toward.normalized() if not toward.is_zero_approx() else facing
		facing = _strike_direction
		_attack_id += 1
		_telegraph_length = toward.length()
		_change_state(&"windup", profile.windup)
		return
	if toward.length_squared() < 36.0:
		_change_state(&"idle")
		return
	_path_delay -= delta
	if _path_delay <= 0.0:
		_path_delay = REPATH_INTERVAL
		if not is_instance_valid(_navigation):
			_navigation = get_tree().get_first_node_in_group(&"combat_navigation") as Routes
		if _navigation != null:
			_waypoints = _navigation.route(global_position, _last_known)
		else:
			_waypoints = PackedVector2Array([_last_known])
	while not _waypoints.is_empty() and global_position.distance_squared_to(_waypoints[0]) < 25.0:
		_waypoints.remove_at(0)
	if not _waypoints.is_empty():
		facing = global_position.direction_to(_waypoints[0])
		velocity = facing * profile.move_speed
		move_and_slide()
		_change_state(&"approach")
	else:
		_change_state(&"idle")

func _clear_sight(point: Vector2) -> bool:
	return Query.first_hit(self, global_position, point, 1).is_empty()

func _resolve_strike() -> void:
	_change_state(&"recover", profile.recovery)
	if role == &"gunner":
		var end := global_position + _strike_direction * profile.attack_reach
		var hit := Query.first_hit(self, global_position, end, 1 | 2 | 4)
		var visible_end := end + ANKLE_TO_CHEST
		if not hit.is_empty():
			end = hit["position"]
			visible_end = end + ANKLE_TO_CHEST
			var collider := hit["collider"] as Node2D
			if collider == _target:
				_target.call(&"receive_hit", self, _attack_id, profile.damage, &"bullet", _strike_direction)
			elif collider != null and collider.has_method(&"receive_hit_at"):
				visible_end = collider.call(&"impact_surface",end)
				collider.call(&"receive_hit_at",self,_attack_id,profile.damage,&"bullet",_strike_direction,end)
			elif collider != null and collider.is_in_group(&"combatants"):
				var result: StringName = collider.call(&"receive_hit", self, _attack_id, profile.damage, &"crossfire", _strike_direction)
				if result in [&"hit", &"killed"]:
					crossfire_hit.emit()
		Feedback.play(self, &"enemy_shot", global_position + _view.muzzle_offset(), visible_end)
	else:
		var offset := _target.global_position - global_position
		var start := global_position + ANKLE_TO_CHEST * _view.scale
		Feedback.play(self, &"enemy_swing", start, start + _strike_direction * 35.0)
		if offset.length() <= profile.attack_reach and absf(_strike_direction.angle_to(offset)) <= HALF_SWEEP and _clear_sight(_target.global_position):
			var outcome: StringName = _target.call(&"receive_hit", self, _attack_id, profile.damage, &"melee", offset.normalized())
			if outcome == &"parried":
				_exposed = true
				_impulse = -_strike_direction * 116.0
				_view.kick(-_strike_direction, 9.0)
				_change_state(&"stagger", PARRY_STAGGER)

func receive_hit(source: Node2D, attack_id: int, damage: int, kind: StringName, incoming: Vector2) -> StringName:
	var result := vitality.apply(source, attack_id, damage)
	if result != &"hit" and result != &"killed":
		return result
	_flash = 1.0
	var contact := global_position + ANKLE_TO_CHEST * _view.scale
	var impact := &"bullet_hit"
	var push := 60.0
	match kind:
		&"riposte", &"counter_shot":
			impact = &"counter_hit"
			push = 208.0
		&"melee", &"return_cut":
			impact = &"blade_hit"
			push = 148.0 if kind == &"return_cut" else 110.0
	Feedback.play(self, impact, contact, contact + incoming.normalized())
	if role != &"dummy":
		_impulse = incoming.normalized() * push
		_view.kick(incoming, push / 17.0)
		_impact_hold = 0.065 if impact == &"counter_hit" else 0.028
	if result == &"killed":
		set_deferred(&"collision_layer", 0)
		set_deferred(&"collision_mask", 1)
		if role == &"raider":
			_last_grip = _view.transform * _view.cleaver_transform()
			_sever_arm = kind in [&"melee", &"return_cut", &"riposte"]
			_fall_direction = incoming.normalized() if not incoming.is_zero_approx() else facing
		_change_state(&"dead", DEATH_TIME)
		remove_from_group(&"enemies")
		died.emit()
	elif role != &"dummy" and kind in [&"melee", &"return_cut", &"riposte", &"counter_shot", &"crossfire"]:
		_exposed = false
		_elapsed = 0.0
		_duration = STAGGER_TIME
		_change_state(&"stagger", STAGGER_TIME)
	_update_art()
	return result

func _change_state(next: StringName, duration := 0.0) -> void:
	if state == next:
		return
	if next == &"windup":
		_blade_cued = false
	if next != &"stagger":
		_exposed = false
	state = next
	_elapsed = 0.0
	_duration = duration

func _update_art() -> void:
	if role == &"raider" and state == &"dead":
		# Hold the actual hit silhouette briefly. Returning to an idle sword
		# pose here makes the victim appear to pivot on the player's blade.
		_view.travel = 0.0
		queue_redraw()
		return
	var phase := clampf(_elapsed / _duration, 0.0, 1.0) if _duration > 0.0 else 0.0
	_view.facing = facing
	_view.travel = clampf(velocity.length() / maxf(1.0, profile.move_speed), 0.0, 1.0)
	_view.phase = phase
	_view.feedback = _flash
	match state:
		&"approach":
			_view.action = &"walk"
		&"windup":
			_view.action = &"windup"
			if role == &"raider":
				# The blade crosses the defender at the timeout, midway through
				# its illustrated sweep. The arc ends on that same physics tick.
				_view.phase = minf(1.0, phase / 0.72)
				if phase >= 0.72:
					_view.action = &"melee"
					_view.phase = 0.5 * (phase - 0.72) / 0.28
		&"recover":
			if _elapsed >= 0.24:
				_view.action = &"idle"
			elif role == &"gunner":
				_view.action = &"fire"
			else:
				_view.action = &"melee"
				_view.phase = lerpf(0.5, 1.0, _elapsed / 0.24)
		_:
			_view.action = state
	if state == &"dead" and _elapsed < 0.10 and role != &"dummy":
		_view.action = &"stagger"
	_view.queue_redraw()
	queue_redraw()

func get_aim_bounds() -> Rect2:
	return Rect2(profile.aim_bounds.position * _view.scale, profile.aim_bounds.size * _view.scale)

func _draw() -> void:
	if vitality == null or state == &"dead":
		return
	if health < max_health or role == &"dummy":
		var height := get_aim_bounds().position.y - 7.0
		draw_rect(Rect2(-21,height,42,4), Color("#17212b"))
		draw_rect(Rect2(-20,height+1,40.0*health/max_health,2), Color("#dfaf70") if role == &"dummy" else Color("#f08064"))
	if _exposed:
		var tip := Vector2(0, get_aim_bounds().position.y - 17.0)
		draw_polyline(PackedVector2Array([tip + Vector2(-7,-5), tip + Vector2(0,2), tip + Vector2(7,-5)]), Color("#ffe7a1"), 2.5, true)
	if state != &"windup":
		return
	var phase := clampf(_elapsed / _duration, 0, 1)
	if role == &"gunner":
		var muzzle := _view.muzzle_offset()
		var endpoint := _strike_direction * maxf(60, _telegraph_length) + ANKLE_TO_CHEST
		draw_dashed_line(muzzle, endpoint, Color(GUN_WARNING, 0.46 + 0.42 * phase), 1.4 + phase, 9.0, true)
		draw_circle(muzzle, 3.2 + phase * 2.3, Color(GUN_WARNING, 0.85), true, -1.0, true)
	else:
		if _duration - _elapsed <= 0.145:
			var glint := _view.transform * _view.cleaver_transform() * Vector2(27,1)
			var size := 5.0 + 4.0 * sin(PI * clampf((_duration - _elapsed) / 0.145, 0, 1))
			draw_colored_polygon(PackedVector2Array([glint + Vector2(0,-size), glint + Vector2(3,0), glint + Vector2(0,size), glint + Vector2(-3,0)]), Color("#fff3ba"))
		var start := facing.angle() - HALF_SWEEP
		var finish := facing.angle() + HALF_SWEEP
		var edge := profile.attack_reach
		draw_arc(Vector2.ZERO, edge, start, finish, 22, Color(BLADE_WARNING, 0.35), 1.5, true)
		draw_arc(Vector2.ZERO, edge, start, lerpf(start, finish, maxf(0.005, phase)), 22, BLADE_WARNING, 2.7, true)
