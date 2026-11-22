extends SceneTree
## Run from the repository root:
## godot --headless --path game --fixed-fps 60 --script ../tools/tests/combat_checks.gd

const Player = preload("res://actors/player.gd")
const PLAYER = preload("res://actors/player.tscn")
const ENEMY = preload("res://actors/enemy.tscn")
const Vitality = preload("res://combat/vitality.gd")
const Preferences = preload("res://ui/preferences.gd")

class Target extends StaticBody2D:
	var vitality := Vitality.new(500)
	var sources: Array[int] = []
	func receive_hit(source: Node2D, id: int, damage: int, _kind: StringName, _incoming: Vector2) -> StringName:
		sources.append(source.get_instance_id())
		return vitality.apply(source, id, damage)

var player: Player
var target: Target
var room := Node2D.new()
var passed := 0
var failures := 0
var death_count := 0

func _initialize() -> void:
	call_deferred(&"run_tests")

func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
	else:
		failures += 1
		printerr("FAIL ", label)

func ticks(count: int) -> void:
	for index in count:
		await physics_frame

func click(point: Vector2, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	root.push_input(event, true)

func press_guard(down: bool) -> void:
	var event := InputEventKey.new()
	var binding: InputEventKey = InputMap.action_get_events(&"guard")[0]
	event.physical_keycode = binding.physical_keycode
	event.pressed = down
	root.push_input(event, true)

func shape_for(body: CollisionObject2D, shape: Shape2D) -> void:
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)

func run_tests() -> void:
	Preferences.new().setup()
	root.size = Vector2i(1280, 720)
	root.add_child(room)
	player = PLAYER.instantiate()
	player.input_enabled = false
	player.position = Vector2(220, 280)
	room.add_child(player)
	player.died.connect(func() -> void: death_count += 1)
	target = Target.new()
	target.collision_layer = 4
	target.collision_mask = 0
	target.add_to_group(&"enemies")
	var circle := CircleShape2D.new()
	circle.radius = 14
	shape_for(target, circle)
	target.position = player.position + Vector2.RIGHT * 156
	room.add_child(target)
	await ticks(3)

	check(player.request_action(&"fire"), "rifle accepted at idle")
	check(not player.request_action(&"melee"), "cannot start two active attacks")
	await ticks(4)
	check(target.vitality.health == 476 and target.sources == [player.get_instance_id()], "shot resolved on intended target with source")
	check(player.magazine == 11, "one round consumed per accepted shot")
	await ticks(15)
	check(player.action == &"idle", "expired buffered request does not fire later")

	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.collision_mask = 0
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(3, 130)
	shape_for(wall, rectangle)
	wall.position = player.position + Vector2.RIGHT * 22
	room.add_child(wall)
	await ticks(2)
	player.request_action(&"fire")
	await ticks(15)
	check(target.vitality.health == 476 and player.magazine == 10, "thin wall inside gun barrel blocks hitscan")

	target.position = player.position + Vector2.RIGHT * 53
	player.request_action(&"melee")
	await ticks(29)
	check(target.vitality.health == 476, "thin wall also blocks melee")
	wall.queue_free()
	await ticks(2)
	player.request_action(&"melee")
	await ticks(4)
	check(target.vitality.health == 476, "sword windup has no contact")
	await ticks(23)
	check(target.vitality.health == 438 and target.sources.size() == 2, "active sword frames cause one wound per target")
	player.request_action(&"reload")
	await ticks(30)
	check(player.magazine == 10, "reload does not transfer before completion")
	await ticks(40)
	check(player.magazine == 12 and player.reserve == 82, "reload conserves ammunition")

	player.aim_direction = Vector2.RIGHT
	check(player.request_action(&"guard"), "guard accepted")
	check(player.receive_hit(target, 1, 20, &"melee", Vector2.LEFT) == &"parried", "fresh frontal melee parry")
	check(player.receive_hit(target, 1, 20, &"melee", Vector2.LEFT) == &"duplicate" and player.health == 100, "one parried contact cannot apply again")
	check(player.receive_hit(target, 2, 20, &"melee", Vector2.LEFT) == &"guarded" and player.health == 95, "successful parry consumes opening")
	check(player.receive_hit(target, 3, 20, &"melee", Vector2.RIGHT) == &"hit" and player.health == 75, "guard leaves rear exposed")
	player.cancel_input()
	player.request_action(&"guard")
	check(player.receive_hit(target, 4, 20, &"melee", Vector2.LEFT) == &"guarded" and player.health == 70, "rapid guard press cannot reopen parry")
	player.cancel_input()
	player.request_action(&"heal")
	await ticks(30)
	check(player.health == 100 and player.med_charges == 2, "medical charge restores health and clamps")
	player.request_action(&"dodge")
	check(player.receive_hit(target, 5, 20, &"bullet", Vector2.LEFT) == &"evaded", "early dodge avoids one shot")
	await ticks(14)
	check(player.receive_hit(target, 6, 20, &"bullet", Vector2.LEFT) == &"hit", "dodge recovery is vulnerable")
	check(not player.request_action(&"dodge"), "dodge cannot cancel itself")
	await ticks(36)
	check(player.receive_hit(target, 7, 1000, &"bullet", Vector2.LEFT) == &"killed", "lethal damage transitions to defeat")
	check(player.receive_hit(target, 8, 1000, &"bullet", Vector2.LEFT) == &"ignored" and death_count == 1, "death emitted exactly once")
	check(not player.request_action(&"fire"), "defeated actor cannot fire")
	player.refill()
	check(player.health == 100 and player.magazine == 12 and player.reserve == 84 and player.med_charges == 3, "refill restores full kit")

	# Route clicks through the actual viewport, including GUI dispatch and a
	# non-horizontal target: an incorrect torso projection would miss this shot.
	player.position = Vector2(220, 280)
	target.position = Vector2(360, 218)
	player.input_enabled = true
	await ticks(3)
	click(target.position + Vector2(0, -59), true)
	click(target.position + Vector2(0, -59), false)
	await ticks(14)
	check(target.vitality.health == 414, "cursor on an elevated torso strikes its foot-plane actor")
	click(target.position, true)
	click(target.position, false)
	await ticks(14)
	check(target.vitality.health == 390, "cursor at the feet strikes the same actor")
	# A painted raider is broader than the original target. The upper outside
	# shoulder must resolve against that role’s picking bounds at game scale.
	var raider := ENEMY.instantiate()
	raider.role = &"raider"
	raider.passive = true
	raider.position = Vector2(400, 356)
	room.add_child(raider)
	await ticks(3)
	var raider_health: int = raider.health
	var shoulder: Vector2 = raider.position + Vector2(22, -72)
	click(shoulder, true)
	click(shoulder, false)
	await ticks(14)
	check(raider.health < raider_health, "clicking the painted raider shoulder registers a shot")
	raider.queue_free()
	var panel := Button.new()
	panel.text = "Refill"
	panel.position = Vector2(330, 150)
	panel.size = Vector2(120, 60)
	room.add_child(panel)
	await ticks(2)
	var before := player.magazine
	click(Vector2(360, 185), true)
	click(Vector2(360, 185), false)
	await ticks(15)
	check(player.magazine == before, "a GUI button consumes the press before weapons")
	panel.queue_free()
	await ticks(3)
	click(Vector2(600, 400), true)
	await ticks(26)
	check(before - player.magazine >= 2, "held mouse fires at bounded repeat cadence")
	player.cancel_input()
	var released := player.magazine
	await ticks(32)
	check(released == player.magazine, "modal cancel clears held fire")
	click(Vector2(600, 400), false)

	player.guard_toggle = true
	press_guard(true)
	press_guard(false)
	await ticks(2)
	check(player.action == &"guard", "toggle guard persists on release")
	press_guard(true)
	press_guard(false)
	await ticks(2)
	check(player.action == &"idle", "second toggle lowers guard")
	press_guard(true)
	press_guard(false)
	player.cancel_input()
	await ticks(15)
	check(player.action == &"idle", "modal cancellation clears latched guard")
	player.guard_toggle = false
	press_guard(true)
	check(player.action == &"guard", "hold guard activates on press")
	press_guard(false)
	check(player.action == &"idle", "hold guard lowers on release")

	print("Combat checks: %d passed, %d failed." % [passed, failures])
	room.queue_free()
	await ticks(2)
	# --fixed-fps can finish the simulation before the audio driver's real-time
	# mix thread has released its last short WAV. Let it drain on teardown.
	var drain_until := Time.get_ticks_msec() + 250
	while Time.get_ticks_msec() < drain_until:
		await process_frame
		OS.delay_msec(8)
	quit(1 if failures else 0)
