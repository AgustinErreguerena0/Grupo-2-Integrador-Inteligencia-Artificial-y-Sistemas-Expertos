extends Button

# Acción ejecutada al presionar el botón
func _on_pressed() -> void:
	# Deshabilita el movimiento diagonal
	GlobalVar.set_diagonal(AStarGrid2D.DIAGONAL_MODE_NEVER)
	# Cambia a la escena del menú
	get_tree().change_scene_to_file("res://menu/menu.tscn")
