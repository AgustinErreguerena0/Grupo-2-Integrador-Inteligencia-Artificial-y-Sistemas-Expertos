class_name Global
extends Node

# Definimos la señal para avisar a la interfaz que el camino cambió
signal actualizar_panel(longitud: int)

var heuristica: AStarGrid2D.Heuristic
var diagonal: AStarGrid2D.DiagonalMode = AStarGrid2D.DIAGONAL_MODE_NEVER
var tipo_algoritmo: String = "ASTAR" # Variable para controlar qué algoritmo usar

func set_heuristica(h: AStarGrid2D.Heuristic) -> void:
	heuristica = h

func set_diagonal(d: AStarGrid2D.DiagonalMode) -> void:
	diagonal = d

func get_heuristica() -> AStarGrid2D.Heuristic:
	return heuristica

func get_diagonal() -> AStarGrid2D.DiagonalMode:
	return diagonal

# Funciones para el selector de algoritmo
func set_tipo_algoritmo(tipo: String) -> void:
	tipo_algoritmo = tipo

func get_tipo_algoritmo() -> String:
	return tipo_algoritmo
