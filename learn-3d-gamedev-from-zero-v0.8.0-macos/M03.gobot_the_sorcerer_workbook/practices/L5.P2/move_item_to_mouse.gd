extends Node3D

var mouse_position_2d := Vector2.ZERO
var mouse_ray := Vector3.ZERO
var world_mouse_position: Variant = null


var _ground_plane := Plane(Vector3.UP)

@onready var _box: Node3D = %Box
@onready var _camera_3d: Camera3D = %Camera3D


func _physics_process(delta: float) -> void:
	_ground_plane.d = global_position.y

	# This should only happen when the left mouse button is pressed.
	if true:
		# Calculate the projected mouse position.
		mouse_position_2d = get_viewport().get_mouse_position()
		mouse_ray
		world_mouse_position

		# Move the box to the mouse position.
