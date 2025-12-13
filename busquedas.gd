extends TileMapLayer

# Coordenadas del atlas en el tileset para las baldosas de inicio/fin
const BALDOSA_PUNTO_INICIO = Vector2i(1, 0)
const BALDOSA_PUNTO_FIN = Vector2i(2, 0)

# Variable para métricas
var longitud_camino: int

# Tamaño de cada celda en píxeles
const TAMANO_CELDA = Vector2i(64, 64)

# Ancho base de las líneas que dibujan el camino
const ANCHO_LINEA_BASE: float = 3.0

# Color de dibujo de camino: blanco con media opacidad
const COLOR_DIBUJO = Color.WHITE * Color(1, 1, 1, 0.5)

# Color para los nodos visitados
const COLOR_VISITADOS = Color(0, 1, 0, 0.2) # Verde transparente

# Se crea el objeto AStarGrid2D
var _astar := AStarGrid2D.new()

# Inicio y fin del camino
var _punto_inicio := Vector2i()
var _punto_fin := Vector2i()

# Camino final [array]
var _camino := PackedVector2Array()

# Array de celdas visitadas a dibujar
var _celdas_visitadas_dibujo: Array[Vector2i] = [] 

func _ready() -> void:
	var heuristica = GlobalVar.get_heuristica()
	var diagonal = GlobalVar.get_diagonal()
	
	_astar.region = Rect2i(0, 0, 18, 10)
	_astar.cell_size = TAMANO_CELDA
	_astar.offset = TAMANO_CELDA * 0.5
	
	_astar.default_compute_heuristic = heuristica
	_astar.default_estimate_heuristic = heuristica
	_astar.diagonal_mode = diagonal
	
	_astar.update()
	
	for pos in get_used_cells():
		_astar.set_point_solid(pos)
	
	var tipo = "ASTAR"
	if GlobalVar.has_method("get_tipo_algoritmo"):
		tipo = GlobalVar.get_tipo_algoritmo()
		
	# Configuración INICIAL de la interfaz
	if %label_evaluados:
		if tipo == "ASTAR":
			%label_evaluados.visible = false  # <--- ¡Se oculta inmediatamente!
		else:
			%label_evaluados.visible = true   # Se muestra para BFS/DFS
			%label_evaluados.text = "Visitados: 0"

func _draw() -> void:
	# 1. Dibujar área explorada (verde)
	for celda in _celdas_visitadas_dibujo:
		var pos_local = map_to_local(celda)
		var rect = Rect2(pos_local - Vector2(TAMANO_CELDA) / 2, Vector2(TAMANO_CELDA))
		draw_rect(rect, COLOR_VISITADOS)

	# 2. Dibujar camino final (blanco)
	if _camino.is_empty():
		return
	
	var ultimo_punto: Vector2 = _camino[0]
	for indice in range(1, len(_camino)):
		var punto_actual: Vector2 = _camino[indice]
		draw_line(ultimo_punto, punto_actual, COLOR_DIBUJO, ANCHO_LINEA_BASE, true)
		draw_circle(punto_actual, ANCHO_LINEA_BASE * 2.0, COLOR_DIBUJO)
		ultimo_punto = punto_actual

func redondear_posicion_local(posicion_local: Vector2i) -> Vector2i:
	return map_to_local(local_to_map(posicion_local))

func es_punto_transitable(posicion_local: Vector2) -> bool:
	var posicion_mapa: Vector2i = local_to_map(posicion_local)
	if _astar.is_in_boundsv(posicion_mapa):
		return not _astar.is_point_solid(posicion_mapa)
	return false

func limpiar_camino() -> void:
	_celdas_visitadas_dibujo.clear()
	
	if not _camino.is_empty():
		_camino.clear()
		erase_cell(_punto_inicio)
		erase_cell(_punto_fin)
		queue_redraw()

# Funcion para obtener los vecinos de la celda en base a la posicion del cohete
func _obtener_vecinos(celda: Vector2i) -> Array[Vector2i]:
	var vecinos: Array[Vector2i] = []
	var direcciones = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	
	if GlobalVar.get_diagonal() != AStarGrid2D.DIAGONAL_MODE_NEVER:
		direcciones.append_array([Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)])
	
	for dir in direcciones:
		var siguiente = celda + dir
		if _astar.is_in_boundsv(siguiente) and not _astar.is_point_solid(siguiente):
			vecinos.append(siguiente)
	return vecinos

# Calculo del camino BFS
func calcular_bfs(inicio: Vector2i, fin: Vector2i) -> PackedVector2Array:
	var cola: Array[Vector2i] = [inicio]
	var visitados = {inicio: Vector2i(-1, -1)} 
	
	while not cola.is_empty():
		var actual = cola.pop_front()
		
		if actual == fin:
			# CORRECCIÓN AQUÍ: Usamos .assign() en lugar de =
			_celdas_visitadas_dibujo.assign(visitados.keys())
			return _reconstruir_camino(visitados, fin)
		
		for vecino in _obtener_vecinos(actual):
			if not visitados.has(vecino):
				visitados[vecino] = actual
				cola.append(vecino)
	
	_celdas_visitadas_dibujo.assign(visitados.keys())
	return PackedVector2Array()

# Calculo del camino DFS
func calcular_dfs(inicio: Vector2i, fin: Vector2i) -> PackedVector2Array:
	var pila: Array[Vector2i] = [inicio]
	var visitados = {inicio: Vector2i(-1, -1)}
	
	while not pila.is_empty():
		var actual = pila.pop_back()
		
		if actual == fin:
			_celdas_visitadas_dibujo.assign(visitados.keys())
			return _reconstruir_camino(visitados, fin)
			
		for vecino in _obtener_vecinos(actual):
			if not visitados.has(vecino):
				visitados[vecino] = actual
				pila.append(vecino)


	_celdas_visitadas_dibujo.assign(visitados.keys())
	return PackedVector2Array()

func _reconstruir_camino(visitados: Dictionary, fin: Vector2i) -> PackedVector2Array:
	var ruta = PackedVector2Array()
	var paso = fin
	while paso != Vector2i(-1, -1):
		ruta.append(_astar.get_point_position(paso))
		paso = visitados[paso]
	ruta.reverse()
	return ruta

# Funcion para encontrar el camino dependiendo del algoritmo a utilizar
func encontrar_camino(punto_inicio_local: Vector2i, punto_fin_local: Vector2i) -> PackedVector2Array:
	limpiar_camino()
	
	_punto_inicio = local_to_map(punto_inicio_local)
	_punto_fin = local_to_map(punto_fin_local)
	
	var tipo = "ASTAR"
	if GlobalVar.has_method("get_tipo_algoritmo"):
		tipo = GlobalVar.get_tipo_algoritmo()
	
	if tipo == "BFS":
		_camino = calcular_bfs(_punto_inicio, _punto_fin)
	elif tipo == "DFS":
		_camino = calcular_dfs(_punto_inicio, _punto_fin)
	else:
		_camino = _astar.get_point_path(_punto_inicio, _punto_fin)
		_celdas_visitadas_dibujo.clear()
		
		
	longitud_camino = _camino.size()
	
	var cantidad_visitados = _celdas_visitadas_dibujo.size()
	print("Longitud: ", longitud_camino, " | Visitados: ", cantidad_visitados)
	

	# Condiciones para determinar que NO se vea la etiqueta "Evaluados" para los nodos visitados en A*
	if %label_evaluados:
		if tipo == "ASTAR":
			%label_evaluados.visible = false
		else:
			%label_evaluados.visible = true
			%label_evaluados.text = "Visitados: " + str(cantidad_visitados)
	# Actualizar la longitud de los nodos visitados/evaluados
	if %label_longitud:
		%label_longitud.text = "Longitud: " + str(longitud_camino)

	if not _camino.is_empty():
		set_cell(_punto_inicio, 0, BALDOSA_PUNTO_INICIO)
		set_cell(_punto_fin, 0, BALDOSA_PUNTO_FIN)
		
	queue_redraw()
		
	if GlobalVar.has_signal("actualizar_panel"):
		GlobalVar.actualizar_panel.emit(longitud_camino, cantidad_visitados)
		
	return _camino.duplicate()
