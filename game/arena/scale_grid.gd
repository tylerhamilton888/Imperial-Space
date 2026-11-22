extends Node2D

const INK := Color(0.59, 0.81, 0.82, 0.22)
const ACCENT := Color(0.74, 0.89, 0.83, 0.38)
const GRID_SPACING := 64

func _draw() -> void:
	for x in range(128, 1480, GRID_SPACING):
		draw_line(Vector2(x,130), Vector2(x,830), INK, 1)
	for y in range(160, 830, GRID_SPACING):
		draw_line(Vector2(100,y), Vector2(1480,y), INK, 1)
	for x in range(128, 1480, GRID_SPACING*2):
		for y in range(160, 830, GRID_SPACING*2):
			draw_line(Vector2(x-3,y), Vector2(x+3,y), ACCENT, 1)
			draw_line(Vector2(x,y-3), Vector2(x,y+3), ACCENT, 1)
