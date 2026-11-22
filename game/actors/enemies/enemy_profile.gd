extends Resource

# Body silhouette in local screen coordinates, measured from the feet.
# Used for mouse selection and overhead information. Physical hit tests stay on the floor.
@export var aim_bounds := Rect2(-18.0, -69.0, 36.0, 73.0)
@export var health: int = 100
@export var move_speed: float = 0.0
@export var sight_range: float = 850.0
@export var engage_range: float = 0.0
@export var attack_reach: float = 0.0
@export var damage: int = 0
@export var windup: float = 0.5
@export var recovery: float = 0.65
