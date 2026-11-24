extends Node2D
signal exit_requested
const UI = preload("res://ui/palette.gd")
const Trim = preload("res://ui/instrument_theme.gd")
const Knight = preload("res://armory/knight.tscn")
const Target = preload("res://armory/target.gd")
const FLOOR = preload("res://armory/forecourt.webp")
const TROOPER = preload("res://armory/trooper_front_three_quarter.png")
const RAIDER = preload("res://armory/khorgoth_raider.png")
const COVER = preload("res://armory/barricade.png")
const WEAPONS = [preload("res://armory/sword.tres"), preload("res://armory/warhammer.tres")]
const SHOULDERS = [preload("res://armory/plate.tres"), preload("res://armory/wing.tres")]
var knight
var target
var weapon_index := 0
var shoulder_index := 0
var weapon_button: Button
var shoulder_button: Button
var status: Label
var hit_count := 0

func _ready() -> void:
	y_sort_enabled = true
	var floor_art := Sprite2D.new()
	floor_art.texture = FLOOR
	floor_art.centered = false
	floor_art.z_index = -3
	add_child(floor_art)
	for bounds: Rect2 in [Rect2(0,170,1280,20),Rect2(0,638,1280,22),Rect2(60,170,22,490),Rect2(1198,170,22,490)]:
		var wall := StaticBody2D.new()
		wall.position = bounds.get_center()
		add_child(wall)
		_solid(wall,bounds.size)
	var cover := StaticBody2D.new()
	cover.position = Vector2(552,520)
	add_child(cover)
	_solid(cover,Vector2(88,23))
	_paint(cover,COVER)
	var trooper := StaticBody2D.new()
	trooper.position = Vector2(416,461)
	add_child(trooper)
	_solid(trooper,Vector2(19,12))
	_paint(trooper,TROOPER)
	target = Target.new()
	target.position = Vector2(741,461)
	target.collision_layer = 4
	target.collision_mask = 0
	add_child(target)
	target.add_to_group(&"combatants")
	_solid(target,Vector2(30,17))
	_paint(target,RAIDER)
	target.struck.connect(_hit)
	knight = Knight.instantiate()
	knight.position = Vector2(572,461)
	add_child(knight)
	knight.equip(WEAPONS[0],SHOULDERS[0])
	var overlay := CanvasLayer.new()
	add_child(overlay)
	var top := Trim.frame(overlay,Vector2(26,20),Vector2(358,70))
	UI.place(UI.label("Armory trial",24,UI.PAPER,true),top,Vector2(18,7))
	UI.place(UI.label("Strike the Khorgoth training target",15,UI.SOFT),top,Vector2(18,39))
	UI.place(Trim.button("Return",func(): exit_requested.emit()),overlay,Vector2(1134,25),Vector2(118,40))
	var loadout := Trim.frame(overlay,Vector2(215,619),Vector2(850,84))
	weapon_button = Trim.button("",swap.bind(true))
	shoulder_button = Trim.button("",swap.bind(false))
	UI.place(weapon_button,loadout,Vector2(15,9),Vector2(205,36))
	UI.place(shoulder_button,loadout,Vector2(230,9),Vector2(205,36))
	status = UI.label("Move into reach",16,UI.GOLD)
	UI.place(status,loadout,Vector2(465,16))
	var melee_buttons := InputMap.action_get_events(&"melee")
	var control_name := ""
	for binding in melee_buttons:
		if binding is InputEventMouseButton:
			control_name = "Right-click" if binding.button_index == MOUSE_BUTTON_RIGHT else "Left-click"
	UI.place(UI.label("WASD  Move     •     %s  Strike     •     1  Weapon     •     2  Shoulder" % control_name,15,UI.PAPER),loadout,Vector2(20,51))
	_refresh()

func _solid(body: StaticBody2D, size: Vector2) -> void:
	var box := RectangleShape2D.new()
	box.size = size
	var collision := CollisionShape2D.new()
	collision.shape = box
	body.add_child(collision)

func _paint(owner_node: Node2D, texture: Texture2D) -> void:
	var shadow := Polygon2D.new()
	shadow.color = Color(0.10,0.08,0.11,0.24)
	var points := PackedVector2Array()
	var radius := 46.0 if texture == COVER else 15.0
	for i in 16:
		points.append(Vector2(cos(TAU*i/16)*radius,sin(TAU*i/16)*6+2))
	shadow.polygon = points
	owner_node.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.name = "Paint"
	sprite.centered = false
	sprite.offset = Vector2(-128,-181)
	sprite.texture = texture
	owner_node.add_child(sprite)

func swap(weapon_slot: bool) -> void:
	var w := (1-weapon_index) if weapon_slot else weapon_index
	var s := shoulder_index if weapon_slot else (1-shoulder_index)
	if knight.equip(WEAPONS[w],SHOULDERS[s]):
		weapon_index = w
		shoulder_index = s
		_refresh()
	else:
		status.text = "Finish the swing to change gear"

func _refresh() -> void:
	weapon_button.text = "Weapon   ·   "+WEAPONS[weapon_index].title
	shoulder_button.text = "Shoulder   ·   "+SHOULDERS[shoulder_index].title

func _hit(damage: int) -> void:
	hit_count += 1
	status.text = "%d damage   ·   %d hits" % [damage,hit_count]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: swap(true)
			KEY_2: swap(false)
			KEY_ESCAPE: exit_requested.emit()
			_: return
		get_viewport().set_input_as_handled()
