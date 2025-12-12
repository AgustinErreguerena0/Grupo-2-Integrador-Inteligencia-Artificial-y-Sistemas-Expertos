extends VBoxContainer

@export var longitud_camino:Label



func _ready() -> void:
	GlobalVar.actualizar_panel.connect(_actualizar_texto)



func _actualizar_texto(lc) -> void:
	longitud_camino.text = "Longitud del camino: " + str(lc)
