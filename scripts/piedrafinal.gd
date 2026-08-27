extends Area3D

var ya_activado := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if ya_activado:
		return
	
	var target := body
	if body.owner:
		target = body.owner
	
	print("Chocó: ", body.name, " | owner: ", target.name, " | grupos: ", target.get_groups())
	
	if target.is_in_group("player"):
		ya_activado = true
		GameEvents.cumbre_alcanzada.emit() 
