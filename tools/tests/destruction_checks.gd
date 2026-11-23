extends SceneTree
const Boot = preload("res://ui/boot.tscn")
const Shards = preload("res://combat/impact_fragment.gd")
const Query = preload("res://combat/combat_query.gd")
var checks := 0
var failed := 0
func _initialize() -> void:
	run.call_deferred()
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failed += 1
		push_error(message)
func ticks(n: int) -> void:
	for i in n:
		await physics_frame
func pieces() -> Array[Node]:
	return get_nodes_in_group(&"impact_fragments")
func run() -> void:
	var boot = Boot.instantiate()
	root.add_child(boot)
	boot.enter_arena(4)
	var arena = boot.arena
	var gate = arena.map.gate
	var cover = arena.map.get_node("WestWing")
	var shooter = arena.player
	shooter.input_enabled = false
	for enemy in arena.live_enemies:
		enemy.passive = true
	await ticks(2)
	for fixture in [gate,cover]:
		var feet: Vector2 = fixture.position
		var near := feet + Vector2.DOWN*70
		var far := feet + Vector2.UP*70
		shooter.position = near
		shooter._update_aim_at(feet + Vector2.UP*fixture.profile.contact_height)
		var shots := 3 if fixture == cover else 4
		for i in shots:
			check(shooter.request_action(&"fire"),"rifle attack accepted")
			await ticks(16)
			var phase := 3 if i+1 == shots else mini(2,i+1)
			check(fixture.phase == phase,"damage phase matches service round count")
			check(Query.first_hit(shooter,near,far,1).is_empty() == (phase==3),"physical lane agrees with art phase")
			check(arena.map.is_valid_spawn(feet,4) == (phase==3),"spawn area updates on destruction")
		check(arena.map.routes.route(near,far)==PackedVector2Array([far]),"navigation sees the opening")
		var count := pieces().size()
		fixture.receive_hit(shooter,999,99,&"bullet",Vector2.UP)
		check(count == pieces().size(),"destroyed object cannot shed a second burst")
	arena.restart(2)
	await ticks(2)
	check(pieces().is_empty(),"restart removes all debris")
	shooter = arena.player
	shooter.input_enabled = false
	var foe = arena.live_enemies[0]
	foe.passive = true
	foe.position = shooter.position + Vector2(55,0)
	foe.facing = Vector2.LEFT
	var wall_x: float = foe.position.x+45.0
	arena.map._add_solid("ImpactWall", Rect2(wall_x, foe.position.y-90,7,180))
	await ticks(2)
	foe.receive_hit(shooter,1,100,&"riposte",Vector2.RIGHT)
	check(foe.state == &"dead" and arena.live_enemies.is_empty(),"lethal contact retires combat target immediately")
	await ticks(7)
	check(pieces().size()==2 and not foe.get_node("View").visible,"separated body and arm replace the standing artwork")
	for part in pieces():
		check(part.ground_speed.x>0,"finisher sends both pieces along the incoming blow")
	await ticks(55)
	for part in pieces():
		check(part.global_position.x < wall_x and part.landed,"remains settle on the near side of solid cover")
	check(get_nodes_in_group(&"fallen_actors").size()==2,"no intact corpse duplicates the cut remains")
	arena.clear_enemies()
	check(pieces().is_empty(),"clear removes body parts before another spawn")
	arena._spawn("raider",shooter.position+Vector2(55,0),true)
	var rifle_victim = arena.live_enemies[0]
	rifle_victim.facing = Vector2.UP
	rifle_victim.receive_hit(shooter,2,100,&"bullet",Vector2.LEFT)
	await ticks(7)
	check(pieces().size()==1 and pieces()[0].heavy and pieces()[0].fall_row==1,"rear-view rifle fall keeps the body whole")
	await ticks(28)
	check(pieces()[0].landed and is_zero_approx(pieces()[0].angle),"fallen body rests in the painted ground pose")
	arena.clear_enemies()
	check(shooter.request_action(&"melee"),"sword draw accepted")
	await ticks(36)
	check(shooter.action==&"idle" and shooter.get_node("Visual").sword_readied,"sword remains drawn after recovery")
	check(shooter.request_action(&"fire") and not shooter.get_node("Visual").sword_readied,"firing restores rifle stance immediately")
	await ticks(16)
	arena._spawn("gunner",shooter.position+Vector2(55,0),true)
	var gunner = arena.live_enemies[0]
	var start: Vector2 = gunner.position
	await ticks(2)
	gunner.receive_hit(shooter,2,100,&"counter_shot",Vector2.RIGHT)
	await ticks(12)
	check(gunner.position.x > start.x+3 and gunner.position.x < wall_x and pieces().is_empty(),"lethal shot moves the gunner into terrain without severing it")
	for i in 20:
		Shards.shed_fixture(arena.simulation,shooter.position,Vector2.RIGHT,16,3,i+1)
	check(pieces().size()==Shards.LIMIT,"multiple simultaneous bursts respect the shared live cap")
	await ticks(180)
	check(pieces().is_empty(),"debris expires after settling")
	boot.queue_free()
	await ticks(4)
	var deadline := Time.get_ticks_msec()+280
	while Time.get_ticks_msec()<deadline:
		OS.delay_msec(8)
		await process_frame
	print("Destruction: %d checks, %d failures" % [checks,failed])
	quit(1 if failed else 0)
