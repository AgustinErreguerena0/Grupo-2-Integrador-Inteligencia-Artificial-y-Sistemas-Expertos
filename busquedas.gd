extends TileMapLayer

# Coordenadas del atlas en el tileset para las baldosas de inicio/fin.
# esto dice en qué columna/fila está la imagen de la bandera de salida y llegada.
const BALDOSA_PUNTO_INICIO = Vector2i(1, 0)
const BALDOSA_PUNTO_FIN = Vector2i(2, 0)

# Variable para métricas.
# Aca guardamos cuántos pasos tiene el camino final y cuántas celdas tuvo que revisar el algoritmo para encontrarlo.
var longitud_camino: int
var cantidad_explorados: int

# Tamaño de cada celda en píxeles.
const TAMANO_CELDA = Vector2i(64, 64)

# Definimos el grosor visual de la línea blanca del camino.
const ANCHO_LINEA_BASE: float = 3.0

# Color de dibujo de camino: blanco con media opacidad. (0,5 de opacidad)
const COLOR_DIBUJO = Color.WHITE * Color(1, 1, 1, 0.5)

# Color para los nodos explorados.
const COLOR_EXPLORADOS = Color(0, 1, 0, 0.2) # Verde transparente para ver el área de exploración de los nodos.

# Se crea el objeto AStarGrid2D.
var _astar := AStarGrid2D.new()

# Inicio y fin del camino. Almacenan las coordenadas (x, y) de la grilla donde empieza y termina el personaje.
var _punto_inicio := Vector2i()
var _punto_fin := Vector2i()

# Camino final [array] donde se guarda la lista ordenada de puntos que forman la ruta exitosa.
var _camino := PackedVector2Array()

# Lista de todas las casillas exploradas a dibujar.
var _celdas_exploradas_dibujo: Array[Vector2i] = [] 

func _ready() -> void:
	# Obtenemos la configuración desde una variable global.
	# Esto define si usamos distancia Manhattan, Euclidiana, etc., y si permitimos diagonales.
	var heuristica = GlobalVar.get_heuristica()
	var diagonal = GlobalVar.get_diagonal()
	
	# Configuramos el tamaño de la grilla lógica.
	# Rect2i(0, 0, 18, 10) define un área de 18 columnas por 10 filas.
	_astar.region = Rect2i(0, 0, 18, 10)
	_astar.cell_size = TAMANO_CELDA
	
	# El offset ayuda a centrar los puntos. Al ponerlo en 0.5, Godot calcula el camino pasando por el CENTRO de la baldosa, no por la esquina.
	_astar.offset = TAMANO_CELDA * 0.5
	
	# Asignamos las reglas de heurística (cómo estima la distancia) y movimiento diagonal.
	_astar.default_compute_heuristic = heuristica
	_astar.default_estimate_heuristic = heuristica
	_astar.diagonal_mode = diagonal
	
	# update() aplica todos los cambios anteriores y construye la grilla en memoria.
	_astar.update()
	
	# Aca sincronizamos lo visual con lo lógico.
	# Recorremos todas las celdas dibujadas en este TileMapLayer.
	for pos in get_used_cells():
		# Le decimos al sistema AStar que esas celdas son "sólidas" (obstáculos), por lo tanto, no se puede caminar sobre ellas.
		_astar.set_point_solid(pos)
	
	# Verificamos qué algoritmo está seleccionado al inicio (AStar, BFS o DFS).
	var tipo = "ASTAR"
	if GlobalVar.has_method("get_tipo_algoritmo"):
		tipo = GlobalVar.get_tipo_algoritmo()
		
	

func _draw() -> void:
	# Esta función se llama automáticamente cuando Godot necesita redibujar la pantalla (o cuando llamamos queue_redraw).
	
	# Primero pintamos las celdas que fueron exploradas. Esto ayuda a visualizar la "eficiencia" del algoritmo.
	for celda in _celdas_exploradas_dibujo:
		# Convertimos la coordenada de grilla (ej: 2,3) a píxeles locales para saber dónde dibujar el cuadrado.
		var pos_local = map_to_local(celda)
		# Creamos un rectángulo centrado en esa posición.
		var rect = Rect2(pos_local - Vector2(TAMANO_CELDA) / 2, Vector2(TAMANO_CELDA))
		draw_rect(rect, COLOR_EXPLORADOS)

	# Si no hay camino calculado, terminamos aquí para no dibujar nada extra.
	if _camino.is_empty():
		return
	
	# Tomamos el primer punto del camino para empezar a trazar líneas.
	var ultimo_punto: Vector2 = _camino[0]
	
	# Recorremos el resto de puntos del camino.
	for indice in range(1, len(_camino)):
		var punto_actual: Vector2 = _camino[indice]
		# Dibujamos una línea desde el punto anterior al actual.
		draw_line(ultimo_punto, punto_actual, COLOR_DIBUJO, ANCHO_LINEA_BASE, true)
		# Dibujamos un círculo de puntos de conexion.
		draw_circle(punto_actual, ANCHO_LINEA_BASE * 2.0, COLOR_DIBUJO)
		# Actualizamos el "ultimo_punto" para la siguiente iteración del bucle.
		ultimo_punto = punto_actual

func redondear_posicion_local(posicion_local: Vector2i) -> Vector2i:
	# Convierte píxeles en una grilla y despues lo covierte de vuelta a píxeles pero centrados.
	return map_to_local(local_to_map(posicion_local))

func es_punto_transitable(posicion_local: Vector2) -> bool:
	# Funcion para determinar si estamos ante un obstaculo o no en la grilla
	var posicion_mapa: Vector2i = local_to_map(posicion_local)
	# Primero revisamos si la posición está dentro de los límites definidos .
	if _astar.is_in_boundsv(posicion_mapa):
		# Si está dentro, devolvemos TRUE solo si NO es sólida.
		return not _astar.is_point_solid(posicion_mapa)
	return false

func limpiar_camino() -> void:
	# Resetea todo para una nueva búsqueda.
	_celdas_exploradas_dibujo.clear()
	
	if not _camino.is_empty():
		_camino.clear()
		# Borramos visualmente las baldosas de inicio y fin (banderitas) del mapa.
		erase_cell(_punto_inicio)
		erase_cell(_punto_fin)
		# Pedimos que se vuelva a ejecutar _draw() para limpiar la pantalla.
		queue_redraw()

# Funcion para obtener los vecinos de la celda en base a la posicion del cohete
func _obtener_vecinos(celda: Vector2i) -> Array[Vector2i]:
	# Esta función manual es necesaria para BFS y DFS
	var vecinos: Array[Vector2i] = []
	# Definimos Arriba, Abajo, Izquierda, Derecha.
	var direcciones = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	
	# Si la configuración global permite diagonales, agregamos las 4 direcciones diagonales a la lista.
	if GlobalVar.get_diagonal() != AStarGrid2D.DIAGONAL_MODE_NEVER:
		direcciones.append_array([Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)])
	
	# Probamos cada dirección posible desde la celda actual.
	for dir in direcciones:
		var siguiente = celda + dir
		# Solo agregamos el vecino si está dentro del mapa y NO es una pared.
		if _astar.is_in_boundsv(siguiente) and not _astar.is_point_solid(siguiente):
			vecinos.append(siguiente)
	return vecinos

# Calculo del camino BFS (Búsqueda en Anchura)
func calcular_bfs(inicio: Vector2i, fin: Vector2i) -> PackedVector2Array:
	# "cola" es una lista de espera. En BFS es FIFO (Primero en entrar, primero en salir).
	var cola: Array[Vector2i] = [inicio]
	# "explorados" guarda quién es el "padre" de cada celda para poder reconstruir el camino al revés después.
	# El inicio no tiene padre (-1, -1).
	var explorados = {inicio: Vector2i(-1, -1)} 
	
	while not cola.is_empty():
		# Sacamos el PRIMERO de la fila (pop_front). Esto asegura que exploramos de forma amplia
		var actual = cola.pop_front()
		
		# Si se encuentra el nodo objetivo de la grilla
		if actual == fin:
			# Guardamos todas las celdas que visitamos para pintarlas de verde luego.
			_celdas_exploradas_dibujo.assign(explorados.keys())
			# Llamamos a la función que recupera la ruta desde el final hacia el inicio.
			return _reconstruir_camino(explorados, fin)
		
		# Si no es la meta, miramos a los vecinos.
		for vecino in _obtener_vecinos(actual):
			# Si no vimos al vecino antes
			if not explorados.has(vecino):
				# Anotamos de dónde venimos (actual es padre de vecino).
				explorados[vecino] = actual
				# Lo ponemos al final de la fila para visitarlo después.
				cola.append(vecino)
	
	# Si se acaba la cola y no llegamos al fin, actualizamos lo visitado y devolvemos camino vacío.
	_celdas_exploradas_dibujo.assign(explorados.keys())
	return PackedVector2Array()

# Calculo del camino DFS (Búsqueda en Profundidad)
func calcular_dfs(inicio: Vector2i, fin: Vector2i) -> PackedVector2Array:
	# En DFS es LIFO (Último en entrar, primero en salir).
	var pila: Array[Vector2i] = [inicio]
	var explorados = {inicio: Vector2i(-1, -1)}
	
	while not pila.is_empty():
		# Sacamos el ÚLTIMO que entró (pop_back). Esto hace que el algoritmo se "clave" profundo en una dirección hasta chocar.
		var actual = pila.pop_back()
		
		if actual == fin:
			_celdas_exploradas_dibujo.assign(explorados.keys())
			return _reconstruir_camino(explorados, fin)
		
		# Si no es la meta, miramos a los vecinos.
		for vecino in _obtener_vecinos(actual):
			# Si no vimos al vecino antes
			if not explorados.has(vecino):
				explorados[vecino] = actual
				# Lo agregamos a la pila. Al ser pila, el próximo ciclo sacará a este vecino inmediatamente.
				pila.append(vecino)


	_celdas_exploradas_dibujo.assign(explorados.keys())
	return PackedVector2Array()

func _reconstruir_camino(explorados: Dictionary, fin: Vector2i) -> PackedVector2Array:
	# Esta función toma el mapa de "rastros" y camina hacia atrás desde el final.
	var ruta = PackedVector2Array()
	var paso = fin
	
	# Mientras no lleguemos al punto fantasma (-1, -1) que marcamos como padre del inicio...
	while paso != Vector2i(-1, -1):
		# Convertimos la coordenada de grilla a posición real (píxeles) y guardamos.
		ruta.append(_astar.get_point_position(paso))
		# Retrocedemos al padre de la celda actual.
		paso = explorados[paso]
	
	# Como fuimos del final al inicio, invertimos el array para que vaya del inicio al final.
	ruta.reverse()
	return ruta

# Funcion para encontrar el camino dependiendo del algoritmo a utilizar
func encontrar_camino(punto_inicio_local: Vector2i, punto_fin_local: Vector2i) -> PackedVector2Array:
	# Limpiamos dibujos anteriores.
	limpiar_camino()
	
	# Convertimos los clics del mouse (píxeles) a coordenadas de grilla (enteros).
	_punto_inicio = local_to_map(punto_inicio_local)
	_punto_fin = local_to_map(punto_fin_local)
	
	# Consultamos qué algoritmo quiere usar el usuario.
	var tipo = "ASTAR"
	if GlobalVar.has_method("get_tipo_algoritmo"):
		tipo = GlobalVar.get_tipo_algoritmo()
	
	# Ejecutamos la lógica según el tipo elegido.
	if tipo == "BFS":
		_camino = calcular_bfs(_punto_inicio, _punto_fin)
	elif tipo == "DFS":
		_camino = calcular_dfs(_punto_inicio, _punto_fin)
	else:
		# Usamos la funcion AStarGrid2D para encontrar el camino
		_camino = _astar.get_point_path(_punto_inicio, _punto_fin)
		# AStar no nos dice qué nodos visitó internamente, así que limpiamos esa visualización.
		_celdas_exploradas_dibujo.clear()
		
	# Calculamos métricas para mostrar en la interfaz (UI).
	longitud_camino = _camino.size()
	cantidad_explorados = 0
	cantidad_explorados = _celdas_exploradas_dibujo.size()
	
	# Enviamos las estadísticas a la interfaz global.
	GlobalVar.actualizar_panel.emit(longitud_camino, cantidad_explorados)
	
	# Si encontramos un camino válido, dibujamos las baldosas de inicio y fin en el mapa visual.
	if not _camino.is_empty():
		set_cell(_punto_inicio, 0, BALDOSA_PUNTO_INICIO)
		set_cell(_punto_fin, 0, BALDOSA_PUNTO_FIN)
		
	# Pedimos redibujar las líneas y cuadros verdes.
	queue_redraw()
		
	
		
	return _camino.duplicate()
