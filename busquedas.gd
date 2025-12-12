extends TileMapLayer

# Coordenadas del atlas en el tileset para las baldosas de inicio/fin
const BALDOSA_PUNTO_INICIO = Vector2i(1, 0)
const BALDOSA_PUNTO_FIN = Vector2i(2, 0)

# Variable para métricas
var longitud_camino: int

# Tamaño de cada celda del mapa en píxeles
const TAMANO_CELDA = Vector2i(64, 64)

# Ancho base de las líneas que dibujan el camino
const ANCHO_LINEA_BASE: float = 3.0

# Color para dibujar el camino (blanco con 50% de transparencia)
const COLOR_DIBUJO = Color.WHITE * Color(1, 1, 1, 0.5)

# El objeto AStarGrid2D que maneja el pathfinding y detección de obstáculos
var _astar := AStarGrid2D.new()

# Punto de inicio y fin en coordenadas de mapa
var _punto_inicio := Vector2i()
var _punto_fin := Vector2i()

# Array que almacena todos los puntos del camino calculado
var _camino := PackedVector2Array()

# Función que se ejecuta cuando el nodo está listo
func _ready() -> void:
	var heuristica = GlobalVar.get_heuristica()
	var diagonal = GlobalVar.get_diagonal()
	
	_astar.region = Rect2i(0, 0, 18, 10)
	_astar.cell_size = TAMANO_CELDA
	_astar.offset = TAMANO_CELDA * 0.5
	
	# Configura A*
	_astar.default_compute_heuristic = heuristica
	_astar.default_estimate_heuristic = heuristica
	_astar.diagonal_mode = diagonal
	
	_astar.update()
	
	# Itera sobre todas las celdas usadas (obstáculos) y las marca
	for pos in get_used_cells():
		_astar.set_point_solid(pos)

# Función que dibuja el camino en pantalla
func _draw() -> void:
	if _camino.is_empty():
		return
	
	var ultimo_punto: Vector2 = _camino[0]
	
	for indice in range(1, len(_camino)):
		var punto_actual: Vector2 = _camino[indice]
		draw_line(ultimo_punto, punto_actual, COLOR_DIBUJO, ANCHO_LINEA_BASE, true)
		draw_circle(punto_actual, ANCHO_LINEA_BASE * 2.0, COLOR_DIBUJO)
		ultimo_punto = punto_actual

# Función que redondea una posición local
func redondear_posicion_local(posicion_local: Vector2i) -> Vector2i:
	return map_to_local(local_to_map(posicion_local))

# Función que verifica si un punto es transitable
func es_punto_transitable(posicion_local: Vector2) -> bool:
	var posicion_mapa: Vector2i = local_to_map(posicion_local)
	if _astar.is_in_boundsv(posicion_mapa):
		return not _astar.is_point_solid(posicion_mapa)
	return false

# Función que limpia el camino actual
func limpiar_camino() -> void:
	if not _camino.is_empty():
		_camino.clear()
		erase_cell(_punto_inicio)
		erase_cell(_punto_fin)
		queue_redraw()

# ---------------------------------------------------------
# ZONA DE ALGORITMOS MANUALES (BFS y DFS)
# ---------------------------------------------------------

# Ayudante: Devuelve vecinos válidos
func _obtener_vecinos(celda: Vector2i) -> Array[Vector2i]:
	var vecinos: Array[Vector2i] = []
	# Direcciones: Arriba, Abajo, Izq, Der
	var direcciones = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	
	if GlobalVar.get_diagonal() != AStarGrid2D.DIAGONAL_MODE_NEVER:
		direcciones.append_array([Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)])
	
	for dir in direcciones:
		var siguiente = celda + dir
		if _astar.is_in_boundsv(siguiente) and not _astar.is_point_solid(siguiente):
			vecinos.append(siguiente)
	return vecinos

# Algoritmo BFS (Anchura) - Usa Cola (FIFO)
func calcular_bfs(inicio: Vector2i, fin: Vector2i) -> PackedVector2Array:
	var cola: Array[Vector2i] = [inicio]
	var visitados = {inicio: Vector2i(-1, -1)} 
	
	while not cola.is_empty():
		var actual = cola.pop_front()
		
		if actual == fin:
			return _reconstruir_camino(visitados, fin)
		
		for vecino in _obtener_vecinos(actual):
			if not visitados.has(vecino):
				visitados[vecino] = actual
				cola.append(vecino)
	return PackedVector2Array()

# Algoritmo DFS (Profundidad) - Usa Pila (LIFO)
func calcular_dfs(inicio: Vector2i, fin: Vector2i) -> PackedVector2Array:
	var pila: Array[Vector2i] = [inicio]
	var visitados = {inicio: Vector2i(-1, -1)}
	
	while not pila.is_empty():
		var actual = pila.pop_back()
		
		if actual == fin:
			return _reconstruir_camino(visitados, fin)
			
		for vecino in _obtener_vecinos(actual):
			if not visitados.has(vecino):
				visitados[vecino] = actual
				pila.append(vecino)
	return PackedVector2Array()

# Ayudante para reconstruir el camino
func _reconstruir_camino(visitados: Dictionary, fin: Vector2i) -> PackedVector2Array:
	var ruta = PackedVector2Array()
	var paso = fin
	while paso != Vector2i(-1, -1):
		ruta.append(_astar.get_point_position(paso))
		paso = visitados[paso]
	ruta.reverse()
	return ruta

# ---------------------------------------------------------
# FUNCIÓN PRINCIPAL (MODIFICADA CON MÉTRICAS)
# ---------------------------------------------------------

func encontrar_camino(punto_inicio_local: Vector2i, punto_fin_local: Vector2i) -> PackedVector2Array:
	limpiar_camino()
	
	_punto_inicio = local_to_map(punto_inicio_local)
	_punto_fin = local_to_map(punto_fin_local)
	
	# 1. SELECTOR DE ALGORITMO
	var tipo = "ASTAR"
	if GlobalVar.has_method("get_tipo_algoritmo"):
		tipo = GlobalVar.get_tipo_algoritmo()
	
	if tipo == "BFS":
		_camino = calcular_bfs(_punto_inicio, _punto_fin)
	elif tipo == "DFS":
		_camino = calcular_dfs(_punto_inicio, _punto_fin)
	else:
		# Por defecto: A*
		_camino = _astar.get_point_path(_punto_inicio, _punto_fin)
	
	# 2. CÁLCULO DE MÉTRICAS (Aplicado a cualquier algoritmo)
	longitud_camino = _camino.size()
	print("Longitud del camino: ", longitud_camino) # Debug en consola
	
	if not _camino.is_empty():
		set_cell(_punto_inicio, 0, BALDOSA_PUNTO_INICIO)
		set_cell(_punto_fin, 0, BALDOSA_PUNTO_FIN)
	
	queue_redraw()
	
	# 3. EMISIÓN DE SEÑAL AL PANEL
	# Esto actualiza tu interfaz gráfica con el dato nuevo
	if GlobalVar.has_signal("actualizar_panel"):
		GlobalVar.actualizar_panel.emit(longitud_camino)
	
	return _camino.duplicate()
