extends Control


# Called when the node enters the scene tree for the first time.


func _ready():
	$PaneldeAjustes.visible = false
	$AudioStreamPlayer.play()

func _on_jugar_pressed():
	get_tree().change_scene_to_file ("res://escenas/prueba1.tscn")

func _on_salir_pressed():
	get_tree().quit()


func _on_ajustes_pressed() -> void:
	print("Se presionó Ajustes")
	$PaneldeAjustes.visible = true

func _on_volver_pressed() -> void:
	$PaneldeAjustes.visible = false


func _on_h_slider_value_changed(value: float) -> void:
	$AudioStreamPlayer.volume_db = lerp(-50.0, 0.0, value /100.0 )


func _on_check_box_música_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$AudioStreamPlayer. play()
	else:
		$AudioStreamPlayer. stop()
		print ("FUNCIONA MÚSICA")
