extends SceneTree
## Run with --path art_studies. Set ART_STUDY_CAPTURES to an existing folder
## when running with a display to save one native image of each assembled scene.

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func run() -> void:
	var review := preload("res://review/review.tscn").instantiate()
	root.add_child(review)
	var captures := OS.get_environment("ART_STUDY_CAPTURES")
	for i in review.SCENES.size():
		review.show_view(i)
		await process_frame
		check(review.world.get_node("Backdrop").find_children("Plate*", "Sprite2D", false, false).size() == 4, "Missing background tile")
		if i in [0, 3]:
			var intact: Node2D = review.world.get_node("Actors/WallIntact")
			var open: Node2D = review.world.get_node("Actors/WallBreached")
			check(intact.position == open.position, "Breach moves the wall's anchor")
			var original: bool = intact.visible
			review.toggle_wall()
			check(intact.visible != original and open.visible == original, "Wall state did not swap")
			review.toggle_wall()
			review.toggle_targets()
			check(not review.world.get_node("Actors/TargetOne").visible and not review.world.get_node("Actors/TargetTwo").visible, "Target pair stayed visible")
			review.toggle_targets()
			review.toggle_terminal()
			check(not review.world.get_node("Actors/Terminal").visible, "Terminal stayed visible")
			review.toggle_terminal()
		if i == 3:
			for pose in 4:
				var visible_count := 0
				for j in 4:
					if review.world.get_node("Actors/Heavy%d" % j).visible:
						visible_count += 1
						check(j == pose, "Unexpected Heavy pose")
				check(visible_count == 1, "Heavy poses overlap")
				review.advance_pose()
		if not captures.is_empty() and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var filename: String = captures.path_join("%s.jpg" % review.SCENES[i])
			check(root.get_texture().get_image().save_jpg(filename, 0.88) == OK, "Capture failed")
	# Some alternate fixtures are prepared for reuse without occupying a review scene.
	for group in ["proving","district","bridge","heavy"]:
		var folder: String = "res://kits/" + group
		for file in DirAccess.get_files_at(folder):
			if not file.ends_with(".tscn"):
				continue
			var scene := load(folder.path_join(file)) as PackedScene
			check(scene != null, "Missing packed scene " + file)
			if scene:
				var example := scene.instantiate()
				check(example.get_child_count() > 0, "Empty packed scene " + file)
				example.free()
	review.queue_free()
	await process_frame
	print("Art studies: 4 assembled views, fixture states, Heavy poses and reusable scenes; %d failures" % failures)
	quit(1 if failures else 0)
