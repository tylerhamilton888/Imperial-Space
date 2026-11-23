extends Resource
## Damage plates share a registration point; the owning map supplies the solid.
@export var capacity := 96
@export var plates: Array[Texture2D]
@export var art_origin := Vector2(-108,-151)
@export var art_scale := Vector2.ONE
@export var aim_bounds := Rect2(-43,-111,80,102)
@export var surface_width := Vector2(-43,23)
@export var contact_height := 50.0
@export var masonry := false
