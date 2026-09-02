extends MeshInstance3D

func _ready() -> void:
	visible = false
	GameEvents.cumbre_alcanzada.connect(_on_cumbre_alcanzada)

func _on_cumbre_alcanzada() -> void:
	visible = true
