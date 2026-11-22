extends RefCounted
## Health belongs to each spawned actor. Attack identifiers increase per attacker.
## Remember its most recent contact so active frames cannot inflict a second hit.

var max_health: int
var health: int
var _last_contact: Dictionary[int, int] = {}

func _init(capacity: int) -> void:
	max_health = maxi(capacity, 1)
	health = max_health

func apply(source: Node2D, attack_id: int, damage: int, outcome: StringName = &"hit") -> StringName:
	if health <= 0 or not is_instance_valid(source) or attack_id <= 0 or damage < 0:
		return &"ignored"
	var source_id := source.get_instance_id()
	if _last_contact.get(source_id, 0) >= attack_id:
		return &"duplicate"
	_last_contact[source_id] = attack_id
	if _last_contact.size() > 64:
		for previous_source: int in _last_contact.keys():
			if not is_instance_id_valid(previous_source):
				_last_contact.erase(previous_source)
	if outcome == &"parried" or outcome == &"evaded":
		return outcome
	health = maxi(0, health - damage)
	return &"killed" if health == 0 else outcome

func refill() -> void:
	health = max_health

func heal(amount: int) -> void:
	if health > 0:
		health = mini(max_health, health + maxi(0, amount))
