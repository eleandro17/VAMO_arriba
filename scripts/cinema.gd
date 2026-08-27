extends Node3D


@export var animation_name: String = "cinema"
@export var next_scene_path: String = "res://escenas/prueba1.tscn"
#@export var allow_skip: bool = true

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)
	anim_player.play(animation_name)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == animation_name:
		_go_to_next_scene()


func _go_to_next_scene() -> void:
	
	set_process_unhandled_input(false)
	get_tree().change_scene_to_file(next_scene_path)
