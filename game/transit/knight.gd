extends "res://actors/player.gd"

func _ready() -> void:
	super._ready()
	melee_profile = $Visual.weapon.melee_profile
	melee_contact_offset = Vector2(0,-116) * $Visual.scale

func _begin_action(id: StringName) -> bool:
	return super._begin_action(id) if id in [&"melee", &"guard", &"dodge"] else false
