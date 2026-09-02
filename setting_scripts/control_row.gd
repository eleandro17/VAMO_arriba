class_name control_row extends HBoxContainer

@export var BUTTON : Button
@export var LABEL : RichTextLabel

var newEvent : InputEvent
var curEvent : InputEvent
var changedInput : bool = false
var unbound : bool = false
var NAME : String
var changingThisInput : bool = false

signal pressedKey
signal keyChanged

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NAME = self.name 
	if NAME.casecmp_to("template"):
		label_buttons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func label_buttons() -> void:
	var actionEvents = InputMap.action_get_events(NAME)
	if actionEvents.size() > 0:
		curEvent = InputMap.action_get_events(NAME)[0]
		BUTTON.text = format_button(curEvent.as_text())
	else:
		unbound = true
		BUTTON.text = "Unbound"
	LABEL.text = format_label(NAME)


func update_InputMap() -> void:
	if changedInput:
		InputMap.action_erase_events(NAME)
		InputMap.action_add_event(NAME,newEvent)
		curEvent = newEvent
		changedInput = false


func _on_button_pressed() -> void:
	BUTTON.text = "..."
	changingThisInput = true
	await pressedKey
	if !unbound:
		if !newEvent.is_match(curEvent):
			changedInput = true
			keyChanged.emit()
	else:
		changedInput = true
		keyChanged.emit()
		unbound = false
	
	changingThisInput = false
		
	BUTTON.text = newEvent.as_text()


func _input(event):
	if changingThisInput:
		if event is InputEventKey || event is InputEventMouseButton:
			if event.pressed:
				newEvent = event
				pressedKey.emit()


func format_label(str: String):
	str = str.to_snake_case().replace_char("_".unicode_at(0)," ".unicode_at(0))
	return str.to_upper()


func format_button(str: String):
	if curEvent is InputEventKey:
		return str.get_slice(" ",0)
	else:
		return str
