class_name Global
extends Node

# ACTUALIZADO: Ahora la señal lleva dos datos (longitud y visitados)
signal actualizar_panel(longitud: int, visitados: int)

var heuristica: AStarGrid2D.Heuristic
var diagonal: AStarGrid2D.DiagonalMode = AStarGrid2D.DIAGONAL_MODE_NEVER
var tipo_algoritmo: String = "ASTAR"

func set_heuristica(h: AStarGrid2D.Heuristic) -> void:
	heuristica = h

func set_diagonal(d: AStarGrid2D.DiagonalMode) -> void:
	diagonal = d

func get_heuristica() -> AStarGrid2D.Heuristic:
	return heuristica

func get_diagonal() -> AStarGrid2D.DiagonalMode:
	return diagonal

func set_tipo_algoritmo(tipo: String) -> void:
	tipo_algoritmo = tipo

func get_tipo_algoritmo() -> String:
	return tipo_algoritmo
