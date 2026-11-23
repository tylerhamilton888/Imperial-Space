extends RefCounted

const FILE := "user://settings.cfg"
const KEYS := {"move_up": KEY_W, "move_left": KEY_A, "move_down": KEY_S, "move_right": KEY_D, "dodge": KEY_SPACE, "guard": KEY_SHIFT, "reload": KEY_R, "heal": KEY_Q, "arena_panel": KEY_F1, "arena_reset": KEY_F5, "arena_grid": KEY_G}
const NAMES := {"move_up":"Move up", "move_left":"Move left", "move_down":"Move down", "move_right":"Move right", "dodge":"Dodge", "guard":"Guard / parry", "reload":"Reload", "heal":"Medical charge", "arena_panel":"Range controls", "arena_reset":"Restart scenario", "arena_grid":"Scale grid"}
var config := ConfigFile.new()

func setup() -> void:
	config.load(FILE)
	var used := {}
	for action: String in KEYS:
		var code := int(config.get_value("keyboard", action, KEYS[action]))
		if code <= 0 or code == KEY_ESCAPE or used.has(code):
			# An invalid hand-edited file must never remove a basic control.
			config.erase_section("keyboard")
			break
		used[code] = true
	for action: String in KEYS:
		_bind_key(action, int(config.get_value("keyboard", action, KEYS[action])))
	_bind_key("pause_game", KEY_ESCAPE)
	set_mouse_swap(bool(config.get_value("controls","swap_mouse",false)), false)
	set_audio(float(config.get_value("sound","volume",0.75)), false)
	set_fullscreen(bool(config.get_value("display","fullscreen",false)), false)

func _bind_key(action: String, code: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	var key := InputEventKey.new()
	key.physical_keycode = code as Key
	InputMap.action_add_event(action, key)

func key_text(action: String) -> String:
	var key: InputEventKey = InputMap.action_get_events(action)[0]
	var code:=key.physical_keycode
	if DisplayServer.get_name()!="headless":
		code=DisplayServer.keyboard_get_keycode_from_physical(code)
	return OS.get_keycode_string(code)

func rebind(action: String, code: int) -> bool:
	if code <= 0 or code == KEY_ESCAPE: return false
	for other: String in KEYS:
		var k: InputEventKey = InputMap.action_get_events(other)[0]
		if other != action and k.physical_keycode == code: return false
	_bind_key(action, code)
	config.set_value("keyboard",action,code)
	config.save(FILE)
	return true

func mouse_text(action: String) -> String:
	var btn: InputEventMouseButton = InputMap.action_get_events(action)[0]
	return "LMB" if btn.button_index == MOUSE_BUTTON_LEFT else "RMB"

func set_mouse_swap(swapped: bool, persist := true) -> void:
	for action: String in ["fire","melee"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT if (action == "fire") != swapped else MOUSE_BUTTON_RIGHT
		InputMap.action_add_event(action, mouse)
	config.set_value("controls","swap_mouse",swapped)
	if persist: config.save(FILE)

func reset_bindings() -> void:
	set_mouse_swap(false,false)
	if config.has_section("keyboard"): config.erase_section("keyboard")
	for action: String in KEYS:
		_bind_key(action, KEYS[action])
	config.save(FILE)

func set_guard_toggle(value: bool) -> void:
	config.set_value("controls","toggle_guard",value)
	config.save(FILE)

func set_audio(value: float, persist := true) -> void:
	value = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(.001,value)))
	AudioServer.set_bus_mute(0,value <= .001)
	config.set_value("sound","volume",value)
	if persist: config.save(FILE)

func set_fullscreen(on: bool, persist := true) -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value("display","fullscreen",on)
	if persist: config.save(FILE)

func set_impact_camera(on: bool) -> void:
	config.set_value("display", "impact_camera", on)
	config.save(FILE)
