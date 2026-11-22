extends CharacterBody2D

signal stats_changed
signal died
signal combat_event(kind: StringName, from: Vector2, to: Vector2)

const Vitality = preload("res://combat/vitality.gd")
const Query = preload("res://combat/combat_query.gd")
const Feedback = preload("res://combat/feedback.gd")
const KIT = preload("res://data/medium_kit.tres")
const TORSO := Vector2(0, -46)
const PLAYER_ACTIONS: Array[StringName] = [&"dodge", &"guard", &"melee", &"fire", &"reload", &"heal"]

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
	velocity = Vector2.ZERO
	_set_action(&"idle")
	stats_changed.emit()

func _physics_process(delta: float) -> void:
	if health == 0:
		_update_view(delta)
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
	move_and_slide()
	_advance_action()
	_update_view(delta)

func _update_aim_at(cursor: Vector2) -> void:
	var target_point := cursor - TORSO
	# Resolve clicks anywhere on an upright silhouette onto its ground position.
	# The closest torso wins when figures overlap. Cover is still queried at contact.
	var closest := INF
	for member in get_tree().get_nodes_in_group(&"enemies"):
		var actor := member as Node2D
		if actor == null or actor.is_queued_for_deletion():
			continue
		var local := cursor - actor.global_position
		var torso_distance := (local - TORSO).length_squared()
		if absf(local.x) <= 18.0 and local.y >= -78.0 and local.y <= 3.0 and torso_distance < closest:
			closest = torso_distance
			target_point = actor.global_position
	var direction := global_position.direction_to(target_point)
	if not direction.is_zero_approx():
		aim_direction = direction

func request_action(id: StringName) -> bool:
	if health == 0 or not id in PLAYER_ACTIONS:
		return false
	if action == &"guard" and id == &"dodge":
		_set_action(&"idle")
	if action == &"idle":
		return _begin_action(id)
	if id != &"guard":
		_buffered = id
		_buffer_left = KIT.buffer_time
	return false

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
	_set_action(id)
	return true

func _begin_guard(fresh_press: bool) -> void:
	_guard_armed = fresh_press and _parry_cooldown <= 0
	if _guard_armed:
		_parry_cooldown = KIT.parry_rearm
	_set_action(&"guard")

func _set_action(id: StringName) -> void:
	action = id
	action_time = 0.0

func _advance_action() -> void:
	match action:
		&"fire":
			if not _shot_fired:
				_shot_fired = true
				_fire_rifle()
		&"melee":
			if action_time >= KIT.sword_contact_start and action_time <= KIT.sword_contact_end:
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
		&"melee": return KIT.sword_total
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
	if not hit.is_empty():
		endpoint = hit.position
		var body := hit.collider as Node2D
		if body != null and body.has_method(&"receive_hit"):
			body.call(&"receive_hit", self, _attack_id, KIT.rifle_damage, &"bullet", _aim_locked)
			struck_actor = true
	_update_view(0.0)
	var muzzle: Vector2 = global_position + $Visual.muzzle_offset()
	# If cover is closer than the drawn barrel, flash against its near face.
	var visible_end := endpoint + TORSO
	if (visible_end - muzzle).dot(_aim_locked) < 0:
		muzzle = global_position + TORSO
	_feedback(&"fire", muzzle, visible_end)
	if not hit.is_empty() and not struck_actor:
		_feedback(&"hit", visible_end, visible_end)

func _sword_contact() -> void:
	var targets := Query.melee_targets(self, _aim_locked, KIT.sword_reach, deg_to_rad(KIT.sword_half_angle_degrees), 4)
	for target in targets:
		var id := target.get_instance_id()
		if _sword_contacts.has(id):
			continue
		_sword_contacts[id] = true
		var direction := global_position.direction_to(target.global_position)
		target.call(&"receive_hit", self, _attack_id, KIT.sword_damage, &"melee", direction)

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
	var pose := &"parry" if action == &"guard" and _parry_pose_left > 0 else action
	$Visual.pose(facing, velocity, pose, phase, delta)
