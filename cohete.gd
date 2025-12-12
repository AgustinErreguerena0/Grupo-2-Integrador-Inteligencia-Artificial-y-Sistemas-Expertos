extends Node2D

# Precarga la clase personalizada que maneja la búsqueda de caminos con A*
const BusquedaCaminoAEstrella = preload("./busquedas.gd")

# Enumeración que define los posibles estados del personaje
enum Estado {
	INACTIVO,  # El personaje no se está moviendo
	SEGUIR,    # El personaje está siguiendo un camino
}

# Constante que representa la masa del personaje (usada para calcular la inercia del movimiento)
const MASA: float = 10.0

# Distancia mínima al punto objetivo para considerarlo alcanzado
const DISTANCIA_LLEGADA: float = 10.0

# Velocidad máxima del personaje (exportada para poder ajustarla desde el editor)
@export_range(10, 500, 0.1, "or_greater") var velocidad: float = 200.0

# Variable que almacena el estado actual del personaje
var _estado := Estado.INACTIVO

# Vector que almacena la velocidad actual del personaje
var _velocidad := Vector2()

# Posición donde el jugador hizo clic con el mouse
var _posicion_clic := Vector2()

# Array que contiene todos los puntos del camino a seguir
var _camino := PackedVector2Array()

# Siguiente punto objetivo en el camino
var _punto_siguiente := Vector2()

# Referencia al TileMap que gestiona el pathfinding (se inicializa cuando el nodo está listo)
@onready var _mapa_baldosas: BusquedaCaminoAEstrella = $"../TileMapLayer"

# Función que se ejecuta cuando el nodo está listo
func _ready() -> void:
	# Inicializa el personaje en estado inactivo
	_cambiar_estado(Estado.INACTIVO)

# Función que se ejecuta en cada frame de física
func _physics_process(_delta: float) -> void:
	# Si el personaje no está siguiendo un camino, no hace nada
	if _estado != Estado.SEGUIR:
		return
	
	# Mueve el personaje hacia el siguiente punto y verifica si llegó
	var llego_al_punto_siguiente: bool = _mover_a(_punto_siguiente)
	
	# Si llegó al punto siguiente
	if llego_al_punto_siguiente:
		# Elimina el punto alcanzado del camino
		_camino.remove_at(0)
		
		# Si ya no quedan más puntos en el camino
		if _camino.is_empty():
			# Cambia al estado inactivo y termina
			_cambiar_estado(Estado.INACTIVO)
			return
		
		# Establece el siguiente punto del camino como objetivo
		_punto_siguiente = _camino[0]

# Función que maneja los eventos de entrada no procesados (clicks del mouse)
func _unhandled_input(evento_entrada: InputEvent) -> void:
	# Obtiene la posición global del mouse
	_posicion_clic = get_global_mouse_position()
	
	# Verifica si el punto clickeado es transitable (no es un obstáculo)
	if _mapa_baldosas.es_punto_transitable(_posicion_clic):
		# Si se presiona la acción "teleport_to" (teletransportar)
		if evento_entrada.is_action_pressed(&"teleport_to", false, true):
			# Cambia a estado inactivo
			_cambiar_estado(Estado.INACTIVO)
			# Teletransporta el personaje a la posición clickeada (redondeada a la celda)
			global_position = _mapa_baldosas.redondear_posicion_local(_posicion_clic)
			# Reinicia la interpolación de física para evitar efectos visuales extraños
			reset_physics_interpolation()
		
		# Si se presiona la acción "move_to" (moverse a)
		elif evento_entrada.is_action_pressed(&"move_to"):
			# Cambia al estado de seguir camino
			_cambiar_estado(Estado.SEGUIR)

# Función que mueve el personaje hacia una posición local usando steering behavior
func _mover_a(posicion_local: Vector2) -> bool:
	# Calcula la velocidad deseada: dirección normalizada multiplicada por velocidad máxima
	var velocidad_deseada: Vector2 = (posicion_local - position).normalized() * velocidad
	
	# Calcula la fuerza de dirección (steering): diferencia entre velocidad deseada y actual
	var direccion: Vector2 = velocidad_deseada - _velocidad
	
	# Aplica la fuerza de dirección dividida por la masa (simula inercia)
	_velocidad += direccion / MASA
	
	# Actualiza la posición del personaje según su velocidad y el tiempo transcurrido
	position += _velocidad * get_physics_process_delta_time()
	
	# Rota el personaje en la dirección del movimiento
	rotation = _velocidad.angle()
	
	# Retorna true si el personaje está lo suficientemente cerca del punto objetivo
	return position.distance_to(posicion_local) < DISTANCIA_LLEGADA

# Función que gestiona los cambios de estado del personaje
func _cambiar_estado(nuevo_estado: Estado) -> void:
	# Si el nuevo estado es INACTIVO
	if nuevo_estado == Estado.INACTIVO:
		# Limpia la visualización del camino en el mapa
		_mapa_baldosas.limpiar_camino()
	
	# Si el nuevo estado es SEGUIR
	elif nuevo_estado == Estado.SEGUIR:
		# Calcula el camino desde la posición actual hasta donde se hizo clic
		_camino = _mapa_baldosas.encontrar_camino(position, _posicion_clic)
		
		# Si el camino tiene menos de 2 puntos (origen y destino)
		if _camino.size() < 2:
			# No hay camino válido, vuelve a estado inactivo
			_cambiar_estado(Estado.INACTIVO)
			return
		
		# El índice 0 es la celda inicial (donde está el personaje actualmente)
		# No queremos que el personaje vuelva a ella en este ejemplo
		# Por eso empezamos desde el índice 1
		_punto_siguiente = _camino[1]
	
	# Actualiza el estado actual
	_estado = nuevo_estado
