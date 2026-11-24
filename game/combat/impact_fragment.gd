extends Node2D
## Debris lives on the encounter floor. Height and fall speed are separate
## from the ground sweep, so flying paint never changes a gameplay collider.
const FALL = preload("res://art/painted/raider_fall.webp")
const Feedback = preload("res://combat/feedback.gd")
const LIMIT := 48
const WOUNDED = preload("res://art/raider/wounded_fall.webp")
const PARTS = preload("res://art/raider/loose_parts.webp")
const FIXTURE = preload("res://art/destruction/fixture_fragments.webp")
enum Part { CLEAVER, FOREARM, PAULDRON }
var part_kind := -1
var paint: Texture2D
var region: Rect2
var pivot: Vector2
var size_factor := 1.0
var ground_speed := Vector2.ZERO
var height := 0.0
var lift := 0.0
var angle := 0.0
var spin := 0.0
var age := 0.0
var lifetime := 2.6
var heavy := false
var fall_row := 0
var fall_flip := false
var masonry_chip := false
var landed := false
var bounced := false
var shadow_width := 4.0

static func make(parent: Node2D, feet: Vector2):
	var live := parent.get_tree().get_nodes_in_group(&"impact_fragments")
	if live.size() >= LIMIT:
		var oldest: Node = live.front()
		oldest.get_parent().remove_child(oldest)
		oldest.queue_free()
	var piece := new()
	parent.add_child(piece)
	piece.global_position = feet
	piece.add_to_group(&"impact_fragments")
	piece.add_to_group(&"fallen_actors")
	return piece

static func fall_raider(ground: Node2D, feet: Vector2, facing: Vector2, impact: Vector2, sever: bool, grip: Transform2D, art_scale := 1.0) -> void:
	var along := impact.normalized() if not impact.is_zero_approx() else Vector2.RIGHT
	var body = make(ground,feet)
	body.paint = WOUNDED if sever else FALL
	body.heavy = true
	body.size_factor = art_scale
	body.fall_row = 1 if facing.y < -0.20 else 0
	body.fall_flip = along.x < 0.0 if sever else along.x > 0.0
	body.ground_speed = along * (106.0 if sever else 54.0)
	body.shadow_width = 19.0 * art_scale
	body.lifetime = 4.5
	# The loose cleaver begins at its painted center of mass. Its hilt
	# coincides with the last live grip, including during a raised attack.
	var blade_center := grip * Vector2(12.7,2.7)
	launch_part(ground,feet,blade_center,Part.CLEAVER,along,grip.get_rotation(),sever,art_scale)
	if sever:
		launch_part(ground,feet,grip.origin+Vector2(0,-6)*art_scale,Part.FOREARM,along,grip.get_rotation()*0.45,true,art_scale)
		var shoulder_x := -12.0 if facing.x >= 0 else 12.0
		launch_part(ground,feet,Vector2(shoulder_x,-65)*art_scale,Part.PAULDRON,along,0.0,true,art_scale)

static func launch_part(ground: Node2D, feet: Vector2, offset: Vector2, kind: Part, along: Vector2, tilt: float, forceful: bool, art_scale := 1.0) -> void:
	var start := feet + Vector2(offset.x,0)
	if absf(offset.x)>0.1:
		var ray := PhysicsRayQueryParameters2D.create(feet,start,1)
		var hit := ground.get_world_2d().direct_space_state.intersect_ray(ray)
		if not hit.is_empty():
			start = hit.position + hit.normal
	var piece = make(ground,start)
	piece.part_kind = kind
	piece.paint = PARTS
	piece.region = Rect2(0,kind*96,96,96)
	piece.pivot = Vector2(48,48)
	piece.size_factor = art_scale/1.5
	piece.height = maxf(4,-offset.y)
	piece.angle = tilt
	piece.shadow_width = 7.0 * art_scale
	piece.lifetime = 4.5
	var side := along.orthogonal()
	var turn := 1.0 if along.x >= 0.0 else -1.0
	match kind:
		Part.CLEAVER:
			piece.ground_speed = (along*195.0-side*48.0) if forceful else along*54.0
			piece.lift = 103.0 if forceful else 18.0
			piece.spin = turn*8.0 if forceful else turn*3.0
		Part.FOREARM:
			piece.ground_speed = along*115.0+side*65.0
			piece.lift = 71.0
			piece.spin = -turn*3.2
		Part.PAULDRON:
			piece.ground_speed = along*83.0-side*84.0
			piece.lift = 148.0
			piece.spin = -turn*6.5

static func shed_fixture(ground: Node2D, feet: Vector2, direction: Vector2, contact_height: float, phase: int, seed_id: int, masonry := false) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_id * 7639 + phase * 307
	var count := 10 if phase == 3 else 3
	for i in count:
		var pos := feet + Vector2(rng.randf_range(-22,22) if phase == 3 else rng.randf_range(-3,3),0)
		var piece = make(ground,pos)
		var sample := i % 3 if phase == 3 else 0
		if masonry:
			sample = 1 if i % 4 != 3 else 0
		piece.masonry_chip = masonry and sample == 1
		piece.paint = FIXTURE
		piece.region = Rect2(sample*32,0,32,32)
		piece.pivot = Vector2(16,16)
		piece.size_factor = rng.randf_range(0.35,0.9) if phase == 3 else rng.randf_range(0.15,0.35)
		piece.height = contact_height + rng.randf_range(-5,5)
		piece.lift = rng.randf_range(35,140)
		piece.spin = rng.randf_range(-10,10)
		piece.ground_speed = direction.rotated(rng.randf_range(-1.15,1.15)) * rng.randf_range(38,122)
		piece.shadow_width = 6.0 * piece.size_factor

func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	modulate.a = clampf((lifetime-age)/0.5,0.0,1.0)
	if landed and ground_speed.is_zero_approx():
		return
	if ground_speed.length_squared() > 0.1:
		var dest := global_position + ground_speed * delta
		var ray := PhysicsRayQueryParameters2D.create(global_position,dest,1)
		var hit := get_world_2d().direct_space_state.intersect_ray(ray)
		if hit.is_empty():
			global_position = dest
		else:
			var normal: Vector2 = hit.normal
			global_position = hit.position + normal
			ground_speed = ground_speed.bounce(normal) * 0.22
	ground_speed = ground_speed.move_toward(Vector2.ZERO,(420.0 if landed else 96.0)*delta)
	if heavy:
		if not landed and age >= 0.30:
			landed = true
			Feedback.play(self,&"body_land",global_position,global_position)
	elif not landed:
		angle += spin * delta
		lift -= 660.0 * delta
		height += lift * delta
		if height <= 0:
			height = 0
			if part_kind == Part.CLEAVER and not bounced:
				Feedback.play(self,&"blade_drop",global_position,global_position)
			if bounced or part_kind == Part.FOREARM:
				landed = true
			else:
				lift = absf(lift) * 0.25
				spin *= 0.42
				bounced = true
	if part_kind >= 0:
		var turn_frame := 2 if landed else (floori(age*9) % 2)
		region.position.x = turn_frame * 96
	queue_redraw()

func _draw() -> void:
	if paint == null:
		return
	var spread := lerpf(0.68,1.30,clampf(age / 0.32,0,1)) if heavy else 1.0
	var width := shadow_width*spread
	# Two soft layers tie the contact to the ground as the armor settles.
	draw_set_transform(Vector2(2,1),0,Vector2(width*1.25,width*0.33))
	draw_circle(Vector2.ZERO,1,Color(0.09,0.06,0.08,0.17),true,-1,true)
	draw_set_transform(Vector2.ZERO,0,Vector2(width,width*0.26))
	draw_circle(Vector2.ZERO,1,Color(0.07,0.05,0.07,0.31),true,-1,true)
	if heavy:
		var key := 0
		if landed:
			key = 3
		elif age >= 0.19:
			key = 2
		elif age >= 0.08:
			key = 1
		draw_set_transform(Vector2.ZERO,0,(Vector2(-1,1) if fall_flip else Vector2.ONE)*size_factor)
		draw_texture_rect_region(paint,Rect2(Vector2(-88,-140)/1.5,Vector2(176,150)/1.5),Rect2(176*key,150*fall_row,176,150))
		return
	draw_set_transform(Vector2.UP*height,angle)
	if masonry_chip:
		# Visible return faces stay thick even while the shard tumbles.
		var side := size_factor*Vector2(3.5,4.0).rotated(-angle)
		draw_texture_rect_region(paint,Rect2(-pivot*size_factor+side,region.size*size_factor),region,Color(0.49,0.42,0.36))
	draw_texture_rect_region(paint,Rect2(-pivot*size_factor,region.size*size_factor),region)
