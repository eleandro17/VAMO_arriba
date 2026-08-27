extends CanvasLayer

@export var altura_maxima: float = 10.0  # Ajustable 
@export var tiempo_antes_reinicio: float = 2.0

@onready var label_altura = $AlturaLabel
@onready var panel_moriste = $MoristePanel
@onready var timer_reinicio = $TimerReinicio

var jugador: Node  # Referencia al jugador
var murio: bool = false

func _ready():
	panel_moriste.visible = false
	
	jugador = get_tree().get_first_node_in_group("player")
	if not jugador:
		push_error("No se encontró un nodo con grupo 'player'")

func _process(delta):
	if murio or not jugador:
		return
	
	# Obtengo la altura g
	var altura_actual = jugador.global_position.y
	
	# Actualizar label
	label_altura.text = "Altura: %.1f" % altura_actual
	
	# Verificar si superó la altura máxima
	if altura_actual > altura_maxima:
		_morir()

func _morir():
	murio = true
	panel_moriste.visible = true
	
	timer_reinicio.start(tiempo_antes_reinicio)

func _on_timer_reinicio_timeout():
	# Reiniciar escena 
	get_tree().reload_current_scene()
