extends SceneTree

const BOOT = preload("res://ui/boot.tscn")
var successes := 0
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func expect(ok: bool, claim: String) -> void:
	if ok:
		successes+=1
	else:
		printerr("FAIL ",claim)
		failures+=1

func _run() -> void:
	# A test-owned profile also catches accidental cross-mode writes.
	if not OS.get_user_data_dir().contains("imperial-test"):
		printerr("Set XDG_DATA_HOME to an isolated directory containing imperial-test.")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute("user://campaign")
	var sentinel:="user://campaign/slot.json"
	var f:=FileAccess.open(sentinel,FileAccess.WRITE)
	f.store_string('{"checkpoint":"preserve","reward_claimed":true}')
	f.close()
	var before:=FileAccess.get_sha256(sentinel)
	var boot=BOOT.instantiate()
	root.add_child(boot)
	await process_frame
	expect(boot.mode==boot.Session.MENU,"fresh menu")
	boot.show_settings()
	expect(is_instance_valid(boot.overlay),"settings")
	boot.prefs.set_mouse_swap(true)
	boot.prefs.rebind("reload",KEY_T)
	var prefs=boot.Preferences.new()
	prefs.setup()
	expect(prefs.key_text("reload").to_upper()=="T","persistent binding")
	expect(prefs.mouse_text("fire")=="RMB","persistent mouse swap")
	expect(not prefs.rebind("reload",KEY_W),"duplicate binding rejected")
	prefs.reset_bindings()
	expect(prefs.key_text("reload").to_upper()=="R" and prefs.mouse_text("fire")=="LMB","reset bindings")
	boot._close_settings()
	boot.enter_arena()
	var a=boot.arena
	await physics_frame
	expect(a.scenario.id==&"empty" and a.live_enemies.is_empty(),"empty entry")
	var start:Vector2=a.player.position
	Input.action_press("move_right")
	for _i in 12: await physics_frame
	Input.action_release("move_right")
	var straight:float=a.player.position.distance_to(start)
	a.player.position=start
	Input.action_press("move_right")
	Input.action_press("move_down")
	for _i in 12: await physics_frame
	Input.action_release("move_right")
	Input.action_release("move_down")
	expect(straight>30 and absf(straight-a.player.position.distance_to(start))<.1,"normalized diagonal movement")
	a.restart(1)
	await physics_frame
	expect(a.live_enemies.size()==1 and a.live_enemies[0].role==&"dummy","dummy preset")
	var old_player:WeakRef=weakref(a.player)
	var old_enemy:WeakRef=weakref(a.live_enemies[0])
	var old_simulation:WeakRef=weakref(a.simulation)
	a.player.receive_hit(a.live_enemies[0],77,20,&"bullet",Vector2.LEFT)
	expect(a.player.health<a.player.max_health,"shared damage")
	a.refill()
	expect(a.player.health==a.player.max_health,"refill without rebuild")
	a.set_panel("controls")
	expect(paused and not a.player.input_enabled,"range menu freezes simulator")
	a.toggle_grid()
	expect(a.map.grid_visible,"visible grid")
	a.spawn_role="gunner"
	a.spawn_count=4
	a.spawn_passive=true
	a.spawn_selected()
	var layout: Array = a.live_enemies.map(func(e:Node2D): return e.position)
	expect(layout.size()==5,"manual spawn count")
	var unique:Dictionary={}
	for loc:Vector2 in layout: unique[loc]=true
	expect(unique.size()==5,"manual spawn clearance")
	expect(not paused and a.player.input_enabled,"spawn resumes simulator")
	a.restart(1)
	a.spawn_selected()
	expect(a.live_enemies.map(func(e:Node2D): return e.position)==layout,"seed reproduces placements")
	await process_frame
	await process_frame
	expect(old_player.get_ref()==null and old_enemy.get_ref()==null and old_simulation.get_ref()==null,"reset frees prior scene tree")
	a.restart(3)
	await physics_frame
	expect(a.live_enemies.size()==2,"mixed preset")
	a.clear_enemies()
	expect(a.live_enemies.is_empty() and get_nodes_in_group("enemies").is_empty(),"clear releases encounter")
	a.restart(2)
	a.player.receive_hit(a.live_enemies[0],44,500,&"bullet",Vector2.LEFT)
	expect(a.panel_kind=="defeat" and paused,"defeat overlay")
	a.restart()
	expect(not paused and a.player.health==a.player.max_health and a.live_enemies.size()==1,"death retry")
	a.set_panel("pause")
	var frozen:Vector2=a.live_enemies[0].position
	for _i in 6: await physics_frame
	expect(a.live_enemies[0].position==frozen,"pause stops AI")
	Engine.time_scale=.5
	a.leave()
	await process_frame
	expect(boot.mode==boot.Session.MENU and not paused and Engine.time_scale==1,"menu exit clears session")
	expect(get_nodes_in_group("enemies").is_empty() and get_nodes_in_group("player").is_empty(),"exit clears actors")
	expect(FileAccess.get_sha256(sentinel)==before,"campaign sentinel unchanged")
	boot.queue_free()
	# The audio mixer runs on a wall-clock thread even during fixed-fps tests.
	var deadline := Time.get_ticks_msec()+160
	while Time.get_ticks_msec()<deadline:
		OS.delay_msec(8)
		await process_frame
	print("Arena checks: ",successes," passed, ",failures," failed")
	quit(0 if failures==0 else 1)
