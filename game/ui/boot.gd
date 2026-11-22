extends Node

const UI = preload("res://ui/palette.gd")
const Instruments = preload("res://ui/instrument_theme.gd")
const Preferences = preload("res://ui/preferences.gd")
const Arena = preload("res://arena/arena.gd")
const TITLE_ART_PATH := "res://art/menu/orbital_watch.jpg"
enum Session { MENU, ARENA }

var mode := Session.MENU
var prefs := Preferences.new()
var screen: Control
var settings_button: Button
var arena: Node2D
var overlay: ColorRect
var captured_action := ""
var bind_label: Label
var bind_buttons := {}
var swap_mouse: CheckButton

func _ready() -> void:
	prefs.setup()
	get_window().min_size = Vector2i(768,432)
	if "--arena" in OS.get_cmdline_user_args():
		enter_arena()
	else:
		main_menu()

func _drop(n: Node) -> void:
	if is_instance_valid(n):
		remove_child(n)
		n.queue_free()

func main_menu() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	mode = Session.MENU
	_drop(arena)
	arena = null
	_drop(screen)
	overlay = null
	screen = Control.new()
	screen.name = "MainMenu"
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var art := TextureRect.new()
	if ResourceLoader.exists(TITLE_ART_PATH):
		art.texture = load(TITLE_ART_PATH)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.place(art,screen,Vector2.ZERO,Vector2(1280,720))
	Instruments.mark(screen,Vector2(71,91),42)
	var command_label := UI.label("IMPERIAL FLEET COMMAND",14,UI.GOLD)
	command_label.add_theme_constant_override("outline_size",3)
	command_label.add_theme_color_override("font_outline_color",Color("#111b2cd9"))
	UI.place(command_label,screen,Vector2(128,101))
	_title_line("Imperial",Vector2(65,136))
	_title_line("Space",Vector2(65,226))
	UI.rule(screen,72,363,335,Color("#c49b69"))
	var start:=Instruments.button("Developer Arena",enter_arena,true)
	UI.place(start,screen,Vector2(72,394),Vector2(306,55))
	start.grab_focus()
	settings_button=Instruments.button("Settings",show_settings)
	UI.place(settings_button,screen,Vector2(72,460),Vector2(148,42))
	UI.place(Instruments.button("Quit",func(): get_tree().quit()),screen,Vector2(230,460),Vector2(148,42))
	var build := UI.label("Development build  " + str(ProjectSettings.get_setting("application/config/version")),14,UI.PAPER)
	build.add_theme_constant_override("outline_size",4)
	build.add_theme_color_override("font_outline_color",Color("#111b2ce0"))
	UI.place(build,screen,Vector2(72,660))

func _title_line(value: String, at: Vector2) -> void:
	var title := UI.label(value,100,Color("#fff0cd"),true)
	title.add_theme_color_override("font_shadow_color",Color("#0b1428cc"))
	title.add_theme_constant_override("shadow_offset_x",2)
	title.add_theme_constant_override("shadow_offset_y",4)
	title.add_theme_constant_override("shadow_outline_size",2)
	UI.place(title,screen,at)

func enter_arena() -> void:
	mode = Session.ARENA
	_drop(screen)
	screen = null
	arena = Arena.new()
	arena.name = "DeveloperArena"
	arena.prefs = prefs
	arena.exit_requested.connect(main_menu)
	add_child(arena)

func show_settings() -> void:
	if is_instance_valid(overlay): return
	overlay = ColorRect.new()
	overlay.name = "Settings"
	overlay.color = Color("#050b11e8")
	UI.place(overlay,screen,Vector2.ZERO,Vector2(1280,720))
	# A modal captures navigation focus as well as clicks.
	for c: Node in screen.get_children():
		if c is Button: c.focus_mode = Control.FOCUS_NONE
	var pane := Instruments.frame(overlay,Vector2(306,56),Vector2(668,608))
	UI.place(UI.label("Settings",38,UI.PAPER,true),pane,Vector2(30,18))
	UI.place(UI.label("Master volume",16,UI.SOFT),pane,Vector2(32,91))
	var volume := HSlider.new()
	volume.max_value=1.0
	volume.step=.01
	volume.value=float(prefs.config.get_value("sound","volume",.75))
	volume.value_changed.connect(prefs.set_audio)
	UI.place(volume,pane,Vector2(222,88),Vector2(219,35))
	var full := CheckButton.new()
	full.text = "Fullscreen"
	full.button_pressed = bool(prefs.config.get_value("display","fullscreen",false))
	full.toggled.connect(prefs.set_fullscreen)
	UI.place(full,pane,Vector2(469,84))
	UI.rule(pane,30,142,608,Color("#4b5b60"))
	UI.place(UI.label("Keyboard bindings",24,UI.PAPER,true),pane,Vector2(30,157))
	UI.place(UI.label("Select an action, then press a key.",14,UI.SOFT),pane,Vector2(32,198))
	bind_buttons.clear()
	var i := 0
	for action: String in Preferences.KEYS:
		var col := i / 6
		var row := i % 6
		var pos := Vector2(32+col*306,238+row*43)
		UI.place(UI.label(Preferences.NAMES[action],15),pane,pos+Vector2(0,6))
		var b := Instruments.button(prefs.key_text(action),_capture.bind(action))
		UI.place(b,pane,pos+Vector2(151,0),Vector2(112,35))
		bind_buttons[action]=b
		i+=1
	bind_label=UI.label(_mouse_legend(),14,UI.SOFT)
	UI.place(bind_label,pane,Vector2(32,510))
	swap_mouse=CheckButton.new()
	swap_mouse.text="Swap mouse buttons"
	swap_mouse.button_pressed=bool(prefs.config.get_value("controls","swap_mouse",false))
	swap_mouse.toggled.connect(func(value: bool):
		prefs.set_mouse_swap(value)
		bind_label.text=_mouse_legend())
	UI.place(swap_mouse,pane,Vector2(449,500),Vector2(189,36))
	var reset := Instruments.button("Default bindings",func():
		prefs.reset_bindings()
		swap_mouse.set_pressed_no_signal(false)
		captured_action=""
		for key:String in bind_buttons: bind_buttons[key].text=prefs.key_text(key)
		bind_label.text="Default bindings restored.")
	UI.place(reset,pane,Vector2(32,546),Vector2(167,40))
	var guard := CheckButton.new()
	guard.text="Toggle guard"
	guard.button_pressed=bool(prefs.config.get_value("controls","toggle_guard",false))
	guard.toggled.connect(prefs.set_guard_toggle)
	UI.place(guard,pane,Vector2(228,546),Vector2(176,40))
	var back := Instruments.button("Done",_close_settings,true)
	UI.place(back,pane,Vector2(490,546),Vector2(146,40))
	back.grab_focus()

func _mouse_legend() -> String:
	return "Mouse   %s  Fire     •     %s  Sword" % [prefs.mouse_text("fire"),prefs.mouse_text("melee")]

func _capture(action: String) -> void:
	captured_action=action
	bind_label.text="Press a key for "+Preferences.NAMES[action]+".   Esc cancels."

func _close_settings() -> void:
	if not is_instance_valid(overlay): return
	captured_action=""
	overlay.get_parent().remove_child(overlay)
	overlay.queue_free()
	overlay=null
	for c: Node in screen.get_children():
		if c is Button: c.focus_mode = Control.FOCUS_ALL
	settings_button.grab_focus()

func _input(event: InputEvent) -> void:
	if not is_instance_valid(overlay): return
	if event is InputEventKey and event.pressed and not event.echo:
		if not captured_action.is_empty():
			get_viewport().set_input_as_handled()
			if event.keycode == KEY_ESCAPE:
				captured_action=""
				bind_label.text="Binding cancelled."
			elif prefs.rebind(captured_action,event.physical_keycode):
				bind_buttons[captured_action].text=prefs.key_text(captured_action)
				captured_action=""
				bind_label.text="Binding saved."
			else: bind_label.text="That key is already assigned. Choose another."
		elif event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_close_settings()
