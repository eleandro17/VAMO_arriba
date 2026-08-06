extends Node3D

@onready var psb: PhysicalBoneSimulator3D = $Armature/Skeleton3D/PhysicalBoneSimulator3D

var torso_bones: Array[PhysicalBone3D] = []
var forearm_left: Array[PhysicalBone3D] = []
var forearm_right: Array[PhysicalBone3D] = []

var hold_near_left: Node3D = null
var hold_near_right: Node3D = null

var joint_left: Generic6DOFJoint3D = null
var joint_right: Generic6DOFJoint3D = null

var locked_z: float = 0.0

func _ready() -> void:
	psb.physical_bones_start_simulation()
	locked_z = global_position.z #restrinjo al plano xy, al menos por ahora, porque ta dificila 

	for child in psb.get_children():
		if child is PhysicalBone3D:
			if child.name.contains("lumbarr") or child.name.contains("dorsal") or child.name.contains("cervical"):
				torso_bones.append(child)
			if child.name.contains("LeftForeArm"):
				forearm_left.append(child)
			if child.name.contains("RightForeArm"):
				forearm_right.append(child)

	for bone in torso_bones:
		bone.gravity_scale = 0.15

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

func grab_left() -> void:
	if joint_left != null or hold_near_left == null or forearm_left.is_empty():
		return
	var hand = forearm_left[0]
	hand.global_position = hold_near_left.global_position

	joint_left = Generic6DOFJoint3D.new()
	add_child(joint_left)
	joint_left.global_position = hold_near_left.global_position
	joint_left.node_a = hand.get_path()
	joint_left.node_b = hold_near_left.get_path()

func release_left() -> void:
	if joint_left != null:
		joint_left.queue_free()
		joint_left = null

func grab_right() -> void:
	if joint_right != null or hold_near_right == null or forearm_right.is_empty():
		return
	var hand = forearm_right[0]
	hand.global_position = hold_near_right.global_position

	joint_right = Generic6DOFJoint3D.new()
	add_child(joint_right)
	joint_right.global_position = hold_near_right.global_position
	joint_right.node_a = hand.get_path()
	joint_right.node_b = hold_near_right.get_path()

func release_right() -> void:
	if joint_right != null:
		joint_right.queue_free()
		joint_right = null

func get_hang_point() -> Vector3:
	if joint_left != null and joint_right != null:
		return (forearm_left[0].global_position + forearm_right[0].global_position) / 2.0
	elif joint_left != null:
		return forearm_left[0].global_position
	elif joint_right != null:
		return forearm_right[0].global_position
	else:
		return (forearm_left[0].global_position + forearm_right[0].global_position) / 2.0

func lock_to_plane() -> void:
	var all_bones = torso_bones + forearm_left + forearm_right
	for bone in all_bones:
		var pos = bone.global_position
		pos.z = locked_z
		bone.global_position = pos

		var vel = bone.linear_velocity
		vel.z = 0.0
		bone.linear_velocity = vel

func _physics_process(delta: float) -> void:
	lock_to_plane()

	if joint_left == null and joint_right == null:
		return  # sin manos agarradas, no hay fuerza de hang — salto/impulsos libres

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
