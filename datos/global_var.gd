class_name Global
extends Node


var heuristica: AStarGrid2D.Heuristic
var diagonal: AStarGrid2D.DiagonalMode = AStarGrid2D.DIAGONAL_MODE_NEVER
signal actualizar_panel(longitud_camino:int) 

func set_heuristica(h: AStarGrid2D.Heuristic) -> void:
	heuristica = h

func set_diagonal(d: AStarGrid2D.DiagonalMode) -> void:
	diagonal = d

func get_heuristica() -> AStarGrid2D.Heuristic:
	return heuristica

func get_diagonal() -> AStarGrid2D.DiagonalMode:
	return diagonal
