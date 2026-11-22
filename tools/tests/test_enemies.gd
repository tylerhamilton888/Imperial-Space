extends SceneTree
## godot --headless --fixed-fps 60 --path game --script ../tools/tests/test_enemies.gd
const Enemy = preload("res://actors/enemies/enemy.gd")
const EnemyScene = preload("res://actors/enemy.tscn")
const Routes = preload("res://actors/enemies/ground_routes.gd")

class Defender extends CharacterBody2D:
	var health := 100
	var parry := false
	func receive_hit(_source: Node2D, _id: int, damage: int, kind: StringName, _direction: Vector2) -> StringName:
		if kind == &"melee" and parry:
			return &"parried"
		health -= damage
		return &"hit"

var world := Node2D.new()
var defender := Defender.new()
var checks := 0
var failures := 0

func _init() -> void:
	call_deferred("_run")

func _check(passed: bool, label: String) -> void:
	checks += 1
	if not passed:
		failures += 1
		printerr("FAIL ", label)

func _ticks(count: int) -> void:
	for tick in range(count):
		await physics_frame

func _until(actor: Enemy, wanted_state: StringName, limit: int) -> bool:
	for tick in range(limit):
		await physics_frame
		if actor.state == wanted_state:
			return true
	return false

func _spawn(role: StringName, pos: Vector2) -> Enemy:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.role = role
	enemy.position = pos
	world.add_child(enemy)
	return enemy

func _run() -> void:
	root.add_child(world)
	var shape := CollisionShape2D.new()
	var foot := CircleShape2D.new()
	foot.radius = 12.0
	shape.shape = foot
	defender.add_child(shape)
	defender.collision_layer = 2
	defender.collision_mask = 0
	defender.position = Vector2(330,150)
	world.add_child(defender)
	defender.add_to_group(&"player")

	var block := StaticBody2D.new()
	block.position = Vector2(220,150)
	var wall := CollisionShape2D.new()
	var slab := RectangleShape2D.new()
	slab.size = Vector2(32,128)
	wall.shape = slab
	block.add_child(wall)
	world.add_child(block)
	var obstacles: Array[Rect2] = [Rect2(block.position - slab.size * 0.5, slab.size)]
	var routes := Routes.new()
	routes.configure(Rect2(0,0,600,360), obstacles)
	world.add_child(routes)
	var start := Vector2(120,150)
	var path := routes.route(start, defender.position)
	_check(path.size() >= 2 and path[-1].is_equal_approx(defender.position), "route detours around cover")
	_check(routes.route(Vector2(30,30), Vector2(250,30)) == PackedVector2Array([Vector2(250,30)]), "open route is direct")

	var gunner := _spawn(&"gunner", start)
	await _ticks(120)
	_check(gunner.position.is_equal_approx(start) and defender.health == 100 and gunner.state == &"idle", "hidden target is unknown")
	block.queue_free()
	routes.configure(Rect2(0,0,600,360), [])
	_check(routes.route(start, defender.position) == PackedVector2Array([defender.position]), "reconfigured grid opens the old wall")
	_check(await _until(gunner, &"windup", 18), "gunner shows windup on sight")
	await _ticks(10)
	_check(defender.health == 100 and gunner.state == &"windup", "gunner does not hit on windup")
	defender.position.y += 56.0
	_check(await _until(gunner, &"recover", 65), "gunner fires locked shot")
	_check(defender.health == 100, "sidestep evades locked shot")
	await _ticks(125)
	_check(defender.health == 100 - gunner.profile.damage, "unobstructed shot hits once per recovery")
	# Cover arriving during anticipation must intercept a committed shot.
	_check(await _until(gunner, &"windup", 60), "gunner prepares next shot")
	var screen := StaticBody2D.new()
	screen.position = (gunner.position + defender.position) * 0.5
	var screen_shape := CollisionShape2D.new()
	screen_shape.shape = slab
	screen.add_child(screen_shape)
	world.add_child(screen)
	await _ticks(75)
	_check(defender.health == 85, "late cover intercepts a locked gunner shot")
	screen.queue_free()
	gunner.free()

	var raider := _spawn(&"raider", defender.position - Vector2(60,0))
	defender.parry = true
	_check(await _until(raider, &"stagger", 65), "parry exposes raider")
	_check(defender.health == 85, "parried strike does no damage")
	await _ticks(16)
	_check(raider.state == &"stagger", "opening persists")
	defender.parry = false
	_check(await _until(raider, &"windup", 90), "raider recovers")
	var before := defender.health
	raider.receive_hit(defender, 1, 20, &"melee", Vector2.LEFT)
	await _ticks(20)
	_check(raider.state == &"stagger" and defender.health == before, "sword interrupts pending strike")
	_check(raider.receive_hit(defender, 1, 20, &"melee", Vector2.LEFT) == &"duplicate" and raider.health == 65, "overlap cannot reapply damage")
	_check(raider.receive_hit(defender, 2, 100, &"bullet", Vector2.LEFT) == &"killed", "lethal hit removes threat")
	await _ticks(25)
	_check(not is_instance_valid(raider) and defender.health == before, "dead actor and its pending attack are gone")

	var dummy := _spawn(&"dummy", defender.position + Vector2(45,0))
	await _ticks(70)
	_check(dummy.state == &"idle" and defender.health == before and dummy.health == 160, "dummy remains passive")
	var closing := _spawn(&"raider", Vector2(520,300))
	await _ticks(20)
	_check(closing.state == &"approach" and closing.position.distance_to(Vector2(520,300)) > 20, "raider closes on observed target")
	var corner_cover := StaticBody2D.new()
	corner_cover.position = Vector2(420,250)
	var corner_shape := CollisionShape2D.new()
	corner_shape.shape = slab
	corner_cover.add_child(corner_shape)
	world.add_child(corner_cover)
	var cover_rect := Rect2(corner_cover.position-slab.size*0.5, slab.size)
	routes.configure(Rect2(0,0,600,360), [cover_rect])
	await _ticks(8)
	var observed_goal := defender.position
	defender.position = Vector2(290,330)
	await _ticks(25)
	_check(closing._last_known.is_equal_approx(observed_goal), "raider does not track hidden movement")
	world.queue_free()
	await _ticks(3)
	# Accelerated test frames can finish before the audio thread releases its
	# final hit cue. Give that thread real time after deleting the test world.
	var drain_until := Time.get_ticks_msec() + 250
	while Time.get_ticks_msec() < drain_until:
		OS.delay_msec(8)
		await process_frame
	print("Enemy scenarios: %d checks, %d failures." % [checks, failures])
	quit(1 if failures else 0)
