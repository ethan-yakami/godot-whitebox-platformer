extends SceneTree


func _init() -> void:
	var scenes := [
		"res://levels/level_3.tscn",
		"res://levels/level_4.tscn",
		"res://levels/level_5.tscn",
	]
	for scene_path in scenes:
		var packed := load(scene_path)
		if packed == null:
			push_error("Failed to load %s" % scene_path)
			quit(1)
			return
		var instance: Node = packed.instantiate()
		if instance == null:
			push_error("Failed to instantiate %s" % scene_path)
			quit(1)
			return
		instance.free()
	print("Level scene verification passed.")
	quit()
