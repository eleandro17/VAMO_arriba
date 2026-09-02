extends Control

# o extends Node
@onready var controles = $TextureRect

func _ready():
		controles.texture = load("res://Visuales- Fonts/Controles asset (1).png")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file ("res://escenas/menú_ajustes.tscn")
