extends CharacterBody2D

signal stats_changed
signal died
signal combat_event(kind: StringName, from: Vector2, to: Vector2)

const Vitality = preload("res://combat/vitality.gd")
const Query = preload("res://combat/combat_query.gd")
const Feedback = preload("res://combat/feedback.gd")
const KIT = preload("res://data/medium_kit.tres")
const TORSO := Vector2(0, -46)
# The painted seven-key swing extends the blade in keys 3 through 5.
const STRIKE_FIRST := 3.0 / 7.0
const STRIKE_RECOVERY := 6.0 / 7.0
const PLAYER_ACTIONS: Array[StringName] = [&"dodge", &"guard", &"melee", &"fire", &"reload", &"heal"]

var melee_profile := KIT
var melee_contact_offset := TORSO
var _vitals := Vitality.new(KIT.max_health)
var health: int:
	get: return _vitals.health
var max_health: int:
	get: return _vitals.max_health
var magazine: int = KIT.mag_size
var reserve: int = KIT.reserve_size
var med_charges: int = KIT.med_charges
var aim_direction := Vector2.RIGHT
var action: StringName = &"idle"
var action_time := 0.0
var guard_toggle := false:
	set(value):
		if guard_toggle != value:
			cancel_input()
		guard_toggle = value
var input_enabled := true:
	set(value):
		input_enabled = value
		if not value:
			cancel_input()

# A parry belongs to the attacker whose weapon was turned. The first attack
# spends the opportunity, even if it misses or hits cover.
var opening: Node2D
var opening_left := 0.0
var _counter_target: Node2D
var _return_cut := false
var _followup_left := 0.0
var _contact_hold := 0.0
var _trail_drawn := false
var _step_distance := 0.0
var _aim_locked := Vector2.RIGHT
var _dodge_direction := Vector2.RIGHT
var _attack_id := 0
var _shot_fired := false
var _sword_contacts: Dictionary[int, bool] = {}
var _fire_held := false
var _guard_held := false
var _guard_armed := false
var _parry_cooldown := 0.0
var _parry_pose_left := 0.0
var _buffered: StringName = &""
var _buffer_left := 0.0

func _ready() -> void:
	add_to_group(&"player")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		cancel_input()

func _input(event: InputEvent) -> void:
	# Release even when the pointer crosses a panel or a button consumes the event.
	if event.is_action_released(&"fire"):
		_fire_held = false
	if event.is_action_released(&"guard") and not guard_toggle:
		_guard_held = false
		if action == &"guard":
			_set_action(&"idle")

func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled or health == 0 or get_tree().paused:
		return
	for id in PLAYER_ACTIONS:
		if event.is_action_pressed(id):
			if id == &"fire":
				_fire_held = true
			elif id == &"guard":
				if guard_toggle and _guard_held:
					_guard_held = false
					if action == &"guard":
						_set_action(&"idle")
					get_viewport().set_input_as_handled()
					return
				_guard_held = true
			if event is InputEventMouseButton:
				_update_aim_at(get_canvas_transform().affine_inverse() * event.position)
			request_action(id)
			get_viewport().set_input_as_handled()
			return

func cancel_input() -> void:
	_fire_held = false
	_guard_held = false
	_buffered = &""
	_buffer_left = 0
	if action == &"guard":
		_set_action(&"idle")

func refill() -> void:
	cancel_input()
	_vitals.refill()
	magazine = KIT.mag_size
	reserve = KIT.reserve_size
	med_charges = KIT.med_charges
	_parry_cooldown = 0
	_parry_pose_left = 0.0
	_guard_armed = false
	_sword_contacts.clear()
	opening = null
	opening_left = 0.0
	_counter_target = null
	_followup_left = 0.0
	_contact_hold = 0.0
	_return_cut = false
	$Visual.sword_readied = false
	_step_distance = 0.0
	velocity = Vector2.ZERO
	_set_action(&"idle")
	stats_changed.emit()

func _physics_process(delta: float) -> void:
	if health == 0:
		_update_view(delta)
		return
	if opening_left > 0.0:
		opening_left = maxf(0.0, opening_left - delta)
		if opening_left == 0.0 or not is_instance_valid(opening):
			opening = null
	_followup_left = maxf(0.0, _followup_left - delta)
	if _contact_hold > 0.0:
		_contact_hold -= delta
		_update_view(0.0)
		return
	var movement := Vector2.ZERO
	if input_enabled:
		movement = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
		_update_aim_at(get_global_mouse_position())
	_parry_cooldown = maxf(0, _parry_cooldown - delta)
	_parry_pose_left = maxf(0, _parry_pose_left - delta)
	if action == &"idle":
		if _buffered != &"":
			var pending := _buffered
			_buffered = &""
			_begin_action(pending)
		if action == &"idle" and _guard_held:
			_begin_guard(false)
		elif action == &"idle" and _fire_held and get_viewport().gui_get_hovered_control() == null:
			_begin_action(&"fire")
	_buffer_left -= delta
	if _buffer_left <= 0:
		_buffered = &""
	action_time += delta
	var speed: float = KIT.move_speed
	match action:
		&"dodge":
			if action_time <= KIT.dodge_move_time:
				movement = _dodge_direction
				speed = KIT.dodge_speed
			else:
				speed *= 0.43
		&"guard":
			speed *= 0.52
		&"melee":
			speed *= 0.42
		&"reload", &"heal":
			speed *= 0.75
	velocity = movement * speed
	if action == &"melee" and action_time >= melee_profile.sword_contact_start - 0.055 and action_time < melee_profile.sword_contact_end:
		var drive := 72.0
		if _return_cut:
			drive = 115.0
		if is_instance_valid(_counter_target):
			drive = 178.0
		velocity += _aim_locked * drive
	move_and_slide()
	if movement.length_squared() > 0.01 and action in [&"idle", &"fire", &"guard"]:
		_step_distance += get_position_delta().length()
		if _step_distance >= 49.0:
			_step_distance = fmod(_step_distance, 49.0)
			Feedback.play(self, &"step", global_position, global_position)
	_advance_action()
	_update_view(delta)

func _update_aim_at(cursor: Vector2) -> void:
	var target_point := cursor - TORSO
	# Resolve clicks anywhere on an upright silhouette onto its ground position.
	# The closest torso wins when figures overlap. Cover is still queried at contact.
	var closest := INF
	var candidates := get_tree().get_nodes_in_group(&"enemies")
	candidates.append_array(get_tree().get_nodes_in_group(&"aim_fixtures"))
	for member in candidates:
		var actor := member as Node2D
		if actor == null or actor.is_queued_for_deletion():
			continue
		var local := cursor - actor.global_position
		var bounds := Rect2(-18.0, -78.0, 36.0, 82.0)
		if actor.has_method(&"get_aim_bounds"):
			bounds = actor.call(&"get_aim_bounds")
		var torso_distance := local.distance_squared_to(bounds.get_center())
		if bounds.has_point(local) and torso_distance < closest:
			closest = torso_distance
			target_point = actor.global_position
			if actor.is_in_group("aim_fixtures"):
				target_point.x += local.x
	var direction := global_position.direction_to(target_point)
	if not direction.is_zero_approx():
		aim_direction = direction

func request_action(id: StringName) -> bool:
	if health == 0 or not id in PLAYER_ACTIONS:
		return false
	if action == &"guard" and (id == &"dodge" or (id in [&"melee", &"fire"] and has_opening())):
		_set_action(&"idle")
	if action == &"idle":
		return _begin_action(id)
	if id != &"guard":
		_buffered = id
		_buffer_left = KIT.buffer_time
		# A second, deliberate press on contact carries through recovery.
		# Keep one request only; holding the button never strings attacks.
		if id == &"melee" and action == &"melee" and _followup_left > 0.0 and not _return_cut:
			_buffer_left = maxf(_buffer_left, _duration() - action_time + 0.06)
	return false

func has_opening() -> bool:
	return opening_left > 0.0 and is_instance_valid(opening) and opening.is_inside_tree()

func _begin_action(id: StringName) -> bool:
	match id:
		&"guard":
			_begin_guard(true)
			return true
		&"fire":
			if magazine == 0:
				return _begin_action(&"reload")
			_shot_fired = false
		&"melee":
			_sword_contacts.clear()
			_return_cut = _followup_left > 0.0 and not has_opening()
			_followup_left = 0.0
			_trail_drawn = false
			_feedback(&"melee", global_position + TORSO, global_position + TORSO)
		&"reload":
			if magazine == KIT.mag_size or reserve <= 0:
				return false
			_feedback(&"reload", global_position, global_position)
		&"heal":
			if med_charges <= 0 or health == max_health:
				return false
		&"dodge":
			var move_input := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down") if input_enabled else Vector2.ZERO
			_dodge_direction = aim_direction if move_input.is_zero_approx() else move_input.normalized()
			_feedback(&"dodge", global_position, global_position)
		_:
			return false
	_aim_locked = aim_direction
	if id == &"fire" or id == &"melee":
		_attack_id += 1
		_counter_target = opening if has_opening() else null
		opening = null
		opening_left = 0.0
		if id == &"fire":
			_followup_left = 0.0
	_set_action(id)
	return true

func _begin_guard(fresh_press: bool) -> void:
	_guard_armed = fresh_press and _parry_cooldown <= 0
	if _guard_armed:
		_parry_cooldown = KIT.parry_rearm
	_set_action(&"guard")

func _set_action(id: StringName) -> void:
	if id in [&"melee",&"guard"]:
		$Visual.sword_readied = true
	elif id in [&"fire",&"reload"]:
		$Visual.sword_readied = false
	action = id
	action_time = 0.0

func _advance_action() -> void:
	match action:
		&"fire":
			if not _shot_fired:
				_shot_fired = true
				_fire_rifle()
		&"melee":
			if action_time >= melee_profile.sword_contact_start and action_time <= melee_profile.sword_contact_end:
				if not _trail_drawn:
					_trail_drawn = true
					var stroke := &"return_arc" if _return_cut else &"sword_arc"
					if is_instance_valid(_counter_target):
						stroke = &"riposte_arc"
					Feedback.play(self, stroke, global_position + melee_contact_offset, global_position + melee_contact_offset + _aim_locked)
				_sword_contact()
	if action_time < _duration():
		return
	match action:
		&"reload":
			var transfer := mini(KIT.mag_size - magazine, reserve)
			magazine += transfer
			reserve -= transfer
			stats_changed.emit()
		&"heal":
			med_charges -= 1
			_vitals.heal(KIT.med_restore)
			stats_changed.emit()
			_feedback(&"heal", global_position, global_position)
	_set_action(&"idle")

func _duration() -> float:
	match action:
		&"fire": return KIT.shot_interval
		&"melee": return melee_profile.sword_total
		&"reload": return KIT.reload_time
		&"heal": return KIT.heal_time
		&"dodge": return KIT.dodge_total
		_: return INF

func _fire_rifle() -> void:
	magazine -= 1
	stats_changed.emit()
	var endpoint := global_position + _aim_locked * float(KIT.rifle_range)
	var hit := Query.first_hit(self, global_position, endpoint, 1 | 4)
	var struck_actor := false
	var visible_end := endpoint + TORSO
	if not hit.is_empty():
		endpoint = hit.position
		visible_end = endpoint + TORSO
		var body := hit.collider as Node2D
		if body != null and body.has_method(&"receive_hit"):
			var counter := is_instance_valid(_counter_target) and body == _counter_target
			var damage: int = KIT.counter_shot_damage if counter else KIT.rifle_damage
			var kind := &"counter_shot" if counter else &"bullet"
			var result: Variant
			if body.has_method(&"receive_hit_at"):
				visible_end = body.call(&"impact_surface", endpoint)
				result = body.call(&"receive_hit_at", self, _attack_id, damage, kind, _aim_locked, endpoint)
			else:
				result = body.call(&"receive_hit", self, _attack_id, damage, kind, _aim_locked)
			if counter and result in [&"hit", &"killed"]:
				combat_event.emit(&"counter_shot", global_position, endpoint)
			struck_actor = true
	$Visual.kick(-_aim_locked, 3.7)
	_update_view(0.0)
	var muzzle: Vector2 = global_position + $Visual.muzzle_offset()
	# If cover is closer than the drawn barrel, flash against its near face.
	if (visible_end - muzzle).dot(_aim_locked) < 0:
		muzzle = global_position + TORSO
	_feedback(&"fire", muzzle, visible_end)
	if not hit.is_empty() and not struck_actor:
		_feedback(&"hit", visible_end, visible_end)

func _sword_contact() -> void:
	var targets := Query.melee_targets(self, _aim_locked, melee_profile.sword_reach, deg_to_rad(melee_profile.sword_half_angle_degrees), 4)
	for target in targets:
		var id := target.get_instance_id()
		if _sword_contacts.has(id):
			continue
		_sword_contacts[id] = true
		var direction := global_position.direction_to(target.global_position)
		var counter := is_instance_valid(_counter_target) and target == _counter_target
		var kind := &"melee"
		var damage: int = melee_profile.sword_damage
		if counter:
			kind = &"riposte"
			damage = melee_profile.riposte_damage
		elif _return_cut:
			kind = &"return_cut"
			damage = melee_profile.return_cut_damage
		var result: Variant = target.call(&"receive_hit", self, _attack_id, damage, kind, direction)
		if result not in [&"hit", &"killed"] or not target.is_in_group(&"combatants"):
			continue
		_contact_hold = 0.065 if counter else 0.035
		$Visual.kick(_aim_locked, 3.5 if counter else 1.8)
		if kind == &"melee":
			_followup_left = 0.68
		combat_event.emit(kind if kind != &"melee" else &"cut_landed", global_position, target.global_position)

func receive_hit(source: Node2D, attack_id: int, damage: int, kind: StringName, incoming: Vector2) -> StringName:
	var outcome: StringName = &"hit"
	var defended_damage := damage
	if action == &"dodge" and action_time < KIT.dodge_invulnerability:
		outcome = &"evaded"
	elif action == &"guard" and aim_direction.dot(-incoming.normalized()) >= cos(deg_to_rad(KIT.guard_arc_half_degrees)):
		if kind == &"melee" and _guard_armed and action_time <= KIT.parry_window:
			outcome = &"parried"
		else:
			outcome = &"guarded"
			defended_damage = ceili(damage * float(KIT.guard_damage_fraction))
	outcome = _vitals.apply(source, attack_id, defended_damage, outcome)
	if outcome in [&"ignored", &"duplicate", &"evaded"]:
		return outcome
	if outcome == &"parried":
		_guard_armed = false
		_parry_pose_left = KIT.parry_window
		opening = source
		opening_left = KIT.counter_window
		$Visual.kick(incoming, 4.0)
	$Visual.feedback = 1.0
	_feedback(outcome, global_position + TORSO, global_position + TORSO)
	stats_changed.emit()
	if outcome == &"killed":
		cancel_input()
		velocity = Vector2.ZERO
		_set_action(&"dead")
		died.emit()
	return outcome

func _feedback(kind: StringName, start: Vector2, end: Vector2) -> void:
	Feedback.play(self, kind, start, end)
	combat_event.emit(kind, start, end)

func _update_view(delta: float) -> void:
	var facing := _aim_locked if action in [&"melee", &"fire"] else aim_direction
	var phase := clampf(action_time / _duration(), 0, 1)
	if action == &"melee":
		if action_time < melee_profile.sword_contact_start:
			phase = remap(action_time, 0.0, melee_profile.sword_contact_start, 0.0, STRIKE_FIRST)
		elif action_time < melee_profile.sword_contact_end:
			phase = remap(action_time, melee_profile.sword_contact_start, melee_profile.sword_contact_end, STRIKE_FIRST, STRIKE_RECOVERY)
		else:
			phase = remap(action_time, melee_profile.sword_contact_end, melee_profile.sword_total, STRIKE_RECOVERY, 1.0)
	var pose := &"parry" if action == &"guard" and _parry_pose_left > 0 else action
	# The return cut travels back across the silhouette. Contact still falls
	# inside the painted extension keys in either direction.
	$Visual.return_stroke = action == &"melee" and _return_cut
	if $Visual.return_stroke and posmod(roundi(facing.angle()/(TAU/8)),8) in [2,6]:
		if phase < STRIKE_FIRST:
			phase = lerpf(0.99, 0.85, phase / STRIKE_FIRST)
		elif phase < STRIKE_RECOVERY:
			phase = remap(phase, STRIKE_FIRST, STRIKE_RECOVERY, 0.85, STRIKE_FIRST)
		else:
			phase = remap(phase, STRIKE_RECOVERY, 1.0, STRIKE_FIRST, 0.0)
	$Visual.pose(facing, velocity, pose, phase, delta)
