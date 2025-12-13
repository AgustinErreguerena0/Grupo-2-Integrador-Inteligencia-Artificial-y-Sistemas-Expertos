extends VBoxContainer

# Etiqueta existente
@export var longitud_camino: Label
# NUEVA Etiqueta: Tienes que asignarla en el Inspector
@export var nodos_visitados: Label 

func _ready() -> void:
	GlobalVar.actualizar_panel.connect(_actualizar_texto)

# La función ahora recibe 2 datos porque la señal envía 2 datos
func _actualizar_texto(lc: int, vis: int) -> void:
	# 1. Actualizamos la longitud (igual que antes)
	if longitud_camino:
		longitud_camino.text = "Longitud del camino: " + str(lc)
	
	# 2. Actualizamos los visitados (nuevo)
	if nodos_visitados:
		# Si es A* nativo, 'vis' será 0, así que podemos poner un texto diferente si quieres
		if vis > 0:
			nodos_visitados.text = "Nodos visitados: " + str(vis)
		else:
			nodos_visitados.text = "Nodos visitados: - (A* Nativo)"
