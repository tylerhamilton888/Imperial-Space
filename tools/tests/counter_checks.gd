extends SceneTree

const Boot = preload("res://ui/boot.tscn")
var boot
var arena
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, claim: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL ", claim)

func ticks(n: int) -> void:
	for _i in n:
		await physics_frame

func fixture():
	arena.restart(2)
	var enemy = arena.live_enemies[0]
	enemy.passive = true
	arena.player.input_enabled = false
	arena.player.aim_direction = Vector2.RIGHT
	enemy.position = arena.player.position + Vector2(54,0)
	await ticks(2)
	return enemy

func parry(enemy) -> void:
	var player = arena.player
	check(player.request_action(&"guard"), "fresh guard")
	check(player.receive_hit(enemy,1,20,&"melee",Vector2.LEFT) == &"parried", "frontal blade turned")
	check(player.has_opening() and player.health == 100, "parry creates an opening without damage")

func run() -> void:
	boot = Boot.instantiate()
	root.add_child(boot)
	boot.enter_arena(2)
	arena = boot.arena
	var enemy = await fixture()
	parry(enemy)
	check(arena.player.request_action(&"melee"), "riposte accepted while holding guard")
	await ticks(16)
	check(arena.live_enemies.is_empty() and arena.duel_finish == "Riposte", "one on-target riposte defeats the advancing raider")
	check(not arena.player.has_opening(), "opening consumed")
	enemy = await fixture()
	parry(enemy)
	arena.player.request_action(&"fire")
	await ticks(16)
	check(enemy.health == 23 and arena.player.magazine == 11, "countershot spends one round and wounds the parried target")
	arena.player.request_action(&"fire")
	await ticks(16)
	check(arena.live_enemies.is_empty(), "ordinary second shot finishes the raider")
	enemy = await fixture()
	parry(enemy)
	await ticks(60)
	check(not arena.player.has_opening(), "opening expires")
	arena.player.cancel_input()
	arena.player.request_action(&"fire")
	await ticks(16)
	check(enemy.health == 61, "late shot deals base damage")
	enemy = await fixture()
	parry(enemy)
	arena._spawn("gunner",arena.player.position+Vector2(0,70),true)
	var other = arena.live_enemies[1]
	await ticks(2)
	arena.player.aim_direction = Vector2.DOWN
	arena.player.request_action(&"fire")
	await ticks(16)
	check(other.health == 46 and enemy.health == 85, "bonus cannot transfer to another target")
	enemy = await fixture()
	parry(enemy)
	arena.map._add_solid("TestCover", Rect2(arena.player.position + Vector2(25,-24), Vector2(5,48)))
	await ticks(2)
	arena.player.request_action(&"fire")
	await ticks(16)
	check(enemy.health == 85 and not arena.player.has_opening(), "cover stops and spends the countershot")
	enemy = await fixture()
	arena.player.aim_direction = Vector2.LEFT
	arena.player.request_action(&"melee")
	await ticks(31)
	check(enemy.health == 85 and arena.player._followup_left == 0, "a miss grants no return cut")
	arena.player.aim_direction = Vector2.RIGHT
	arena.player.request_action(&"melee")
	await ticks(12)
	check(enemy.health == 47 and arena.player._followup_left > 0, "landed cut unlocks return")
	check(not arena.player.request_action(&"melee"), "early follow-up is buffered during the first recovery")
	await ticks(36)
	check(arena.duel_finish == "Return cut", "two connected strokes can finish a raider")
	enemy = await fixture()
	parry(enemy)
	arena.refill()
	check(not arena.player.has_opening() and arena.player._followup_left == 0, "refill clears earned actions")
	arena.restart(2)
	check(arena.duel_finish == "" and not arena.player.has_opening(), "restart clears duel result and opening")
	enemy = await fixture()
	arena._spawn("gunner", arena.player.position + Vector2(235,0), false)
	var gunner = arena.live_enemies[1]
	var old_pos: Vector2 = gunner.position
	await ticks(5)
	check(gunner.state != &"windup" and gunner.position.distance_to(old_pos) > 0.5, "gunner moves to find a clear shot around a squadmate")
	enemy.position += Vector2(0,80)
	for _i in 30:
		if gunner.state == &"windup": break
		await ticks(1)
	check(gunner.state == &"windup", "gunner commits when its lane is clear")
	enemy.position = gunner.position.lerp(arena.player.position, 0.55)
	await ticks(43)
	check(enemy.health == 70 and arena.player.health == 100, "crossing a committed shot wounds the raider and shields the player")
	boot.queue_free()
	await ticks(3)
	var until := Time.get_ticks_msec()+350
	while Time.get_ticks_msec()<until:
		OS.delay_msec(8)
		await process_frame
	print("Counter checks: %d, failures: %d" % [checks, failures])
	quit(1 if failures else 0)
