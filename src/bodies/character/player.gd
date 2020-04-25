extends "res://src/bodies/characters.gd"

const SMOOTHNESS = 5

func _physics_process(delta: float) -> void:
	
	_move(delta)
	_look(delta, get_local_mouse_position())


func _move(delta: float) -> void:
	var axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		apply_friction(acceleration * delta)
		
	else:
		apply_movement(axis * acceleration * delta)
	
	motion = move_and_slide(motion)


func _look(delta: float, relative_position: Vector2) -> void:
	rotation += relative_position.angle() * delta * SMOOTHNESS


func get_input_axis() -> Vector2:
	
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
