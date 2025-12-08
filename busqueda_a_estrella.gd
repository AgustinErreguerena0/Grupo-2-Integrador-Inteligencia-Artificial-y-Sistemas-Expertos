extends TileMapLayer

# Coordenadas del atlas en el tileset para las baldosas de inicio/fin
const BALDOSA_PUNTO_INICIO = Vector2i(1, 0)
const BALDOSA_PUNTO_FIN = Vector2i(2, 0)

# Tamaño de cada celda del mapa en píxeles
const TAMANO_CELDA = Vector2i(64, 64)

# Ancho base de las líneas que dibujan el camino
const ANCHO_LINEA_BASE: float = 3.0

# Color para dibujar el camino (blanco con 50% de transparencia)
const COLOR_DIBUJO = Color.WHITE * Color(1, 1, 1, 0.5)

# El objeto AStarGrid2D que maneja el pathfinding en grillas 2D
var _astar := AStarGrid2D.new()

# Punto de inicio del camino en coordenadas de mapa
var _punto_inicio := Vector2i()

# Punto final del camino en coordenadas de mapa
var _punto_fin := Vector2i()

# Array que almacena todos los puntos del camino calculado
var _camino := PackedVector2Array()

# Función que se ejecuta cuando el nodo está listo
func _ready() -> void:

	# Dependiendo de la configuración, también se puede usar get_used_rect() del TileMapLayer
	_astar.region = Rect2i(0, 0, 18, 10)
	
	# Establece el tamaño de cada celda para los cálculos de distancia
	_astar.cell_size = TAMANO_CELDA
	
	# Establece el offset para centrar los puntos en las celdas
	_astar.offset = TAMANO_CELDA * 0.5
	
	# Configura la heurística de Manhattan para calcular distancias
	# (solo movimientos horizontales y verticales, no diagonales)
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	
	# Habilita el movimiento diagonal
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	# Actualiza la grilla de A* con la configuración establecida
	_astar.update()
	
	# Itera sobre todas las celdas usadas (obstáculos) en la capa del TileMap
	# y las marca como no transitables (obstáculos)
	for pos in get_used_cells():
		_astar.set_point_solid(pos)
		
# Función que dibuja el camino en pantalla
func _draw() -> void:
	# Si no hay camino, no dibuja nada
	if _camino.is_empty():
		return
	
	# Guarda el primer punto del camino
	var ultimo_punto: Vector2 = _camino[0]
	
	# Itera desde el segundo punto hasta el final del camino
	for indice in range(1, len(_camino)):
		var punto_actual: Vector2 = _camino[indice]
		
		# Dibuja una línea desde el último punto hasta el punto actual
		draw_line(ultimo_punto, punto_actual, COLOR_DIBUJO, ANCHO_LINEA_BASE, true)
		
		# Dibuja un círculo en el punto actual
		draw_circle(punto_actual, ANCHO_LINEA_BASE * 2.0, COLOR_DIBUJO)
		
		# Actualiza el último punto para la siguiente iteración
		ultimo_punto = punto_actual

# Función que redondea una posición local a la posición central de su celda
func redondear_posicion_local(posicion_local: Vector2i) -> Vector2i:
	# Convierte de posición local a coordenadas de mapa y luego de vuelta a local
	# Esto redondea la posición al centro de la celda más cercana
	return map_to_local(local_to_map(posicion_local))

# Función que verifica si un punto es transitable (no es un obstáculo)
func es_punto_transitable(posicion_local: Vector2) -> bool:
	# Convierte la posición local a coordenadas de mapa
	var posicion_mapa: Vector2i = local_to_map(posicion_local)
	
	# Verifica si la posición está dentro de los límites de la grilla
	if _astar.is_in_boundsv(posicion_mapa):
		# Retorna true si el punto NO es sólido (es transitable)
		return not _astar.is_point_solid(posicion_mapa)
	
	# Si está fuera de los límites, no es transitable
	return false

# Función que limpia el camino actual y borra los marcadores visuales
func limpiar_camino() -> void:
	# Si hay un camino existente
	if not _camino.is_empty():
		# Limpia el array del camino
		_camino.clear()
		
		# Borra las baldosas de inicio y fin del mapa
		erase_cell(_punto_inicio)
		erase_cell(_punto_fin)
		
		# Encola un redibujado para limpiar las líneas y círculos
		queue_redraw()

# Función que calcula y retorna el camino entre dos puntos
func encontrar_camino(punto_inicio_local: Vector2i, punto_fin_local: Vector2i) -> PackedVector2Array:
	# Limpia cualquier camino anterior
	limpiar_camino()
	
	# Convierte las posiciones locales a coordenadas de mapa
	_punto_inicio = local_to_map(punto_inicio_local)
	_punto_fin = local_to_map(punto_fin_local)
	
	# Usa A* para calcular el camino óptimo entre inicio y fin
	_camino = _astar.get_point_path(_punto_inicio, _punto_fin)
	
	# Si se encontró un camino válido
	if not _camino.is_empty():
		# Coloca una baldosa marcadora en el punto de inicio
		set_cell(_punto_inicio, 0, BALDOSA_PUNTO_INICIO)
		
		# Coloca una baldosa marcadora en el punto final
		set_cell(_punto_fin, 0, BALDOSA_PUNTO_FIN)
	
	# Encola un redibujado para visualizar las líneas y círculos del camino
	queue_redraw()
	
	# Retorna una copia del camino calculado
	return _camino.duplicate()
