extends Button

var busquedas = preload("res://busquedas.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
		# 1. Avisamos a GlobalVar que vamos a usar BFS.
	# (Asegúrate de haber agregado set_tipo_algoritmo en GlobalVar como hablamos antes)
	GlobalVar.set_tipo_algoritmo("DFS") 
	
	# 2. Cambiamos de escena
	get_tree().change_scene_to_packed(busquedas)
