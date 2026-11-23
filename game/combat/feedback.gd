extends Node2D
## Short-lived illustrated tracers, contact sparks and synthesized prototype cues.
## Parenting to the combatant bounds the lifetime on clear / scenario restart.

const SAMPLE_RATE := 22050
static var _sounds: Dictionary[StringName, AudioStreamWAV] = {}
var _kind: StringName
var _endpoint: Vector2
var _age := 0.0
var _lifetime := 0.22

static func play(owner_node: Node2D, kind: StringName, start_world: Vector2, end_world: Vector2) -> void:
	if not owner_node.is_inside_tree():
		return
	var effect := new()
	effect._kind = kind
	effect._endpoint = end_world - start_world
	if kind in [&"fire", &"enemy_shot"]:
		effect._lifetime = 0.48
	elif kind in [&"counter_hit", &"parried"]:
		effect._lifetime = 0.32
	effect.top_level = true
	effect.z_index = 32
	owner_node.add_child(effect)
	effect.global_position = start_world
	if kind in [&"sword_arc", &"riposte_arc", &"return_arc"]:
		return
	var sound := AudioStreamPlayer.new()
	if not _sounds.has(kind):
		_sounds[kind] = _synthesize(kind)
	sound.stream = _sounds[kind]
	sound.volume_db = -7.0 if kind == &"fire" else -10.5
	if kind == &"step":
		sound.volume_db = -19.0
	effect.add_child(sound)
	sound.play()

static func _synthesize(kind: StringName) -> AudioStreamWAV:
	var duration := 0.32 if kind in [&"counter_hit", &"parried", &"fire"] else 0.17
	var rng := RandomNumberGenerator.new()
	rng.seed = absi(kind.hash())
	var samples := PackedByteArray()
	var count := int(SAMPLE_RATE * duration)
	samples.resize(count * 2)
	var smoothed := 0.0
	for index in range(count):
		var t := float(index) / SAMPLE_RATE
		var noise := rng.randf_range(-1, 1)
		smoothed = lerpf(smoothed, noise, 0.28)
		var sample: float
		match kind:
			&"fire", &"enemy_shot":
				var bass := 63.0 if kind == &"fire" else 103.0
				sample = sin(TAU * (bass * t + 1.2 * (1.0 - exp(-50.0 * t)))) * exp(-26.0 * t) * 0.62
				sample += noise * exp(-76.0 * t) * 0.65 + smoothed * exp(-28.0 * t) * 0.32
			&"melee", &"enemy_swing", &"dodge":
				sample = smoothed * sin(PI * t / duration) * exp(-10.0 * t) * 0.9
			&"blade_cue":
				sample = sin(TAU*(890.0*t + 1770.0*t*t))*exp(-37.0*t)*0.48
			&"step":
				sample = sin(TAU*(82.0*t+0.12*(1.0-exp(-55.0*t))))*exp(-36*t)*0.55 + smoothed*exp(-48*t)*0.6
			&"blade_hit", &"bullet_hit", &"counter_hit":
				var bass := 78.0 if kind == &"counter_hit" else 123.0
				sample = sin(TAU*(bass*t+0.7*(1.0-exp(-60.0*t))))*exp(-23*t)*0.77
				sample += noise*exp(-62*t)*0.75
				if kind != &"bullet_hit":
					sample += (sin(TAU*716*t)+0.4*sin(TAU*1427*t))*exp(-32*t)*0.27
			&"parried", &"guarded":
				sample = (sin(TAU * 1220.0 * t) + sin(TAU * 1793.0 * t) * 0.3) * exp(-19.0 * t) * 0.48 + noise * exp(-103.0*t)*0.6
			&"reload", &"heal":
				sample = noise * (exp(-80.0 * t) + exp(-95.0 * absf(t - 0.10))) * 0.43
			_:
				sample = (noise * 0.43 + sin(TAU * 178.0 * t) * 0.5) * exp(-34.0 * t)
		var tail := clampf((duration - t) / 0.007, 0.0, 1.0)
		samples.encode_s16(index * 2, int(clampf(sample * tail, -0.98, 0.98) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.data = samples
	return stream

func _process(delta: float) -> void:
	_age += delta
	if _age >= _lifetime:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var fade := maxf(0, 1.0 - _age / 0.13)
	match _kind:
		&"fire", &"enemy_shot":
			_draw_casing()
			if fade <= 0:
				return
			var color := Color("#ffe3a1") if _kind == &"fire" else Color("#ff8365")
			color.a = fade
			var direction := _endpoint.normalized()
			draw_line(Vector2.ZERO, _endpoint, Color(color, fade * 0.48), 1.5, true)
			var side := direction.orthogonal() * 3.3
			var vertices := PackedVector2Array([side, direction * 16.0, -side, -direction * 2.0])
			if direction.length_squared() > 0.01:
				draw_colored_polygon(vertices, color)
		&"sword_arc", &"return_arc", &"riposte_arc":
			_draw_blade_trail()
		&"counter_hit", &"blade_hit", &"bullet_hit":
			_draw_impact()
		&"hit", &"killed", &"parried", &"guarded":
			var progress := clampf(_age / _lifetime, 0, 1)
			var color := Color("#f7ce8b") if _kind in [&"hit", &"killed"] else Color("#99f1f6")
			color.a = 1 - progress
			for index in range(6):
				var ray := Vector2.from_angle(index * TAU / 6 + 0.22)
				draw_line(_endpoint + ray * (3 + progress * 12), _endpoint + ray * (9 + progress * 16), color, 1.8, true)

func _draw_casing() -> void:
	var t := clampf(_age / 0.44, 0.0, 1.0)
	var aim := _endpoint.normalized()
	var breech := -aim * 19.0
	var side := Vector2(1.0 if aim.x <= 0.0 else -1.0, 0.3)
	var height := 27.0 * sin(PI * t)
	var pos := breech + side * (27.0*t) + Vector2(0, 36.0*t*t - height)
	var tilt := Vector2.from_angle(8*t+aim.angle()) * 2.6
	draw_line(pos - tilt, pos + tilt, Color("#efbd70", clampf((1.0-t)*4,0,1)), 1.8, true)

func _draw_blade_trail() -> void:
	var t := clampf(_age / 0.17, 0, 1)
	if t >= 1: return
	var arc := 1.05
	var reach := 56.0
	var flip := 1.0
	if _kind == &"return_arc":
		flip = -1.0
		reach = 63.0
	elif _kind == &"riposte_arc":
		arc = 0.67
		reach = 72.0
	var head := lerpf(-arc, arc, ease(t, 0.48))
	var tail := maxf(-arc, head - 1.1*(1.0-t))
	if head - tail < 0.001: return
	var edge := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in 12:
		var u := float(i)/11.0
		var v := Vector2.from_angle(_endpoint.angle() + flip*lerpf(tail,head,u))
		v.y *= 0.77
		edge.append(v * reach)
		inner.append(v * (reach - sin(PI*u)*5.2 - 0.25))
	inner.reverse()
	var ribbon := edge.duplicate()
	ribbon.append_array(inner)
	draw_colored_polygon(ribbon, Color(0.97,0.77,0.4,0.42*(1.0-t)))
	draw_polyline(edge, Color(1.0,0.93,0.72,0.83*(1.0-t)), 1.6, true)

func _draw_impact() -> void:
	var t := clampf(_age / _lifetime, 0, 1)
	var strong := _kind == &"counter_hit"
	var span := 45.0 if strong else 26.0
	var along := _endpoint.normalized()
	for i in (11 if strong else 7):
		var theta := sin(i*9.37)*1.35
		var ray := along.rotated(theta)
		if i % 4 == 3: ray = -ray
		var distance := span*(0.45+0.55*absf(cos(i*7.7)))*sqrt(t)
		var tip := ray*distance + Vector2.DOWN*(11.0*t*t)
		draw_line(tip-ray*(1.0-t)*9.0,tip,Color(1.0,0.78+0.2*absf(sin(i)),0.46,1.0-t),1.6,true)
	if strong and t < 0.48:
		draw_arc(Vector2.ZERO, 4.0+32.0*t, 0, TAU, 32, Color(1.0,0.87,0.58,0.65*(1.0-t/0.48)),1.6,true)
