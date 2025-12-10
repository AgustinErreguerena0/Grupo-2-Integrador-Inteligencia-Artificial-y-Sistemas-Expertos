extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_toggled(toggled_on: bool) -> void:
	print(toggled_on)
	
	if toggled_on == true:
		GlobalVar.set_diagonal(AStarGrid2D.DIAGONAL_MODE_ALWAYS)
	else:
		GlobalVar.set_diagonal(AStarGrid2D.DIAGONAL_MODE_NEVER)
		
		
