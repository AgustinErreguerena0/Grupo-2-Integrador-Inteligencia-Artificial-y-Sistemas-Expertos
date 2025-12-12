extends Button




func _on_pressed() -> void:
	GlobalVar.set_diagonal(AStarGrid2D.DIAGONAL_MODE_NEVER)
	get_tree().change_scene_to_file("res://menu/menu.tscn") 
