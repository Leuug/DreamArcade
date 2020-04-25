extends KinematicBody2D

export(float, 0, 10000) var max_speed: float = 500
export(float, 0, 10000) var acceleration: float = 2000

var motion: Vector2 = Vector2.ZERO
onready var raycast: RayCast2D = $RayCast2D


func apply_friction(amount: float) -> void:
	
	if motion.length() > amount:
		motion -= motion.normalized() * amount
		
	else:
		motion = Vector2.ZERO


func apply_movement(velocity: Vector2) -> void:
	
	motion += velocity
	motion = motion.clamped(max_speed)
