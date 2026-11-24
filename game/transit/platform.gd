extends Node2D

const WEST = preload("res://transit/court/paving_0.webp")
const EAST = preload("res://transit/court/paving_1.webp")

func _draw() -> void:
	draw_texture(WEST,Vector2.ZERO)
	draw_texture(EAST,Vector2(640,0))
