extends Node2D

const PANEL := preload("../kits/interface/imperial_panel.tres")
const SCENES := ["proving_ground", "karth_vale", "cruiser_bridge", "heavy_proving_ground"]
const TITLES := ["Proving ground", "Karth Vale", "Cruiser bridge", "Heavy armor"]
const POSES := ["Cannon ready", "Cannon reverse", "Hammer ready", "Hammer raised"]
const WEAPONS := ["rifle", "sword", "dodge", "guard", "grenade", "medical"]
const HEAVY_WEAPONS := ["cannon", "hammer", "dodge", "guard", "impact", "medical"]

var world: Node2D
var view_index := 0
var heavy_pose := 0
var breached := true
var targets_visible := true
var terminal_visible := true
var serif := SystemFont.new()

func _ready() -> void:
	serif.font_names = PackedStringArray(["Georgia", "Liberation Serif", "DejaVu Serif"])
	show_view(0)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			show_view(event.keycode - KEY_1)
		elif event.keycode == KEY_V and view_index == 3:
			advance_pose()
		elif event.keycode == KEY_B and view_index in [0, 3]:
			toggle_wall()

func show_view(index: int) -> void:
	view_index = index
	if world:
		remove_child(world)
		world.queue_free()
	world = (load("res://review/%s.tscn" % SCENES[index]) as PackedScene).instantiate()
	add_child(world)
	refresh_controls()

func refresh_controls() -> void:
	for child in $Interface.get_children():
		$Interface.remove_child(child)
		child.queue_free()
	var bar := panel(Rect2(343, 8, 586, 42))
	for i in TITLES.size():
		button(bar, Rect2(7 + i*144, 5, 140, 32), TITLES[i], show_view.bind(i), i == view_index)
	var title := panel(Rect2(12, 12, 272, 52))
	label(title, Rect2(16, 6, 254, 35), ["IMPERIAL PROVING GROUND", "KARTH VALE", "CRUISER BRIDGE", "IMPERIAL PROVING GROUND"][view_index], 17)
	if view_index == 2:
		show_dialogue()
		return
	var readouts := preload("../kits/interface/combat_readouts.tscn").instantiate()
	readouts.position = Vector2(12, 650)
	$Interface.add_child(readouts)
	if view_index in [0, 3]:
		readouts.get_node("Magazine").position.x = 852
		readouts.get_node("Health/Value").text = "1000 / 1000"
		readouts.get_node("Health/Bar").value = 1000
		readouts.get_node("Magazine/Value").text = "20 / 80" if view_index == 3 else "12 / 84"
	var icons: Array = HEAVY_WEAPONS if view_index == 3 else WEAPONS
	var strip := panel(Rect2(445, 646, 390, 66))
	for i in icons.size():
		picture(strip, Rect2(8 + 63*i, 5, 58, 44), icons[i])
		var binding := label(strip, Rect2(8 + 63*i, 47, 58, 17), ["LMB","RMB","SPACE","SHIFT","1","Q"][i], 12)
		binding.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if view_index in [0, 3]:
		show_range_panel()

func show_range_panel() -> void:
	var side := panel(Rect2(1038, 9, 232, 702))
	label(side, Rect2(14, 20, 210, 30), "DEVELOPER ARENA", 21)
	label(side, Rect2(16, 75, 203, 26), "ARMOR STUDY", 15)
	button(side, Rect2(15, 110, 97, 34), "Medium", show_view.bind(0), view_index == 0)
	button(side, Rect2(118, 110, 97, 34), "Heavy", show_view.bind(3), view_index == 3)
	if view_index == 3:
		label(side, Rect2(16, 175, 200, 26), "WEAPON POSE", 15)
		button(side, Rect2(15, 210, 200, 36), POSES[heavy_pose] + "  ›", advance_pose)
		for i in POSES.size():
			world.get_node("Actors/Heavy%d" % i).visible = i == heavy_pose
	label(side, Rect2(16, 438, 204, 26), "RANGE FIXTURES", 15)
	button(side, Rect2(15, 475, 200, 36), "Hide targets" if targets_visible else "Show targets", toggle_targets)
	button(side, Rect2(15, 522, 200, 36), "Hide terminal" if terminal_visible else "Show terminal", toggle_terminal)
	world.get_node("Actors/TargetOne").visible = targets_visible
	world.get_node("Actors/TargetTwo").visible = targets_visible
	world.get_node("Actors/Terminal").visible = terminal_visible
	label(side, Rect2(16, 300, 200, 26), "BREACH FIXTURE", 15)
	button(side, Rect2(15, 337, 200, 36), "Restore wall" if breached else "Show breach", toggle_wall)
	world.get_node("Actors/WallIntact").visible = not breached
	world.get_node("Actors/WallBreached").visible = breached

func advance_pose() -> void:
	heavy_pose = (heavy_pose + 1) % POSES.size()
	refresh_controls()

func toggle_targets() -> void:
	targets_visible = not targets_visible
	refresh_controls()

func toggle_terminal() -> void:
	terminal_visible = not terminal_visible
	refresh_controls()

func toggle_wall() -> void:
	breached = not breached
	refresh_controls()

func show_dialogue() -> void:
	var box := preload("../kits/interface/dialogue_panel.tscn").instantiate() as Panel
	box.position = Vector2(12, 513)
	$Interface.add_child(box)

func panel(bounds: Rect2) -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", PANEL)
	p.position = bounds.position
	p.size = bounds.size
	$Interface.add_child(p)
	return p

func label(parent: Control, bounds: Rect2, caption: String, point_size: int) -> Label:
	var item := Label.new()
	item.text = caption
	item.add_theme_font_override("font", serif)
	item.add_theme_font_size_override("font_size", point_size)
	item.add_theme_color_override("font_color", Color("#efdbb0"))
	item.position = bounds.position
	item.size = bounds.size
	parent.add_child(item)
	return item

func button(parent: Control, bounds: Rect2, caption: String, callback: Callable, selected := false) -> void:
	var item := Button.new()
	item.text = caption
	item.add_theme_font_override("font", serif)
	item.add_theme_font_size_override("font_size", 15)
	var skin := PANEL.duplicate() as StyleBoxFlat
	skin.bg_color = Color("#805d2b") if selected else Color("#293138")
	skin.shadow_size = 0
	item.add_theme_stylebox_override("normal", skin)
	item.position = bounds.position
	item.size = bounds.size
	item.pressed.connect(callback)
	parent.add_child(item)

func picture(parent: Control, bounds: Rect2, asset: String) -> void:
	var item := TextureRect.new()
	item.texture = load("res://kits/interface/%s.webp" % asset)
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item.position = bounds.position
	item.size = bounds.size
	parent.add_child(item)
