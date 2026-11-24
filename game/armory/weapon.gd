extends "res://armory/item.gd"
const Profile = preload("res://combat/medium_kit.gd")
@export var melee_profile: Profile
## Optional pitch correction for each of the right-facing body keys.
@export var pose_angles: PackedFloat32Array
