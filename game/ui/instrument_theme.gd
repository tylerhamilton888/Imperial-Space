extends RefCounted
## Brass-edged range instruments, shared by the title screen and the arena.
const UI = preload("res://ui/palette.gd")
const FRAME: Texture2D = preload("res://art/hud/frame.webp")
const CREST: Texture2D = preload("res://art/hud/fleet_crest.webp")
const BUTTON_EDGE := Color("#796340")

static func frame(parent: Node, pos: Vector2, extent: Vector2) -> Panel:
	var panel := Panel.new()
	var skin := StyleBoxTexture.new()
	skin.texture = FRAME
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		skin.set_texture_margin(side, 22)
		skin.set_content_margin(side, 11)
	panel.add_theme_stylebox_override("panel", skin)
	UI.place(panel, parent, pos, extent)
	return panel

static func button(caption: String, callback: Callable, primary := false) -> Button:
	var node := UI.button(caption,callback,primary)
	var body := UI.box(Color("#bc995e") if primary else Color("#18212b"), BUTTON_EDGE, 1)
	body.set_corner_radius_all(3)
	body.shadow_color = Color("#06081082")
	body.shadow_size = 1
	node.add_theme_stylebox_override("normal",body)
	node.add_theme_color_override("font_color",Color("#1c1918") if primary else UI.PAPER)
	var hover := UI.box(Color("#efce91"),Color("#ffe4ab"),1)
	hover.set_corner_radius_all(3)
	node.add_theme_stylebox_override("hover",hover)
	node.add_theme_stylebox_override("pressed",UI.box(Color("#a88859"),Color("#5e4732"),1))
	var focus := UI.box(Color.TRANSPARENT,Color("#d9b980"),2)
	focus.set_corner_radius_all(3)
	node.add_theme_stylebox_override("focus",focus)
	return node

static func selector(node: OptionButton) -> void:
	node.add_theme_stylebox_override("normal",UI.box(Color("#171e27"),BUTTON_EDGE,1))
	node.add_theme_stylebox_override("hover",UI.box(Color("#34312e"),UI.GOLD,1))
	node.add_theme_color_override("font_color",UI.PAPER)

static func mark(parent: Node, pos: Vector2, side: int) -> void:
	var device := TextureRect.new()
	device.texture = CREST
	device.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	device.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.place(device, parent, pos, Vector2(side,side))
