extends StaticBody2D
## A painted fixture owns a single removable footprint. Neighboring solids survive its breach.
signal opened
signal integrity_changed

const Vitality = preload("res://combat/vitality.gd")
const Feedback = preload("res://combat/feedback.gd")
const Fragment = preload("res://combat/impact_fragment.gd")
const Profile = preload("res://combat/fixture_profile.gd")
@export var profile: Profile = preload("res://arena/proving/shutter.tres")
@onready var vitality := Vitality.new(profile.capacity)
var phase := 0
var is_open := false
var impact_left := 0.0
var scars := PackedVector2Array()
var surface_mask := BitMap.new()

func _ready() -> void:
	add_to_group("aim_fixtures")
	set_process(false)
	_refresh_mask()

func _refresh_mask() -> void:
	var image := profile.plates[phase].get_image()
	if image != null and not image.is_empty():
		surface_mask.create_from_image_alpha(image)

func get_aim_bounds() -> Rect2:
	return profile.aim_bounds

func impact_surface(ground_contact: Vector2) -> Vector2:
	var x := clampf(ground_contact.x-global_position.x, profile.surface_width.x,profile.surface_width.y)
	return global_position + Vector2(x,-profile.contact_height)

func receive_hit(source: Node2D, attack_id: int, amount: int, kind: StringName, direction: Vector2) -> StringName:
	return receive_hit_at(source,attack_id,amount,kind,direction,global_position)

func receive_hit_at(source: Node2D, attack_id: int, amount: int, _kind: StringName, direction: Vector2, ground_contact: Vector2) -> StringName:
	var result := vitality.apply(source, attack_id, amount)
	if result != &"hit" and result != &"killed":
		return result
	var previous := phase
	if vitality.health == 0:
		phase = 3
	elif vitality.health <= profile.capacity / 2:
		phase = 2
	elif vitality.health <= 3 * profile.capacity / 4:
		phase = 1
	if phase != previous and phase < 3:
		_refresh_mask()
	impact_left = 0.10
	set_process(true)
	var surface := impact_surface(ground_contact)
	var x := surface.x-global_position.x
	if result == &"hit" and scars.size() < 12:
		var nick := to_local(surface) + Vector2(sin(attack_id*2.9)*4,cos(attack_id*1.7)*3)
		scars.append(nick)
	var cue := &"shutter_break" if phase == 3 else &"shutter_tear" if phase > previous else &"hit"
	if profile.masonry:
		cue = &"stone_break" if phase == 3 else &"stone_hit"
	Feedback.play(self,cue,surface,surface)
	if result == &"killed":
		is_open = true
		collision_layer = 0
		remove_from_group("aim_fixtures")
		opened.emit()
	# A closed panel sheds material back toward the shooter. The last shot
	# carries the broken slats through the newly opened lane.
	var away := direction.normalized() if is_open else -direction.normalized()
	var edge := Vector2(x,11.0 if away.y >= 0 else -11.0)
	Fragment.shed_fixture(get_parent().get_parent(),global_position+edge,away,profile.contact_height+edge.y,phase,attack_id,profile.masonry)
	integrity_changed.emit()
	queue_redraw()
	return result

func _process(delta: float) -> void:
	impact_left = maxf(0,impact_left-delta)
	queue_redraw()
	set_process(impact_left > 0)

func _draw() -> void:
	var tint := Color.WHITE.lerp(Color(1.35,1.24,1.1),impact_left/0.10)
	var plate := profile.plates[phase]
	draw_texture_rect(plate,Rect2(profile.art_origin,plate.get_size()*profile.art_scale),false,tint)
	if not is_open:
		for mark in scars:
			var uv := (mark-profile.art_origin) / profile.art_scale
			if surface_mask.get_size() != Vector2i.ZERO and not surface_mask.get_bitv(Vector2i(uv)):
				continue
			draw_line(mark-Vector2(2,1),mark+Vector2(3,2),Color("#3c302a"),2.5,true)
			draw_line(mark+Vector2(0,2),mark+Vector2(3,3),Color("#c4a27b"),1,true)
	if not is_open and (not profile.masonry or phase > 0):
		var bar := Rect2(-25,profile.aim_bounds.position.y- (51 if not profile.masonry else 9),50,5)
		draw_rect(bar.grow(2),Color("#282119"))
		bar.size.x *= float(vitality.health) / profile.capacity
		draw_rect(bar,Color("#f5bd56"))
