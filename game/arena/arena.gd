extends Node2D

signal exit_requested

const Player = preload("res://actors/player.tscn")
const Enemy = preload("res://actors/enemy.tscn")
const Map = preload("res://arena/range_map.tscn")
const Scenario = preload("res://arena/scenario.gd")
const Hud = preload("res://ui/range_hud.gd")
const SCENARIOS := [
	preload("res://arena/scenarios/empty.tres"),
	preload("res://arena/scenarios/dummy.tres"),
	preload("res://arena/scenarios/duel.tres"),
	preload("res://arena/scenarios/squad.tres")
]
const SPAWNS := [Vector2(930,445),Vector2(880,500),Vector2(1090,430),Vector2(1080,570),Vector2(780,450),Vector2(770,550),Vector2(650,375),Vector2(1230,430),Vector2(1220,510),Vector2(1035,670),Vector2(830,340)]
const CAP := 12
const SIGHT = preload("res://art/aim_cursor.svg")

var prefs: RefCounted
var scenario_index := 0
var scenario: Scenario
var session_rng := RandomNumberGenerator.new()
var simulation: Node2D
var map: Node2D
var player: CharacterBody2D
var hud: CanvasLayer
var live_enemies: Array[Node2D] = []
var grid_on := false
var panel_kind := ""
var spawn_role := "raider"
var spawn_count := 1
var spawn_passive := false

func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() != "headless":
		Input.set_custom_mouse_cursor(SIGHT, Input.CURSOR_CROSS, Vector2(16,16))
	hud=Hud.new()
	hud.arena=self
	add_child(hud)
	restart(0)

func restart(index: int = -1) -> void:
	if index >= 0 and index < SCENARIOS.size(): scenario_index=index
	scenario=SCENARIOS[scenario_index]
	Engine.time_scale=1.0
	get_tree().paused=false
	if is_instance_valid(simulation):
		remove_child(simulation)
		simulation.queue_free()
	live_enemies.clear()
	session_rng.seed=scenario.seed_value
	simulation=Node2D.new()
	simulation.name="Simulation"
	simulation.process_mode=Node.PROCESS_MODE_PAUSABLE
	simulation.y_sort_enabled=true
	add_child(simulation)
	map=Map.instantiate()
	map.grid_visible=grid_on
	simulation.add_child(map)
	player=Player.instantiate()
	player.guard_toggle=bool(prefs.config.get_value("controls","toggle_guard",false))
	player.position=scenario.player_start
	simulation.add_child(player)
	var camera:=Camera2D.new()
	# Frame a 96–100 px Crusader at the approved 1080p scale while keeping the
	# arsenal entrance and the gunner across the range visible in the opening shot.
	camera.zoom=Vector2(1.07,1.07)
	camera.position=Vector2(0,-164)
	camera.limit_left=0
	camera.limit_top=-120
	camera.limit_right=1600
	camera.limit_bottom=960
	camera.position_smoothing_enabled=true
	camera.position_smoothing_speed=8.5
	player.add_child(camera)
	camera.make_current()
	camera.reset_smoothing()
	player.stats_changed.connect(hud.refresh)
	player.died.connect(_on_defeat)
	for i in scenario.roles.size():
		_spawn(scenario.roles[i],scenario.positions[i],false)
	set_panel("")
	hud.refresh()
	if scenario.id == &"empty":
		hud.notice("Open Range controls to start a drill.")

func _spawn(role: String, pos: Vector2, passive: bool) -> void:
	var e: CharacterBody2D=Enemy.instantiate()
	e.role=StringName(role)
	e.passive=passive
	e.position=pos
	simulation.add_child(e)
	live_enemies.append(e)
	e.died.connect(_on_enemy_died.bind(e))

func _on_enemy_died(e: Node2D) -> void:
	live_enemies.erase(e)
	hud.refresh()

func _on_defeat() -> void:
	set_panel("defeat")

func spawn_selected() -> void:
	var remaining:=spawn_count
	var candidates:=SPAWNS.duplicate()
	# A session-local generator maintains reproducible manual spawn order.
	while remaining > 0 and not candidates.is_empty() and live_enemies.size() < CAP:
		var n:=session_rng.randi_range(0,candidates.size()-1)
		var point: Vector2=candidates.pop_at(n)
		if not map.is_valid_spawn(point) or point.distance_to(player.position)<60.0: continue
		var occupied:=false
		for e: Node2D in live_enemies:
			if e.position.distance_to(point)<48.0:
				occupied=true
				break
		if occupied: continue
		_spawn(spawn_role,point,spawn_passive)
		remaining-=1
	set_panel("")
	var spawned:=spawn_count-remaining
	hud.notice("Spawned %d of %d  •  %s" % [spawned,spawn_count,spawn_role.capitalize()])

func clear_enemies() -> void:
	for e: Node in simulation.get_children():
		if e.scene_file_path == Enemy.resource_path:
			simulation.remove_child(e)
			e.queue_free()
	live_enemies.clear()
	set_panel("")
	hud.notice("Range cleared")

func refill() -> void:
	player.refill()
	set_panel("")
	hud.notice("Health and supplies restored")

func toggle_grid() -> void:
	grid_on=not grid_on
	map.grid_visible=grid_on
	hud.refresh()

func set_panel(kind: String) -> void:
	var reopening := panel_kind != "" and kind == ""
	panel_kind=kind
	Input.set_default_cursor_shape(Input.CURSOR_CROSS if kind=="" else Input.CURSOR_ARROW)
	get_tree().paused=kind != ""
	player.input_enabled=kind==""
	player.cancel_input()
	if reopening:
		get_viewport().gui_release_focus()
	hud.show_panel(kind)
	hud.refresh()

func leave() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	get_tree().paused=false
	Engine.time_scale=1.0
	exit_requested.emit()

func _input(event: InputEvent) -> void:
	if not is_instance_valid(player) or not event.is_pressed() or event.is_echo(): return
	if event.is_action_pressed("arena_reset"):
		get_viewport().set_input_as_handled()
		restart()
	elif event.is_action_pressed("pause_game"):
		get_viewport().set_input_as_handled()
		if panel_kind == "defeat": leave()
		else: set_panel("pause" if panel_kind=="" else "")
	elif event.is_action_pressed("arena_panel") and panel_kind!="defeat":
		get_viewport().set_input_as_handled()
		set_panel("" if panel_kind=="controls" else "controls")
	elif event.is_action_pressed("arena_grid") and panel_kind!="defeat":
		get_viewport().set_input_as_handled()
		toggle_grid()

func _exit_tree() -> void:
	if DisplayServer.get_name() != "headless":
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		Input.set_custom_mouse_cursor(null, Input.CURSOR_CROSS)
