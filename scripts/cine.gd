extends Control

@onready var text = $VideoStreamPlayer/ColorRect/RichTextLabel
var narration= "Todos estamos escapando de algo... ayuda al Awara a escalar la montaña para escapar del fuego"

func _ready() -> void:
	text.text = ""
	write_text()
	
func write_text():
	for c in narration:
		text.text += c
		await get_tree().create_timer (0.10).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://escenas/prueba1.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/main_menu.tscn")
