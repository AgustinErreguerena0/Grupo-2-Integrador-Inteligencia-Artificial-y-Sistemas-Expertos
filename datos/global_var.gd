# Nodo global para almacenar configuración compartida
class_name Global
extends Node

# Señal para actualizar el panel de información
signal actualizar_panel(longitud: int, visitados: int)

# Heurística utilizada por A*
var heuristica: AStarGrid2D.Heuristic

# Modo de movimiento diagonal (por defecto deshabilitado)
var diagonal: AStarGrid2D.DiagonalMode = AStarGrid2D.DIAGONAL_MODE_NEVER

# Algoritmo seleccionado
var tipo_algoritmo: String = "ASTAR"

# Setea la heurística
func set_heuristica(h: AStarGrid2D.Heuristic) -> void:
	heuristica = h

# Setea el modo diagonal
func set_diagonal(d: AStarGrid2D.DiagonalMode) -> void:
	diagonal = d

# Devuelve la heurística actual
func get_heuristica() -> AStarGrid2D.Heuristic:
	return heuristica

# Devuelve el modo diagonal actual
func get_diagonal() -> AStarGrid2D.DiagonalMode:
	return diagonal

# Setea el tipo de algoritmo
func set_tipo_algoritmo(tipo: String) -> void:
	tipo_algoritmo = tipo

# Devuelve el tipo de algoritmo actual
func get_tipo_algoritmo() -> String:
	return tipo_algoritmo
