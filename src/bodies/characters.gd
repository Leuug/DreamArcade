extends KinematicBody2D
"""
Script base para todos os personagens do jogo. Implementa as movimentações 
básicas (fricção e aceleração), seguindo a orientação 'Top-Down'.
"""
export(int, 0, 9999) var strength: int = 1
export(int, 0, 999) var max_health: int = 2 # hits/ atk (zero inclusivo)
export(int, 0, 999) var weight: int = 100 # resistência ao knock_back # weigth vs atk
export(float, 0, 1000) var max_speed: float = 100 # px/ sec
export(float, 0, 1000) var acceleration: float = 200 # (px/ sec) amount // Quantidade de px por segundo que acrescenta na velocidade a cada segundo.

var motion: Vector2 = Vector2.ZERO
onready var health: int = max_health


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


func take_damage(atk: int, from: Vector2) -> void:
	"""
	Lida com o ataque (recebido por outro objeto).
	"""
	
	if health <= 0:
		_die()
		
	else:
		_damage(atk)
		_knock_back(from, 10 * atk)


func _die() -> void:
	"""
	Mata o personagem quando sua saúde chegar a zero.
	"""
	queue_free()


func _damage(atk) -> void:
	"""
	Causa dano ao personagem.
	"""
	health -= atk


func _knock_back(from: Vector2, force: int) -> void:
	"""
	Afasta o personagem de um determinado ponto, com uma certa força.
	"""
	motion = (global_position - from).clamped(1) * max(100 + force - 10 * weight, 0)
