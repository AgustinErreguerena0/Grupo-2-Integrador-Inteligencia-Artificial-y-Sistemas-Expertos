extends Button
var busquedas = preload("res://busquedas.tscn")



func _on_pressed() -> void:
	GlobalVar.set_heuristica(AStarGrid2D.HEURISTIC_OCTILE)
	GlobalVar.set_tipo_algoritmo("ASTAR")
	get_tree().change_scene_to_packed(busquedas) 
	
