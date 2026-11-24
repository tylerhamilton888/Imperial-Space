extends Node2D
signal wounded
signal fell
const SHEET = preload("res://transit/court/operator.webp")
const Vitals = preload("res://combat/vitality.gd")
const Feedback = preload("res://combat/feedback.gd")
var vitals := Vitals.new(69)
var health: int:
	get: return vitals.health
var key := 0:
	set(value):
		key = value
		queue_redraw()
var flinch := 0.0
func _draw() -> void:
	draw_set_transform(Vector2(4,1),0,Vector2(23,5))
	draw_circle(Vector2.ZERO,1,Color(0.10,0.08,0.11,0.28))
	draw_set_transform(Vector2(flinch*2,0))
	draw_texture_rect_region(SHEET,Rect2(-44,-75,100,90),Rect2(key*100,0,100,90))
func _physics_process(delta: float) -> void:
	if flinch > 0:
		flinch = maxf(0,flinch-delta*5)
		queue_redraw()
func receive_hit(source: Node2D, id: int, damage: int, _kind: StringName, incoming: Vector2) -> StringName:
	var result := vitals.apply(source,id,damage)
	if result in [&"hit",&"killed"]:
		flinch = 1.0
		var impact := global_position+Vector2(0,-36)
		Feedback.play(self,&"blade_hit",impact,impact+incoming)
		if result == &"killed":
			key = 3
			fell.emit()
		else:
			wounded.emit()
	return result
