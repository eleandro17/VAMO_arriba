extends Control

func _ready():
	$AudioStreamPlayer.play()

func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://escenas/cine.tscn")

func _on_salir_pressed():
	get_tree().quit()

func _on_ajustes_pressed() -> void:
	# Cambia a la escena de ajustes directamente
	get_tree().change_scene_to_file("res://escenas/menú_ajustes.tscn")


func _on_créditos_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/videozorro.tscn")
