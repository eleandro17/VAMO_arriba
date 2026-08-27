extends Node3D


@export var next_spawn_path: NodePath       # Marker3D de dónde aparece en el siguiente nivel
@export var hold_body_path: NodePath = ^"areaCheckpoint"  
@export var trigger_once: bool = true
@export var ragdoll_group: String = "player"  # el ragdoll tiene que estar en este grupo

var _already_triggered: bool = false
var _ragdoll: Node3D
var _hold_body: Node3D

func _ready() -> void:
	_ragdoll = get_tree().get_first_node_in_group(ragdoll_group)
	_hold_body = get_node(hold_body_path)

	if _ragdoll == null:
		push_warning("Checkpoint: no encontré ningún nodo en el grupo '%s'. ¿Agregaste el ragdoll a ese grupo?" % ragdoll_group)
		return

	_ragdoll.grabbed_hold.connect(_on_grabbed_hold)

func _on_grabbed_hold(hold: Node3D, hand: String) -> void:
	if hold != _hold_body:
		return  # se agarró de otra piedra, no de la mano del guía
	if trigger_once and _already_triggered:
		return

	_already_triggered = true
	_trigger_checkpoint()

func _trigger_checkpoint() -> void:
	if next_spawn_path.is_empty():
		push_warning("Checkpoint: falta asignar next_spawn_path en el Inspector")
		return

	var spawn = get_node(next_spawn_path)
	_ragdoll.respawn_at(spawn.global_transform)
