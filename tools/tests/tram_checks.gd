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
	Input.action_press(&"move_right")
	await ticks(43)
	Input.action_release(&"move_right")
	check(scene.phase == scene.Phase.HOLD,"Approaching the operator starts defense")
	Input.action_press(&"move_left")
	await ticks(93)
	Input.action_release(&"move_left")
	for i in 1200:
		if scene.phase == scene.Phase.LOST: break
		await ticks(1)
	check(scene.operator.health == 0 and scene.knight.health > 0,"Undefended operator falls to raiders")
	check(scene.operator.key == 3 and scene.car.position.x == 610 and scene.replay.visible,"Stalled car and injured operator on failure")
	scene.replay.pressed.emit()
	scene = boot.arena
	await ticks(3)
	check(scene.locks == 0 and scene.operator.health == 69 and scene.phase == scene.Phase.WAITING,"Replay restores operator, locks and opening")
	Input.action_press(&"move_right")
	await ticks(88)
	Input.action_release(&"move_right")
	var p = scene.knight
	p.input_enabled = false
	var crossed := false
	var left_pose_used := false
	for i in 1200:
		var foe = null
		for candidate in scene.threats:
			if is_instance_valid(candidate) and candidate.state != &"dead" and not candidate.retreating:
				foe = candidate
				break
		if not crossed and scene.parries >= 1 and foe == null:
			crossed = true
			p.input_enabled = true
			Input.action_press(&"move_left")
			await ticks(50)
			Input.action_release(&"move_left")
			p.input_enabled = false
		if is_instance_valid(foe):
			p._update_aim_at(foe.position+Vector2(0,-45))
			if p.has_opening():
				p.request_action(&"melee")
			elif foe.state == &"windup" and foe._duration-foe._elapsed<0.11 and p.action==&"idle":
				p.request_action(&"guard")
		left_pose_used = left_pose_used or p.get_node("Visual").looks_left
		if scene.phase in [scene.Phase.LOST,scene.Phase.CLEAR]: break
		await ticks(1)
	check(scene.parries == 2 and scene.player_hits == 2,"Both live melee threats can be parried and countered")
	check(left_pose_used and crossed,"Second side uses authored left-facing pose")
	check(scene.second_arrived and scene.operator.health == 69,"Both approaches covered in time")
	check(scene.phase == scene.Phase.CLEAR and scene.locks == 3,"All three locks release")
	check(scene.car.position.x < -250 and scene.operator.key == 2,"Departure moves whole tram offscreen")
	scene.exit_requested.emit()
	await ticks(4)
	check(boot.mode == boot.Session.MENU and not is_instance_valid(boot.arena),"Return to menu")
	boot.queue_free()
	for i in 36:
		await process_frame
		OS.delay_msec(8)
	print("Last Tram: %d checks, %d failures" % [checks,failures])
	quit(int(failures > 0))
