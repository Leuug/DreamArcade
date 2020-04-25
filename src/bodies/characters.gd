extends KinematicBody2D
"""
Script base para todos os personagens do jogo. Implementa as movimentações 
básicas (fricção e aceleração), seguindo a orientação 'Top-Down'.
"""
export(float, 0, 1000) var max_speed: float = 100 # px/ sec
export(float, 0, 1000) var acceleration: float = 200 # (px/ sec) amount // Quantidade de px por segundo que acrescenta na velocidade a cada segundo.

var motion: Vector2 = Vector2.ZERO


func apply_friction(amount: float) -> void:
	"""
	Aplica fricção (desaceleração) ao motion.
	"""
	motion = motion.move_toward(Vector2.ZERO, amount)


func apply_movement(velocity: Vector2) -> void:
	"""
	Aplica ação (aceleração) ao movimento.
	"""
	motion += velocity
	motion = motion.clamped(max_speed)
