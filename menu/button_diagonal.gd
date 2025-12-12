extends CheckButton





func _on_toggled(toggled_on: bool) -> void:
	print(toggled_on)
	
	if toggled_on == true:
		GlobalVar.set_diagonal(AStarGrid2D.DIAGONAL_MODE_ALWAYS)
	else:
		GlobalVar.set_diagonal(AStarGrid2D.DIAGONAL_MODE_NEVER)
		
		
