extends Node3D
## Poné este script en el nodo padre que contiene todas las piedras (ej. "Holds").
## Cada piedra hija (o sus MeshInstance3D internos) va a recibir una variación
## de color aleatoria, para que no se vean todas idénticas.

@export var randomize_on_ready: bool = true

# rango de variación sobre el color 
@export var hue_variation: float = 0.05        # qué tanto puede cambiar el tono (0.0 - 1.0)
@export var saturation_variation: float = 0.15 # qué tanto puede cambiar la saturación
@export var value_variation: float = 0.2       # qué tanto puede cambiar el brillo

# variación opcional de escala, para que tampoco todas midan exactamente lo mismo
@export var randomize_scale: bool = true
@export var scale_min: float = 0.9
@export var scale_max: float = 1.15

func _ready() -> void:
	if randomize_on_ready:
		randomize_all_holds()

func randomize_all_holds() -> void:
	print("[HoldVariation] arrancando, hijos encontrados: ", get_children().size())
	for child in get_children():
		_randomize_hold(child)

func _randomize_hold(hold: Node3D) -> void:
	print("[HoldVariation] procesando: ", hold.name)
	# buscamos el/los MeshInstance3D dentro de esta piedra (puede ser el propio nodo o un hijo)
	var mesh_instances: Array[MeshInstance3D] = []
	if hold is MeshInstance3D:
		mesh_instances.append(hold)
	else:
		for descendant in hold.find_children("*", "MeshInstance3D", true, false):
			mesh_instances.append(descendant)

	print("[HoldVariation]   mesh instances encontrados: ", mesh_instances.size())

	for mesh_instance in mesh_instances:
		_apply_color_variation(mesh_instance)

	if randomize_scale:
		var s = randf_range(scale_min, scale_max)
		hold.scale = Vector3(s, s, s)

func _apply_color_variation(mesh_instance: MeshInstance3D) -> void:
	var surface_count = mesh_instance.get_surface_override_material_count()
	if surface_count == 0 and mesh_instance.mesh:
		surface_count = mesh_instance.mesh.get_surface_count()

	print("[HoldVariation]     ", mesh_instance.name, " -> surfaces: ", surface_count)

	for i in range(surface_count):
		var mat = mesh_instance.get_surface_override_material(i)
		if mat == null and mesh_instance.mesh:
			mat = mesh_instance.mesh.surface_get_material(i)

		if mat == null:
			print("[HoldVariation]       surface ", i, ": material NULO (no encontrado)")
			continue

		print("[HoldVariation]       surface ", i, ": clase de material = ", mat.get_class())

		if not (mat is BaseMaterial3D):
			print("[HoldVariation]       -> no es BaseMaterial3D, no lo puedo tintar así (¿shader custom?)")
			continue

		# duplicamos el material para que esta piedra no afecte a las demás
		var unique_mat: BaseMaterial3D = mat.duplicate()

		var base_color = unique_mat.albedo_color
		var h = base_color.h + randf_range(-hue_variation, hue_variation)
		var s = clamp(base_color.s + randf_range(-saturation_variation, saturation_variation), 0.0, 1.0)
		var v = clamp(base_color.v + randf_range(-value_variation, value_variation), 0.0, 1.0)

		unique_mat.albedo_color = Color.from_hsv(fmod(h + 1.0, 1.0), s, v, base_color.a)
		mesh_instance.set_surface_override_material(i, unique_mat)
		print("[HoldVariation]       aplicado nuevo color: ", unique_mat.albedo_color)
