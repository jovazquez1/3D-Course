extends Node

@onready var _kill_plane_3d: Area3D = %KillPlane3D


func _ready() -> void:
	_kill_plane_3d.body_entered.connect(func (_body: CharacterBody3D) -> void:
		get_tree().reload_current_scene(),
		CONNECT_DEFERRED
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var window := get_window()
		window.mode = (
			Window.MODE_FULLSCREEN
			if window.mode != Window.MODE_FULLSCREEN
			else Window.MODE_WINDOWED
		)
