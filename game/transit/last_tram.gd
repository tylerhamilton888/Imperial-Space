extends Node2D
signal exit_requested
signal replay_requested
const UI = preload("res://ui/palette.gd")
const Trim = preload("res://ui/instrument_theme.gd")
const Knight = preload("res://transit/knight.tscn")
const Pursuer = preload("res://transit/pursuer.tscn")
const Signalman = preload("res://transit/signalman.gd")
const Platform = preload("res://transit/platform.gd")
const Car = preload("res://transit/car.webp")
const Clank = preload("res://transit/switch.ogg")
const Bell = preload("res://transit/departure.ogg")
const Air = preload("res://transit/station_air.ogg")
enum Phase { WAITING, HOLD, DEPARTING, CLEAR, LOST }
const STROKE_TIME := 3.45
var prefs: RefCounted
var phase := Phase.WAITING
var age := 0.0
var work := 0.0
var locks := 0
var second_arrived := false
var interrupted := 0.0
var knight
var operator: Signalman
var car: Sprite2D
var threats: Array[CharacterBody2D] = []
var heading: Label
var objective: Label
var condition: Label
var voice: Label
var caption_time := 0.0
var replay: Button
var ambient: AudioStreamPlayer
var dispatch_light: Polygon2D
var camera := Camera2D.new()
var player_hits := 0
var parries := 0

func _ready() -> void:
	y_sort_enabled = true
	camera.position = Vector2(640,360)
	add_child(camera)
	camera.make_current()
	var station := Platform.new()
	station.z_index = -5
	add_child(station)
	car = _sprite(Car,Vector2(610,330),Vector2(-243,-160))
	car.z_index = -3
	_sprite(preload("res://transit/west_lamp.png"),Vector2(48,271),Vector2.ZERO).z_index = -2
	_sprite(preload("res://transit/east_lamp.png"),Vector2(1191,270),Vector2.ZERO).z_index = -2
	for bounds: Rect2 in [Rect2(-50,320,1380,30),Rect2(-50,555,1380,40),Rect2(-30,320,55,265),Rect2(1255,320,55,265),Rect2(26,445,114,109),Rect2(1030,474,225,80)]:
		_wall(bounds)
	knight = Knight.instantiate()
	knight.position = Vector2(405,477)
	knight.guard_toggle = bool(prefs.config.get_value("controls","toggle_guard",false))
	add_child(knight)
	knight.died.connect(_lose.bind("The Knight fell. The last car is still on the platform."))
	knight.stats_changed.connect(_condition)
	knight.combat_event.connect(_combat_event)
	operator = Signalman.new()
	operator.position = Vector2(626,409)
	add_child(operator)
	operator.wounded.connect(_wounded)
	operator.fell.connect(_lose.bind("The signalman is down. The line is still locked."))
	dispatch_light = Polygon2D.new()
	var ring := PackedVector2Array()
	for i in 16: ring.append(Vector2.from_angle(TAU*i/16)*4)
	dispatch_light.polygon = ring
	dispatch_light.color = Color("#ff7145")
	dispatch_light.position = operator.position+Vector2(34,-19)
	dispatch_light.z_index = 2
	add_child(dispatch_light)
	_hud()
	ambient = AudioStreamPlayer.new()
	ambient.stream = Air
	ambient.volume_db = -13
	add_child(ambient)
	ambient.finished.connect(ambient.play)
	ambient.play()
	_say("Signalman", "The points are jammed. Knight, over here!",5.0)
	_condition()

func _sprite(paint: Texture2D, pos: Vector2, offset: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = paint
	sprite.offset = offset
	sprite.position = pos
	add_child(sprite)
	return sprite

func _wall(box: Rect2) -> void:
	var wall := StaticBody2D.new()
	wall.position = box.get_center()
	var shape := RectangleShape2D.new()
	shape.size = box.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	wall.add_child(collision)
	add_child(wall)

func _hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var plaque := Trim.frame(layer,Vector2(22,18),Vector2(395,80))
	heading = UI.label("Karth Vale   /   The Last Tram",23,UI.PAPER,true)
	UI.place(heading,plaque,Vector2(16,7))
	objective = UI.label("Reach the signalman at the track lever",16,UI.GOLD)
	UI.place(objective,plaque,Vector2(17,46))
	UI.place(Trim.button("Return",func(): exit_requested.emit()),layer,Vector2(1151,21),Vector2(106,38))
	var rail := Trim.frame(layer,Vector2(16,643),Vector2(1248,64))
	condition = UI.label("",16,UI.PAPER)
	UI.place(condition,rail,Vector2(16,6))
	var move_hint := "%s%s%s%s" % [prefs.key_text("move_up"),prefs.key_text("move_left"),prefs.key_text("move_down"),prefs.key_text("move_right")]
	var controls := "%s  Move      %s  Strike      %s  Guard / parry      %s  Dodge" % [move_hint,prefs.mouse_text("melee"),prefs.key_text("guard"),prefs.key_text("dodge")]
	UI.place(UI.label(controls,15,UI.SOFT),rail,Vector2(16,34))
	voice = UI.label("",19,UI.PAPER,true)
	voice.add_theme_constant_override("outline_size",5)
	voice.add_theme_color_override("font_outline_color",Color("#192026"))
	UI.place(voice,layer,Vector2(32,602))
	replay = Trim.button("Play again",func(): replay_requested.emit(),true)
	UI.place(replay,rail,Vector2(1055,10),Vector2(167,42))
	replay.hide()

func _condition() -> void:
	if condition:
		condition.text = "Knight   %d / %d        Signalman   %d / 69" % [knight.health,knight.max_health,operator.health]

func _combat_event(kind: StringName, _from: Vector2, _to: Vector2) -> void:
	if kind in [&"parried",&"riposte",&"cut_landed",&"return_cut"] and prefs.config.get_value("display","impact_camera",true):
		camera.offset = -knight.aim_direction * (3.5 if kind == &"riposte" else 1.8)
	if kind == &"parried": parries += 1
	if kind in [&"cut_landed",&"riposte",&"return_cut"]: player_hits += 1

func _say(speaker: String, words: String, duration: float) -> void:
	voice.text = "%s   “%s”" % [speaker,words]
	caption_time = duration

func _sound(stream: AudioStream, db: float) -> void:
	var sound := AudioStreamPlayer.new()
	sound.stream = stream
	sound.volume_db = db
	add_child(sound)
	sound.finished.connect(sound.queue_free)
	sound.play()

func _spawn(at: Vector2) -> void:
	var enemy = Pursuer.instantiate()
	enemy.role = &"raider"
	enemy.operator = operator
	enemy.knight = knight
	enemy.position = at
	add_child(enemy)
	threats.append(enemy)

func _begin() -> void:
	phase = Phase.HOLD
	age = 0
	objective.text = "Protect the signalman   ·   0 / 3 locks"
	_say("Signalman","Hold them off. I can throw the points by hand.",3.3)
	_spawn(Vector2(947,447))

func _physics_process(delta: float) -> void:
	camera.offset = camera.offset.move_toward(Vector2.ZERO,delta*39.0)
	age += delta
	caption_time -= delta
	if caption_time <= 0: voice.text = ""
	match phase:
		Phase.WAITING:
			if knight.position.distance_to(operator.position)<160: _begin()
		Phase.HOLD:
			if age >= 3.8 and not second_arrived:
				second_arrived = true
				_spawn(Vector2(150,435))
				_say("Signalman","Another one, by the luggage!",2.4)
			interrupted = maxf(0,interrupted-delta)
			if interrupted > 0: return
			work += delta
			operator.key = 1 if fmod(work,STROKE_TIME) > STROKE_TIME*.51 else 0
			var finished := floori(work/STROKE_TIME)
			if finished > locks:
				locks = finished
				_sound(Clank,-4)
				objective.text = "Protect the signalman   ·   %d / 3 locks" % locks
				if locks == 3: _depart()
		Phase.DEPARTING:
			car.position.x = 610.0 - 90.0*age*age
			if car.position.x < -250:
				phase = Phase.CLEAR
				objective.text = "Evacuation complete"
				_say("Transit control","Last car clear. Everyone aboard is through.",6.0)
				replay.show()

func _wounded() -> void:
	if phase != Phase.HOLD: return
	interrupted = 0.65
	_condition()
	_say("Signalman","Get him off the lever!",1.8)

func _end_fighting() -> void:
	for enemy in threats:
		if is_instance_valid(enemy) and enemy.state != &"dead":
			enemy.retreating = true
			enemy.collision_mask = 0
			enemy.collision_layer = 0
			enemy.remove_from_group(&"enemies")

func _depart() -> void:
	phase = Phase.DEPARTING
	age = 0.0
	operator.key = 2
	dispatch_light.color = Color("#88f3a3")
	_sound(Bell,-2)
	_say("Signalman","Line clear! Take her out!",3.0)
	objective.text = "The last tram is leaving"
	_end_fighting()

func _lose(message: String) -> void:
	if phase not in [Phase.WAITING,Phase.HOLD]: return
	phase = Phase.LOST
	_condition()
	_end_fighting()
	voice.text = message
	caption_time = 60.0
	objective.text = "Evacuation stalled"
	replay.show()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"arena_reset"):
		get_viewport().set_input_as_handled()
		replay_requested.emit()
	elif event.is_action_pressed(&"pause_game"):
		get_viewport().set_input_as_handled()
		exit_requested.emit()
