extends Button

# Escena de búsquedas precargada
var busquedas = preload("res://busquedas.tscn")

# Acción al presionar el botón
func _on_pressed() -> void:
	# Configura la heurística Euclidiana
	GlobalVar.set_heuristica(AStarGrid2D.HEURISTIC_EUCLIDEAN)
	# Selecciona el algoritmo A*
	GlobalVar.set_tipo_algoritmo("ASTAR")
	# Cambia a la escena de búsquedas
	get_tree().change_scene_to_packed(busquedas)
