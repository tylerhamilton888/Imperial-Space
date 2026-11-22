extends SceneTree

var checked := 0
var failed := 0

func verify(test: bool, title: String) -> void:
	checked += 1
	if not test:
		failed += 1
		push_error(title)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var map: Node2D = load("res://arena/range_map.tscn").instantiate()
	root.add_child(map)
	await physics_frame
	await physics_frame
	verify(not map.get_node("ScaleGrid").visible,"Scale grid starts hidden")
	map.set("grid_visible",true)
	verify(map.get_node("ScaleGrid").visible,"Scale grid toggles")
	verify(map.call("is_valid_spawn", Vector2(570,460)),"Player start clear")
	verify(not map.call("is_valid_spawn", Vector2(780,282)),"Cover refuses spawn")
	verify(not map.call("is_valid_spawn", Vector2(1490,400)),"Out of bounds refuses spawn")
	verify(not map.call("is_valid_spawn", Vector2(110,230)),"Spawn accounts for body radius")
	var space := map.get_world_2d().direct_space_state
	var cases := [
		[Vector2(570,460), Vector2(930,445), ""],
		[Vector2(860,180), Vector2(860,420), "NorthCover"],
		[Vector2(1130,590), Vector2(1130,710), "SouthCover"],
		[Vector2(320,210), Vector2(320,350), "CrewRail"],
		[Vector2(547,530), Vector2(20,530), "WestWall"],
		[Vector2(1380,355), Vector2(1550,355), "EastWall"],
		[Vector2(555,660), Vector2(555,900), "SouthWall"],
		[Vector2(555,300), Vector2(555,50), "NorthWall"],
	]
	for entry:Array in cases:
		var hit := space.intersect_ray(PhysicsRayQueryParameters2D.create(entry[0],entry[1],1))
		var name_found: String = "" if hit.is_empty() else String(hit.collider.name)
		verify(name_found==entry[2],"ray expected ['%s'] got ['%s']"%[entry[2],name_found])
	verify(map.get_node("RangeOfficer").get("role")==&"soldier","The crew officer uses the human scale reference")
	var routes := get_first_node_in_group("combat_navigation")
	var path:PackedVector2Array=routes.call("route",Vector2(860,230),Vector2(860,365))
	verify(path.size()>=2,"A route around the north barrier exists")
	print("RANGE MAP: %d checks / %d failures"%[checked,failed])
	quit(failed)
