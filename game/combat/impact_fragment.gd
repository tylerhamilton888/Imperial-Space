extends Node2D
## Debris lives on the encounter floor. Height and fall speed are separate
## from the ground sweep, so flying paint never changes a gameplay collider.
const LIMIT := 48
const RAIDER = preload("res://art/destruction/raider_break.webp")
const FIXTURE = preload("res://art/destruction/fixture_fragments.webp")
# Centers of the weapon-arm paint in each registered 256 x 194 heading.
const ARM_CENTERS := [Vector2(130,135), Vector2(94,135), Vector2(79,134), Vector2(162,135),
	Vector2(126,135), Vector2(90,126), Vector2(181,125), Vector2(166,126)]
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

static func split_raider(ground: Node2D, feet: Vector2, facing: Vector2, impact: Vector2) -> void:
	var heading := posmod(roundi(facing.angle() / (TAU / 8.0)), 8)
	var along := impact.normalized() if not impact.is_zero_approx() else Vector2.RIGHT
	var turn := -1.0 if along.x < 0.0 else 1.0
	for row in 2:
		var anchor: Vector2 = Vector2(128,106) if row == 0 else ARM_CENTERS[heading]
		var offset := (anchor - Vector2(128,163)) / 1.5
		var start := feet + Vector2(offset.x,0)
		if absf(offset.x) > 0.1:
			var ray := PhysicsRayQueryParameters2D.create(feet,start,1)
			var hit := ground.get_world_2d().direct_space_state.intersect_ray(ray)
			if not hit.is_empty():
				start = hit.position + hit.normal
		var piece = make(ground,start)
		piece.paint = RAIDER
		piece.region = Rect2(heading*256,row*194,256,194)
		piece.pivot = anchor
		piece.size_factor = 1.0 / 1.5
		piece.height = -offset.y
		piece.heavy = row == 0
		piece.lift = 24.0 if row == 0 else 145.0
		piece.ground_speed = along * (126.0 if row == 0 else 220.0)
		if row == 1:
			piece.ground_speed += along.orthogonal() * turn * 68.0
		piece.spin = turn * (4.6 if row == 0 else -8.3)
		piece.shadow_width = 16.0 if row == 0 else 7.0
		piece.lifetime = 4.5

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
	if not landed:
		angle += spin * delta
		lift -= 660.0 * delta
		height += lift * delta
		if height <= 0:
			height = 0
			if heavy or bounced:
				landed = true
			else:
				lift = absf(lift) * 0.25
				spin *= 0.42
				bounced = true
	queue_redraw()

func _draw() -> void:
	if paint == null:
		return
	draw_set_transform(Vector2.ZERO,0,Vector2(shadow_width,shadow_width*0.32))
	draw_circle(Vector2.ZERO,1,Color(0.07,0.05,0.07,0.33),true,-1,true)
	var flatten := lerpf(0.55,1.0,clampf(height / 30.0,0.0,1.0)) if heavy else 1.0
	var plane := Transform2D(Vector2.RIGHT,Vector2.DOWN*flatten,Vector2.UP*height)
	draw_set_transform_matrix(plane * Transform2D(angle,Vector2.ZERO))
	draw_texture_rect_region(paint,Rect2(-pivot*size_factor,region.size*size_factor),region)
