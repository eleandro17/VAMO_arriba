extends Control


# Called when the node enters the scene tree for the first time.


func _ready():
	$PaneldeAjustes.visible = false
	$AudioStreamPlayer.play()

func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_salir_pressed():
	get_tree().quit()


func _on_ajustes_pressed() -> void:
	print("Se presionó Ajustes")
	$PaneldeAjustes.visible = true

func _on_volver_pressed() -> void:
	$PaneldeAjustes.visible = false
