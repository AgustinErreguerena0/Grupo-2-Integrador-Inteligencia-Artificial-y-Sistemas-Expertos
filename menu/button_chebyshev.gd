extends Button
var busquedas = preload("res://busquedas.tscn")



func _on_pressed() -> void:
	GlobalVar.set_heuristica(AStarGrid2D.HEURISTIC_CHEBYSHEV)
	get_tree().change_scene_to_packed(busquedas) 
