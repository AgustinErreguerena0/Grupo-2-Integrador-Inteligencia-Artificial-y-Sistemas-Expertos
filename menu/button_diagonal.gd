extends CheckButton

# Acción al cambiar el estado del check
func _on_toggled(toggled_on: bool) -> void:
	# Muestra el estado actual en consola
	print(toggled_on)
	
	# Habilita o deshabilita el movimiento diagonal
	if toggled_on == true:
		GlobalVar.set_diagonal(AStarGrid2D.DIAGONAL_MODE_ALWAYS)
	else:
		GlobalVar.set_diagonal(AStarGrid2D.DIAGONAL_MODE_NEVER)
