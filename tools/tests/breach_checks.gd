extends SceneTree

const Boot = preload("res://ui/boot.tscn")
const Query = preload("res://combat/combat_query.gd")
var checks := 0
var failed := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		push_error(message)
		failed += 1

func ticks(n: int) -> void:
	for i in n:
		await physics_frame

func run() -> void:
	var boot := Boot.instantiate()
	root.add_child(boot)
	boot.enter_arena(4)
	var a = boot.arena
	await ticks(3)
	var gate = a.map.gate
	var map = a.map
	var p = a.player
	for defender in a.live_enemies:
		defender.passive = true
	var lower := Vector2(698,470)
	var upper := Vector2(698,320)
	check(a.scenario.id == &"breach" and a.live_enemies.size() == 2, "Direct entry sets the authored drill")
	check(not map.is_valid_spawn(gate.position) and not map.is_valid_spawn(Vector2(34,180)), "Closed shutter and off-deck corner reject spawn")
	check(Query.first_hit(p, lower, upper, 1).get("collider") == gate, "Shutter owns the first ray hit")
	check(map.routes.route(lower, upper).size()>1, "AI must initially detour")
	check(p.test_move(Transform2D(0,lower),upper-lower), "Solid panel blocks an actor")
	p.input_enabled=false
	p.position=lower
	p._update_aim_at(gate.position+Vector2(0,-100))
	check(p.aim_direction.dot(Vector2.UP) > .99, "Clicking the painted upper shutter resolves to the ground aperture")
	for i in 4:
		check(p.request_action(&"fire"), "Rifle action accepted")
		await ticks(16)
	check(gate.is_open and gate.vitality.health == 0 and p.magazine == 8, "Four real rifle attacks break the shutter")
	check(Query.first_hit(p,lower,upper,1).is_empty(), "Open aperture clears shot obstruction")
	check(map.routes.route(lower,upper) == PackedVector2Array([upper]), "Open aperture yields a direct AI route")
	check(not p.test_move(Transform2D(0,lower),upper-lower), "Actor fits through opened frame")
	check(map.is_valid_spawn(gate.position) and not map.is_valid_spawn(Vector2(635,397)), "Spawn clearance follows open aperture and solid jamb")
	check(not Query.first_hit(p,Vector2(635,460),Vector2(635,345),1).is_empty(),"Left jamb still stops shots")
	check(not Query.first_hit(p,Vector2(763,460),Vector2(763,345),1).is_empty(),"Right jamb still stops shots")
	map.track_passage(Vector2(900,430))
	map.track_passage(Vector2(900,370))
	check(not map.crossed,"Walking around the wall cannot award passage")
	map.track_passage(lower)
	map.track_passage(upper)
	check(map.crossed,"Crossing through the breach counts")
	for e in a.live_enemies.duplicate():
		e.receive_hit(p,999,999,&"bullet",Vector2.UP)
	check(a.drill_instruction().begins_with("Drill complete"), "Passing the gate and defeating defenders completes the drill")
	a.restart()
	await ticks(3)
	check(not a.map.crossed and not a.map.gate.is_open and a.drill_opponents.size()==2, "Restart restores the gate, defenders and objective")
	var target=a.map.get_node("SteelTarget1")
	a.player.position=target.position+Vector2(0,80)
	a.player.input_enabled=false
	a.player._update_aim_at(target.position+Vector2(2,-44))
	a.player.request_action(&"fire")
	await ticks(16)
	check(target.hits==1,"Shooting a painted target registers one impact")
	a.clear_enemies()
	check(a.drill_interrupted and not a.drill_instruction().begins_with("Drill complete"), "Manual clearing cannot win the drill")
	a.restart(3)
	await ticks(2)
	check(a.scenario.id == &"squad" and a.live_enemies.size()==2, "Original forecourt remains reachable")
	boot.queue_free()
	await ticks(3)
	var deadline := Time.get_ticks_msec()+250
	while Time.get_ticks_msec()<deadline:
		OS.delay_msec(8)
		await process_frame
	print("Breach drill: %d checks, %d failures" % [checks,failed])
	quit(1 if failed else 0)
