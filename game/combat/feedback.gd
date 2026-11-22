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
	effect.top_level = true
	effect.z_index = 32
	owner_node.add_child(effect)
	effect.global_position = start_world
	var sound := AudioStreamPlayer.new()
	if not _sounds.has(kind):
		_sounds[kind] = _synthesize(kind)
	sound.stream = _sounds[kind]
	sound.volume_db = -7.0 if kind == &"fire" else -10.5
	effect.add_child(sound)
	sound.play()

static func _synthesize(kind: StringName) -> AudioStreamWAV:
	var duration := 0.17
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
			&"parried", &"guarded":
				sample = (sin(TAU * 1220.0 * t) + sin(TAU * 1793.0 * t) * 0.3) * exp(-31.0 * t) * 0.5
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
		&"hit", &"killed", &"parried", &"guarded":
			var progress := clampf(_age / _lifetime, 0, 1)
			var color := Color("#f7ce8b") if _kind in [&"hit", &"killed"] else Color("#99f1f6")
			color.a = 1 - progress
			for index in range(6):
				var ray := Vector2.from_angle(index * TAU / 6 + 0.22)
				draw_line(_endpoint + ray * (3 + progress * 12), _endpoint + ray * (9 + progress * 16), color, 1.8, true)
