extends RefCounted

const INK := Color("#102028")
const PAPER := Color("#f2e9d5")
const SOFT := Color("#b1c0be")
const GOLD := Color("#dfb277")
const CYAN := Color("#8ed3d0")
const ICON = preload("res://art/standard.svg")

static func box(fill: Color, edge: Color = Color.TRANSPARENT, width: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = edge
	s.set_border_width_all(width)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 7
	s.content_margin_bottom = 7
	return s

static func label(value: String, size: int = 16, color: Color = PAPER, title: bool = false) -> Label:
	var l := Label.new()
	l.text = value
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if title:
		var f := SystemFont.new()
		f.font_names = PackedStringArray(["Georgia", "Liberation Serif", "DejaVu Serif", "Times New Roman"])
		l.add_theme_font_override("font", f)
	return l

static func button(caption: String, callback: Callable, primary := false) -> Button:
	var b := Button.new()
	b.text = caption
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size.y = 38
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_color_override("font_color", INK if primary else PAPER)
	b.add_theme_color_override("font_focus_color", INK if primary else PAPER)
	b.add_theme_color_override("font_hover_color", Color("#111d23"))
	b.add_theme_color_override("font_hover_pressed_color", INK)
	b.add_theme_color_override("font_pressed_color", INK)
	b.add_theme_stylebox_override("normal", box(GOLD if primary else Color("#1d3039"), Color("#44545b"), 0 if primary else 1))
	b.add_theme_stylebox_override("hover", box(Color("#e9c597")))
	b.add_theme_stylebox_override("pressed", box(CYAN))
	var focus := box(Color.TRANSPARENT, CYAN, 2)
	b.add_theme_stylebox_override("focus", focus)
	b.pressed.connect(callback)
	return b

static func place(c: Control, parent: Node, pos: Vector2, extent: Vector2 = Vector2.ZERO) -> void:
	parent.add_child(c)
	c.position = pos
	c.size = extent

static func panel(parent: Node, pos: Vector2, extent: Vector2, color := Color("#102029f5")) -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", box(color, Color("#4b5b60"), 1))
	place(p, parent, pos, extent)
	return p

static func rule(parent: Node, x: float, y: float, width: float, color: Color) -> void:
	var bar := ColorRect.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.color = color
	place(bar, parent, Vector2(x,y), Vector2(width,1))

static func mark(parent: Node, pos: Vector2, side: int) -> void:
	var icon := TextureRect.new()
	icon.texture = ICON
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(icon, parent, pos, Vector2(side,side))
