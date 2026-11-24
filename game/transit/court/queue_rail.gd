extends StaticBody2D
## Rails guide the passengers to the breakable boarding divider.
const RUN := Vector2(53,91)
func _ready() -> void:
	var foot := CollisionPolygon2D.new()
	foot.polygon = PackedVector2Array([Vector2(-3,1),Vector2(3,-1),RUN+Vector2(3,-1),RUN+Vector2(-3,1)])
	add_child(foot)
func _draw() -> void:
	var brass := Color("#c99b55")
	var enamel := Color("#254f52")
	draw_line(Vector2(2,0),RUN+Vector2(3,1),Color("#38384970"),4,true)
	for height in [12,22]:
		draw_line(Vector2(0,-height),RUN-Vector2(0,height),enamel,3,true)
		draw_line(Vector2(0,-height-1),RUN-Vector2(0,height+1),brass,1,true)
	for base: Vector2 in [Vector2.ZERO,RUN*.5,RUN]:
		draw_line(base,base-Vector2(0,24),enamel,4,true)
		draw_circle(base-Vector2(0,24),3,brass,true,-1,true)
