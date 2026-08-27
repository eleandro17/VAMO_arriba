extends Control

# Ruta a Menú Principal
const MAIN_MENU_PATH = "res://escenas/main_menu.tscn"

# Referencia al nodo de audio
@onready var audio_player = $AudioStreamPlayer

func _ready() -> void:
	# Sincronizar el volumen inicial según la posición del slider
	if $PaneldeAjustes/Volumen/HSlider:
		_on_h_slider_value_changed($PaneldeAjustes/Volumen/HSlider.value)

func _on_check_box_música_toggled(toggled_on: bool) -> void:
	if toggled_on:
		audio_player.play()
	else:
		audio_player.stop()
		print("MÚSICA DESACTIVADA")

func _on_volver_pressed() -> void:
	# 1.Parar la música si suena
	if audio_player and audio_player.playing:
		audio_player.stop()
	
	# 2 Cambio de escena 
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _on_h_slider_value_changed(value: float) -> void:
	
	if value == 0:
		audio_player.volume_db = -80.0
	else:
		audio_player.volume_db = lerp(-50.0, 0.0, value / 100.0)

func _on_controles_pressed() -> void:
	$PaneldeAjustes/Volumen.visible = false
	$PaneldeAjustes/Controles.visible = false
	if $PaneldeAjustes.has_node("CheckBox música"):
		$"PaneldeAjustes/CheckBox música".visible = false
	if $PaneldeAjustes.has_node("volver"):
		$PaneldeAjustes/volver.visible = false
		$PaneldeAjustes/Controles/ControlSettings.enable_controls()
