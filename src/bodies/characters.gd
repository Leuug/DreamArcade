extends KinematicBody2D
"""
Script base para todos os personagens do jogo. Implementa as movimentações 
básicas (fricção e aceleração), seguindo a orientação 'Top-Down'.
"""
export(int, 0, 999) var max_health: int = 2 # hits/ atk (zero inclusivo)
export(int, 0, 999) var weight: int = 100 # resistência ao knock_back # weigth vs atk
export(int, 0, 999) var dizzy_probability: int = 20 # %
export(int, 0, 999) var melt_probability: int = 25 # %
export(int, 0, 999) var slowness_probability: int = 75 # %

export(float, 0, 1000) var max_speed: float = 100 # px/ sec
export(float, 0, 1000) var acceleration: float = 200 # (px/ sec) amount // Quantidade de px por segundo que acrescenta na velocidade a cada segundo.

var is_slow: bool
var motion: Vector2 = Vector2.ZERO
onready var health: int = max_health


func _ready() -> void:
	randomize()


func _on_SlownessTimer_timeout() -> void:
	is_slow = false


func apply_friction(amount: float) -> void:
	"""
	Aplica fricção (desaceleração) ao motion.
	"""
	motion = motion.move_toward(Vector2.ZERO, amount)


func apply_movement(velocity: Vector2) -> void:
	"""
	Aplica ação (aceleração) ao movimento.
	"""
	motion += velocity / 2 if is_slow else velocity
	motion = motion.clamped(max_speed)


func take_damage(atk: int, from: Vector2, effect: int = Game.EFFECTS.NONE) -> void:
	"""
	Lida com o ataque (recebido por outro personagem ou objeto).
	"""
	_damage(atk)
	
	match effect:
		Game.EFFECTS.DIZZY:
			
			if randi() % 100 < dizzy_probability:
				_dizzy()
		
		Game.EFFECTS.MELT:
			
			if randi() % 100 < melt_probability:
				_melt()
		
		Game.EFFECTS.KNOCKBACK:
			_knock_back(from, 10 * atk)
		
		Game.EFFECTS.SLOWNESS:
			
			if randi() % 100 < slowness_probability:
				_slowness()
	
	if health < 0: # Não morre no Zero
		_die()


func _die() -> void:
	"""
	Mata o personagem quando sua saúde chegar a zero.
	"""
	queue_free()


func _damage(atk: int) -> void:
	"""
	Causa dano ao personagem.
	"""
	health -= atk


func _dizzy() -> void:
	"""
	Função virtual chamada quando o personagem recebe o efeito DIZZY.
	"""
	pass


func _melt() -> void:
	"""
	Função chamada quando o personagem recebe o efeito MELT.
	"""
	$ParalelAnimator.play("melt")


func _knock_back(from: Vector2, force: int) -> void:
	"""
	Afasta o personagem de um determinado ponto, com uma certa força.
	"""
	motion = (global_position - from).clamped(1) * max(100 + force - 10 * weight, 0)


func _slowness() -> void:
	"""
	Função virtual chamada quando o personagem recebe o efeito SLOWNESS.
	Faz com que o personagem se mova com metade da sua velocidade.
	"""
	is_slow = true
