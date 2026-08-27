class_name control_settings extends Control

@export var CONTROLLIST : VBoxContainer
@export var TEMPLATE : control_row
@export var SAVEBUTTON : Button
@export var STATUS : RichTextLabel
@export var STATUSUNSAVED : String = "ADVERTENCIA: NO SE GUARDÓ!"
@export var STATUSSAVED : String = "Cambios guardados :D!"

# Cambiado a Array[String] para evitar conflicto con InputMap.get_actions()
var controls : Array[String]
var controlRows : Array[control_row]
var controls_changed : bool = false


func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	if STATUS:
		STATUS.visible = false
	
	get_controls()
	populate_menu()
	
	# Mover el botón al final solo si existe y es hijo de CONTROLLIST
	if SAVEBUTTON and CONTROLLIST and SAVEBUTTON.get_parent() == CONTROLLIST:
		CONTROLLIST.move_child(SAVEBUTTON, CONTROLLIST.get_child_count() - 1)


func get_controls() -> void:
	controls.clear()
	for action: String in InputMap.get_actions():
		# Filtra las acciones nativas de UI de Godot (ui_up, ui_accept, etc.)
		if not action.begins_with("ui_"):
			controls.append(action)


func populate_menu() -> void:
	if not TEMPLATE or not CONTROLLIST:
		return
		
	# Ocultamos la fila plantilla
	TEMPLATE.visible = false
	
	for action_name: String in controls:
		# Duplicamos la fila plantilla
		var newRow = TEMPLATE.duplicate() as control_row
		newRow.name = action_name
		newRow.visible = true
		
		# La agregamos al VBoxContainer (ListaControles)
		CONTROLLIST.add_child(newRow)
		controlRows.append(newRow)
		
		# Conectamos la señal key_changed si la fila la tiene
		if newRow.has_signal("key_changed"):
			newRow.connect("key_changed", Callable(self, "_on_row_key_changed"))


func disable_controls() -> void:
	if STATUS:
		STATUS.visible = false
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED


func enable_controls() -> void:
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	update_row_text()


func save_new_controls() -> void:
	for row: control_row in controlRows:
		if row.has_method("update_InputMap"):
			row.update_InputMap()
	controls_changed = false


func update_row_text() -> void:
	for row: control_row in controlRows:
		if row.has_method("label_buttons"):
			row.label_buttons()


func update_status(status_msg : String) -> void:
	if STATUS:
		STATUS.text = status_msg
		STATUS.visible = true


func _on_save_pressed() -> void:
	if controls_changed:
		update_status(STATUSSAVED)
		save_new_controls()


func _on_row_key_changed() -> void:
	update_status(STATUSUNSAVED)
	controls_changed = true


# Función ejecutada al presionar el botón Controles
func _on_controles_pressed() -> void:
	enable_controls()


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file ("res://escenas/menú_ajustes.tscn")
