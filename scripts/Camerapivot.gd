extends Node3D

@export var target_node: Node3D# target position (to follow the character)

@export var mouse_sensitivity = 0.1# camera rotation speed


@onready var physical_skel: Skeleton3D = $"../Armature/Skeleton3D"

@onready var spring_arm = $SpringArm3D

var mouse_lock = false # is mouse locked

func _physics_process(delta):
	if physical_skel == null:
		return

	for child in physical_skel.get_children():
		if child is PhysicalBone3D:
			spring_arm.add_excluded_object(child.get_rid())

	if target_node != null:
		global_position = global_position.lerp(target_node.get_hang_point(), 10.0 * delta)

func _input(event):
	   	
	#rotate camera
	if event is InputEventMouseMotion :
		rotation_degrees.y -= mouse_sensitivity*event.relative.x
		rotation_degrees.x -= mouse_sensitivity*event.relative.y
		rotation_degrees.x = clamp(rotation_degrees.x,-45,45)
	
