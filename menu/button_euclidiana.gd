extends Button
var escena_a_estrella = preload("res://a_estrella.tscn")



func _on_pressed() -> void:
	GlobalVar.set_heuristica(AStarGrid2D.HEURISTIC_EUCLIDEAN)
	get_tree().change_scene_to_packed(escena_a_estrella) 
