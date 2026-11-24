extends Resource
## Grip or shoulder offset in authored display pixels, measured from top left.
enum Slot { SHOULDER, MAIN_HAND }
@export var slot: Slot = Slot.SHOULDER
@export var title: String
@export var texture: Texture2D
@export var display_size: Vector2
@export var anchor: Vector2
