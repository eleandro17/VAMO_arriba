extends Node3D
   
@onready var pbs: PhysicalBoneSimulator3D = $Root/Skeleton3D/PhysicalBoneSimulator3D

var upperchest_bone: PhysicalBone3D = null
var float_speed: float = 20.0

func _ready() -> void:
	pbs.physical_bones_start_simulation()

	for child in pbs.get_children():
		if child is PhysicalBone3D and child.bone_name.contains("UpperChest"):
			upperchest_bone = child
			upperchest_bone.gravity_scale = 0.0  # no cae por su cuenta

func _physics_process(delta: float) -> void:
	if upperchest_bone == null:
		return

	if Input.is_action_pressed("ui_up"):
		upperchest_bone.linear_velocity.y = float_speed
	elif Input.is_action_pressed("ui_down"):
		upperchest_bone.linear_velocity.y = -float_speed
	else:
		upperchest_bone.linear_velocity.y = 0.0
