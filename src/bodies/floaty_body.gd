extends KinematicBody2D

export var acceleration = 4000
export var desaccelaration = 3000

var max_current_speed = 500.0
var target_speed = 0.0

var current_speed = Vector2()
var entry_direction = Vector2()
var last_move_direction = Vector2()


func _physics_process(delta):
	var variation = Vector2()
	
	if entry_direction:
		last_move_direction = entry_direction
		
		if target_speed != max_current_speed:
			target_speed = max_current_speed
	else:
		target_speed = 0
		
	variation.x = acceleration * abs(last_move_direction.x) * delta
	variation.y = desaccelaration * abs(last_move_direction.y) * delta
	
	current_speed.x = approach(current_speed.x, target_speed * last_move_direction.x, variation.x)
	current_speed.y = approach(current_speed.y, target_speed * last_move_direction.y, variation.y)
	
	current_speed = move_and_slide(current_speed)


func approach(current_value, target_value, variation):
	"""
	Faz uma interpolação linear entre target_value e current_value em uma dada taxa de variation.
	Basicamente, um lerp manual. // Fiz por didática.
	"""
	var difference = target_value - current_value
	
	if difference > variation:
		return current_value + variation
		
	if difference < -variation:
		return current_value - variation
	
	return target_value
