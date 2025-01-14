extends Node3D

# NOTE: In practices, compared to lessons, we turn local variables into
# properties to make them accessible to the practice system. It allows the
# practice system to test your code better and to give you meaningful feedback.
# Use these variables in _physics_process() to make the skin look at the world.
var mouse_position_2d := Vector2.ZERO
var mouse_ray := Vector3.ZERO
var world_mouse_position: Variant = null


# Create a Plane object representing the ground plane. It's a plane created from a normal pointing up.
var _ground_plane := Plane(Vector3.UP) # var _ground_plane

@onready var _gobot_skin_3d: Node3D = %Skin
@onready var _camera_3d: Camera3D = %Camera3D


func _physics_process(delta: float) -> void:
	# This check allows the practice code to run without errors.
	if _ground_plane == null:
		return

	# This aligns the ground plane with the player's vertical position in the world.
	_ground_plane.d = global_position.y

	# Complete the code to project the mouse cursor position onto the world plane.
	mouse_position_2d = get_viewport().get_mouse_position() # mouse_position_2d = Vector2.ZERO
	mouse_ray = _camera_3d.project_ray_normal(mouse_position_2d) # mouse_ray = Vector3.ZERO
	world_mouse_position = _ground_plane.intersects_ray(_camera_3d.global_position, mouse_ray) # world_mouse_position = null

	# Make the skin look at the world mouse position.
	if world_mouse_position != null: #
		_gobot_skin_3d.look_at(world_mouse_position) #
