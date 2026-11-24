extends "res://actors/player.gd"
const Weapon = preload("res://armory/weapon.gd")
const Item = preload("res://armory/item.gd")

func _ready() -> void:
	super._ready()
	melee_contact_offset = Vector2(0,-116) * $Visual.scale

func equip(weapon: Weapon, shoulder: Item) -> bool:
	if action != &"idle" or weapon == null or shoulder == null:
		return false
	if weapon.slot != Item.Slot.MAIN_HAND or shoulder.slot != Item.Slot.SHOULDER:
		return false
	$Visual.weapon = weapon
	$Visual.shoulder = shoulder
	melee_profile = weapon.melee_profile
	$Visual.queue_redraw()
	return true

func _update_aim_at(_cursor: Vector2) -> void:
	aim_direction = Vector2.RIGHT

func _unhandled_input(event: InputEvent) -> void:
	if input_enabled and event.is_action_pressed(&"melee") and not get_tree().paused:
		request_action(&"melee")
		get_viewport().set_input_as_handled()

func _begin_action(id: StringName) -> bool:
	if id != &"melee":
		return false
	# The fitting drill rehearses the opening stroke for each combination.
	_followup_left = 0.0
	return super._begin_action(id)
