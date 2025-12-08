class_name Datos
extends Resource


@export var heuristica: AStarGrid2D.Heuristic
@export var diagonal: AStarGrid2D.DiagonalMode

func Datos(h,d) -> void:
	heuristica = h
	diagonal = d

func set_heuristica(h: AStarGrid2D.Heuristic) -> void:
	heuristica = h

func set_diagonal(d: AStarGrid2D.DiagonalMode) -> void:
	diagonal = d
