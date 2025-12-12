extends Button
var busquedas = preload("res://busquedas.tscn")



func _on_pressed() -> void:
	GlobalVar.set_heuristica(AStarGrid2D.HEURISTIC_OCTILE)
	get_tree().change_scene_to_packed(busquedas) 
	
