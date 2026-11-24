extends SceneTree
const Boot = preload("res://ui/boot.tscn")
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr(message)

func ticks(count: int) -> void:
	for i in count: await physics_frame

func run() -> void:
	var boot = Boot.instantiate()
	root.add_child(boot)
	if boot.mode == boot.Session.MENU:
		var launch: Button = null
		for item in boot.screen.get_children():
			if item is Button and item.text == "Play The Last Tram":
				launch = item
		check(launch != null,"Title entry present")
		if launch == null:
			quit(1)
			return
		launch.pressed.emit()
	var scene = boot.arena
	await ticks(40)
	check(scene.phase == scene.Phase.WAITING and scene.threats.is_empty(),"Read the platform before engaging")
	var ray := PhysicsRayQueryParameters2D.create(Vector2(525,320),Vector2(290,145),1)
	var space: PhysicsDirectSpaceState2D = scene.knight.get_world_2d().direct_space_state
	check(not space.intersect_ray(ray).is_empty(),"Diagonal rails stop the Knight at the platform curb")
	ray.from = Vector2(960,480)
	ray.to = Vector2(1225,483)
	check(not space.intersect_ray(ray).is_empty(),"Planter and canal have solid footprints")
	var origin: Vector2 = scene.knight.position
	await walk_to(scene.knight,Vector2(553,369))
	check(scene.phase == scene.Phase.HOLD,"Approaching the operator starts defense")
	check(origin.y-scene.knight.position.y > 180,"Playable forecourt has vertical depth")
	await walk_to(scene.knight,Vector2(796,545))
	for i in 1200:
		if scene.phase == scene.Phase.LOST: break
		await ticks(1)
	check(scene.operator.health == 0 and scene.knight.health > 0,"Undefended operator falls to raiders")
	check(scene.operator.key == 3 and scene.car.position == scene.CAR_STOP and scene.replay.visible,"Stalled car and injured operator on failure")
	check(scene.boarded == 0 and scene.yard.get_node("PassengerB").visible,"Closed lane leaves passengers waiting")
	scene.replay.pressed.emit()
	scene = boot.arena
	await ticks(3)
	check(scene.locks == 0 and scene.operator.health == 69 and scene.phase == scene.Phase.WAITING,"Replay restores operator, locks and opening")
	var visual = scene.knight.get_node("Visual")
	var facings := {}
	for i in 8:
		visual.pose(Vector2.from_angle(i*TAU/8),Vector2.ZERO,&"idle",0.0,0.0)
		facings[visual.heading] = true
	check(facings.size() == 8,"Eight distinct registered aim headings")
	var lane = scene.yard.get_node("BoardingDivider")
	var ray_to_lane := PhysicsRayQueryParameters2D.create(Vector2(316,451),Vector2(316,343),1)
	check(space.intersect_ray(ray_to_lane).get("collider") == lane,"Boarding divider blocks a physical crossing")
	var states: Array = await free_boarding_lane(scene)
	check(states == [1,2,2,3],"Live sword strikes expose chipped, breached and rubble plates")
	check(lane.is_open and space.intersect_ray(ray_to_lane).is_empty(),"The broken divider leaves a traversable lane")
	check(scene.yard.get_node("FreightDivider").phase == 0,"The neighboring fixture keeps its own integrity")
	await defend(scene)
	check(scene.boarded == 2 and not scene.yard.get_node("PassengerB").visible,"Both evacuees cross the opening and board")
	check(scene.parries == 2 and scene.player_hits == 2,"Both live melee threats can be parried and countered")
	check(scene.NORTH_ENTRY.y + 350 < scene.SOUTH_ENTRY.y,"Opposing attacks enter from different depths")
	check(scene.second_arrived and scene.operator.health == 69,"Both approaches covered in time")
	check(scene.phase == scene.Phase.CLEAR and scene.locks == 3,"All three locks release")
	check(scene.car.position.x < -250 and scene.car.position.y > scene.CAR_STOP.y+200 and scene.operator.key == 2,"Departure moves whole tram offscreen")
	scene.replay.pressed.emit()
	scene = boot.arena
	await ticks(3)
	await defend(scene)
	check(scene.phase == scene.Phase.CLEAR and scene.boarded == 0,"Standing defense can save the car but leave the late passengers")
	check(scene.yard.get_node("BoardingDivider").phase == 0 and scene.yard.get_node("PassengerA").visible,"Reset restores masonry, its collision and the waiting civilians")
	scene.exit_requested.emit()
	await ticks(4)
	check(boot.mode == boot.Session.MENU and not is_instance_valid(boot.arena),"Return to menu")
	boot.queue_free()
	for i in 36:
		await process_frame
		OS.delay_msec(8)
	print("Last Tram: %d checks, %d failures" % [checks,failures])
	quit(int(failures > 0))

func walk_to(p, goal: Vector2) -> void:
	p.input_enabled = true
	for i in 240:
		var offset: Vector2 = goal - p.position
		if offset.length() < 4: break
		var direction := offset.normalized()
		root.warp_mouse(goal + Vector2(0,-46))
		Input.action_press(&"move_left",maxf(0,-direction.x))
		Input.action_press(&"move_right",maxf(0,direction.x))
		Input.action_press(&"move_up",maxf(0,-direction.y))
		Input.action_press(&"move_down",maxf(0,direction.y))
		await ticks(1)
	for id in [&"move_left",&"move_right",&"move_up",&"move_down"]:
		Input.action_release(id)
	p.input_enabled = false

func defend(scene) -> void:
	var p = scene.knight
	await walk_to(p,Vector2(553,369))
	await walk_to(p,Vector2(688,241))
	var crossed := false
	for i in 1000:
		var foe = null
		for candidate in scene.threats:
			if is_instance_valid(candidate) and candidate.state != &"dead" and not candidate.retreating:
				foe = candidate
				break
		if not crossed and scene.parries >= 1 and foe == null:
			crossed = true
			await walk_to(p,Vector2(436,416))
		if is_instance_valid(foe):
			p._update_aim_at(foe.position+Vector2(0,-36))
			if p.has_opening():
				p.request_action(&"melee")
			elif foe.state == &"windup" and foe._duration-foe._elapsed<0.11 and p.action==&"idle":
				p.request_action(&"guard")
		if scene.phase in [scene.Phase.LOST,scene.Phase.CLEAR]: break
		await ticks(1)

func free_boarding_lane(scene) -> Array:
	var p = scene.knight
	var gate = scene.yard.get_node("BoardingDivider")
	await walk_to(p,Vector2(390,378))
	var states := []
	for i in 4:
		p._update_aim_at(gate.global_position+Vector2(0,-29))
		p.request_action(&"melee")
		await ticks(33)
		states.append(gate.phase)
	return states
