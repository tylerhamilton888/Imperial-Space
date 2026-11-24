extends Node2D
const WEST = preload("res://transit/platform_0.webp")
const EAST = preload("res://transit/platform_1.webp")
var seconds := 0.0

func _process(delta: float) -> void:
	seconds += delta
	queue_redraw()

func _draw() -> void:
	draw_texture(WEST,Vector2.ZERO)
	draw_texture(EAST,Vector2(640,0))
	# Cinders from the damaged kiosk and small golden reflections on the canal.
	for i in 17:
		var phase := fposmod(seconds*(0.28+0.012*(i%4))+i*0.381,1.0)
		var at := Vector2(1125+(i%5)*2+17*phase+sin(i+phase*6)*3,234-phase*(18+i%9))
		draw_circle(at,0.7+0.3*(i%2),Color(1,0.49,0.11,sin(phase*PI)*0.85))
	for i in 22:
		var x := 140+i*43+sin(seconds*.65+i)*4
		var y := 696+i%5*4+sin(seconds+i*.4)
		draw_line(Vector2(x,y),Vector2(x+4+i%8,y),Color(0.98,0.71,0.32,0.17+0.1*sin(seconds*1.9+i)),1.0)
