extends KinematicBody2D
"""
Script base para todos os personagens do jogo. Implementa as movimentações 
básicas (fricção e aceleração), seguindo a orientação 'Top-Down'.
"""
export(float, 0, 10000) var max_speed: float = 500
export(float, 0, 10000) var acceleration: float = 2000

var motion: Vector2 = Vector2.ZERO


func apply_friction(amount: float) -> void:
	"""
	Aplica fricção (desaceleração) ao motion.
	"""
	if motion.length() > amount:
		motion -= motion.normalized() * amount
		
	else:
		motion = Vector2.ZERO


func apply_movement(velocity: Vector2) -> void:
	"""
	Aplica ação (aceleração) ao movimento.
	"""
	motion += velocity
	motion = motion.clamped(max_speed)
