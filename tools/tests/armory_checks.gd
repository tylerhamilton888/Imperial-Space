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
	for i in count:
		await physics_frame

func run() -> void:
	var boot = Boot.instantiate()
	root.add_child(boot)
	if boot.mode == boot.Session.MENU:
		boot.enter_armory()
	var trial = boot.arena
	var knight = trial.knight
	var view = knight.get_node("Visual")
	await ticks(4)
	check(knight.melee_profile == view.weapon.melee_profile,"Default weapon tuning")
	check(not knight.equip(trial.WEAPONS[0],trial.WEAPONS[1]),"Reject a weapon in the shoulder slot")
	var poses := {}
	Input.action_press(&"move_right")
	for i in 27:
		await physics_frame
		poses[view.frame] = true
	Input.action_release(&"move_right")
	await ticks(4)
	check(poses.size() == 4,"Four moving body keys")
	for pair in [[0,0],[1,0],[1,1],[0,1]]:
		if trial.weapon_index != pair[0]:
			trial.swap(true)
		if trial.shoulder_index != pair[1]:
			trial.swap(false)
		check(view.weapon == trial.WEAPONS[pair[0]] and view.shoulder == trial.SHOULDERS[pair[1]],"Independent slot selection")
		knight.position = trial.target.position - Vector2(78,0)
		await ticks(2)
		var before: int = trial.hit_count
		check(knight.request_action(&"melee"),"Start strike")
		trial.swap(true)
		check(trial.weapon_index == pair[0] and view.weapon == trial.WEAPONS[pair[0]],"Mid-strike swap rejected")
		await ticks(60)
		check(trial.hit_count == before+1,"One contact per strike")
		check(trial.status.text.begins_with(str(knight.melee_profile.sword_damage)+" damage"),"Equipped item damage")
	knight.position = Vector2(552,490)
	Input.action_press(&"move_down")
	await ticks(24)
	Input.action_release(&"move_down")
	check(knight.position.y < 510,"Cover stops the player")
	trial.exit_requested.emit()
	await ticks(3)
	check(boot.mode == boot.Session.MENU and not is_instance_valid(boot.arena),"Return to title")
	boot.queue_free()
	for i in 32:
		await process_frame
		OS.delay_msec(8)
	print("Armory: %d checks, %d failures" % [checks,failures])
	quit(int(failures > 0))
