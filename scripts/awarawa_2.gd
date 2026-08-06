extends Node3D

@onready var pbs: PhysicalBoneSimulator3D = $Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var grab_joint_left: PinJoint3D = $GrabJointLeft
@onready var grab_joint_right: PinJoint3D = $GrabJointRight

var torso_bones: Array[PhysicalBone3D] = []
var forearm_left: Array[PhysicalBone3D] = []
var forearm_right: Array[PhysicalBone3D] = []
var all_bones: Array[PhysicalBone3D] = []

var hold_near_left: Node3D = null
var hold_near_right: Node3D = null

var grabbing_left: bool = false
var grabbing_right: bool = false

var locked_z: float = 0.0

# --- spring correction hacia la bind pose ---
var bind_basis: Dictionary = {}  # bone_name -> Basis
@export var angular_spring_stiffness: float = 400.0
@export var angular_spring_damping: float = 20.0
@export var max_angular_force: float = 300.0

func _ready() -> void:
	locked_z = global_position.z

	for child in pbs.get_children():
		if child is PhysicalBone3D:
			all_bones.append(child)
			if child.bone_name.contains("Spine") or child.bone_name.contains("Hips"):
				torso_bones.append(child)
			if child.bone_name.contains("LeftForeArm"):
				forearm_left.append(child)
			if child.bone_name.contains("RightForeArm"):
				forearm_right.append(child)

	# capturamos la bind pose ANTES de iniciar la simulación física
	for bone in all_bones:
		bind_basis[bone.bone_name] = bone.global_transform.basis

	pbs.physical_bones_start_simulation()

	for bone in torso_bones:
		bone.gravity_scale = 0.85

	if not forearm_left.is_empty():
		var area_l = forearm_left[0].get_node("GrabArea")
		area_l.body_entered.connect(_on_left_area_entered)
		area_l.body_exited.connect(_on_left_area_exited)

	if not forearm_right.is_empty():
		var area_r = forearm_right[0].get_node("GrabArea")
		area_r.body_entered.connect(_on_right_area_entered)
		area_r.body_exited.connect(_on_right_area_exited)

func _on_left_area_entered(body: Node3D) -> void:
	if body.is_in_group("holds"):
		hold_near_left = body

func _on_left_area_exited(body: Node3D) -> void:
	if body == hold_near_left:
		hold_near_left = null

func _on_right_area_entered(body: Node3D) -> void:
	if body.is_in_group("holds"):
		hold_near_right = body

func _on_right_area_exited(body: Node3D) -> void:
	if body == hold_near_right:
		hold_near_right = null

# --- grab con joints pre-existentes (sin crear/destruir nodos) ---
func grab_left() -> void:
	if grabbing_left or hold_near_left == null or forearm_left.is_empty():
		return
	var hand = forearm_left[0]
	hand.global_position = hold_near_left.global_position

	grabbing_left = true
	grab_joint_left.global_position = hold_near_left.global_position
	grab_joint_left.node_a = hand.get_path()
	grab_joint_left.node_b = hold_near_left.get_path()

func release_left() -> void:
	grabbing_left = false
	grab_joint_left.node_a = NodePath()
	grab_joint_left.node_b = NodePath()

func grab_right() -> void:
	if grabbing_right or hold_near_right == null or forearm_right.is_empty():
		return
	var hand = forearm_right[0]
	hand.global_position = hold_near_right.global_position

	grabbing_right = true
	grab_joint_right.global_position = hold_near_right.global_position
	grab_joint_right.node_a = hand.get_path()
	grab_joint_right.node_b = hold_near_right.get_path()

func release_right() -> void:
	grabbing_right = false
	grab_joint_right.node_a = NodePath()
	grab_joint_right.node_b = NodePath()

func get_hang_point() -> Vector3:
	if forearm_left.is_empty() or forearm_right.is_empty():
		return global_position  # fallback seguro mientras los arrays no tengan huesos

	if grabbing_left and grabbing_right:
		return (forearm_left[0].global_position + forearm_right[0].global_position) / 2.0
	elif grabbing_left:
		return forearm_left[0].global_position
	elif grabbing_right:
		return forearm_right[0].global_position
	else:
		return (forearm_left[0].global_position + forearm_right[0].global_position) / 2.
func lock_to_plane() -> void:
	for bone in all_bones:
		var pos = bone.global_position
		pos.z = locked_z
		bone.global_position = pos

		var vel = bone.linear_velocity
		vel.z = 0.0
		bone.linear_velocity = vel

# --- spring: corrige rotación de cada hueso hacia su bind pose, con fuerza clampeada ---
func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)

func apply_spring_correction(delta: float) -> void:
	for bone in all_bones:
		var target_basis: Basis = bind_basis[bone.bone_name]
		var current_basis: Basis = bone.global_transform.basis
		var rotation_difference: Basis = target_basis * current_basis.inverse()

		var torque = hookes_law(rotation_difference.get_euler(), bone.angular_velocity, angular_spring_stiffness, angular_spring_damping)
		torque = torque.limit_length(max_angular_force)

		bone.angular_velocity += torque * delta

func _physics_process(delta: float) -> void:
	lock_to_plane()
	apply_spring_correction(delta)

	if not grabbing_left and not grabbing_right:
		return

	var hang_point = get_hang_point()
	for bone in torso_bones:
		var direccion = hang_point - bone.global_position
		var target_velocity = direccion * 3.0
		bone.linear_velocity = bone.linear_velocity.lerp(target_velocity, 5.0 * delta)

func push(direccion: Vector3, fuerza: float = 6.0) -> void:
	direccion.z = 0.0
	for bone in torso_bones:
		bone.apply_central_impulse(direccion.normalized() * fuerza)

func push_arm(bones: Array[PhysicalBone3D], direccion: Vector3, fuerza: float = 16.0) -> void:
	direccion.z = 0.0
	for bone in bones:
		bone.apply_central_impulse(direccion.normalized() * fuerza)

func jump(fuerza: float = 26.0) -> void:
	for bone in torso_bones:
		bone.apply_central_impulse(Vector3.UP * fuerza)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		push(Vector3.UP)
	if event.is_action_pressed("ui_down"):
		push(Vector3.DOWN)
	if event.is_action_pressed("ui_left"):
		push_arm(forearm_left, Vector3.LEFT)
	if event.is_action_pressed("ui_right"):
		push_arm(forearm_right, Vector3.RIGHT)
	if event.is_action_pressed("ui_select"):
		jump()

	if event.is_action_pressed("grab_left"):
		grab_left()
	if event.is_action_released("grab_left"):
		release_left()

	if event.is_action_pressed("grab_right"):
		grab_right()
	if event.is_action_released("grab_right"):
		release_right()
