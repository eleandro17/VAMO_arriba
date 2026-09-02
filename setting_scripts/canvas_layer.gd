extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _input (event) :
	if event.is_action_pressed ("ui_cancel"):
		$Panel.visible = !$Panel.visible
		get_tree().paused = $Panel.visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continuar_pressed() -> void:
	$Panel.hide()
	get_tree().paused = false
	

func _on_ajustes_pressed() -> void:
	get_tree().change_scene_to_file ("res://escenas/menú_ajustes.tscn")


func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file ("res://escenas/main_menu.tscn")
