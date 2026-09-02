extends Node
const SAVE_PATH = "user://controles.cfg"

func save_inputs():
	var config = ConfigFile.new()
	for action in InputMap.get_actions():
		if not action.begins_with("ui_"): # Evita guardar controles por defecto de la UI
			var events = InputMap.action_get_events(action)
			config.set_value("Inputs", action, events)
	config.save(SAVE_PATH)

func load_inputs():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return # Si no hay archivo guardado, usa los controles por defecto
	
	for action in config.get_section_keys("Inputs"):
		InputMap.action_erase_events(action)
		var events = config.get_value("Inputs", action)
		for event in events:
			InputMap.action_add_event(action, event)
