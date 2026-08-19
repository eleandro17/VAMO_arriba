extends Node3D


@export var animation_name: String = "cinema"
@export var next_scene_path: String = "res://escenas/prueba1.tscn"
@export var allow_skip: bool = true

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)
	anim_player.play(animation_name)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == animation_name:
		_go_to_next_scene()

func _unhandled_input(event: InputEvent) -> void:
	if not allow_skip:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_go_to_next_scene()

func _go_to_next_scene() -> void:
	# evita que se dispare dos veces (ej. termina la animación Y el jugador
	# apreta skip casi al mismo tiempo)
	set_process_unhandled_input(false)
	get_tree().change_scene_to_file(next_scene_path)
