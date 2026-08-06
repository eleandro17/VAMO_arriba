extends Node3D

@export var target_node: Node3D
@export var mouse_sensitivity = 0.1

@onready var physical_skel: Skeleton3D = $"../Armature/Skeleton3D"
@onready var spring_arm = $SpringArm3D

var mouse_lock = false
var locked_z: float = 0.0

const YAW_LIMIT: float = 20.0
const PITCH_LIMIT: float = 15.0

func _ready() -> void:
	locked_z = global_position.z

	# excluimos los huesos físicos de la colisión del spring arm UNA sola vez
	if physical_skel != null:
		for child in physical_skel.get_children():
			if child is PhysicalBone3D:
				spring_arm.add_excluded_object(child.get_rid())

func _physics_process(delta):
	if target_node != null:
		var target_pos = target_node.get_hang_point()
		target_pos.z = locked_z
		global_position = global_position.lerp(target_pos, 10.0 * delta)

func _input(event):
	if Input.is_action_just_pressed("exit_camera"):
		mouse_lock = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		mouse_lock = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and mouse_lock:
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		rotation_degrees.x -= mouse_sensitivity * event.relative.y
		rotation_degrees.x = clamp(rotation_degrees.x, -PITCH_LIMIT, PITCH_LIMIT)
		rotation_degrees.y = clamp(rotation_degrees.y, -YAW_LIMIT, YAW_LIMIT)
