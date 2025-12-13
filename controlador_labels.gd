extends VBoxContainer

# Etiquetas
@export var longitud_camino: Label
@export var nodos_explorados: Label 

func _ready() -> void:
	#Contectar la señal emitida con la funcion _actualizar_texto
	GlobalVar.actualizar_panel.connect(_actualizar_texto)

# Funcion que actualiza el texto de la labels longitud del camino y nodos explorados
func _actualizar_texto(lc: int, vis: int) -> void:
	# 1. Actualizamos la longitud
	
	longitud_camino.text = "Longitud del camino: " + str(lc)
	
	# 2. Actualizamos los explorados
	if vis > 0:
		nodos_explorados.text = "Nodos explorados: " + str(vis)
	else:
		nodos_explorados.text = "Nodos explorados: -" 
