extends Button
var datos = Datos.new()
var escena_a_estrella = preload("res://a_estrella.tscn")

func _ready() -> void:
	datos.set_heuristica(4)

func _on_pressed() -> void:
	get_tree().change_scene_to_packed(escena_a_estrella) 
	pass
