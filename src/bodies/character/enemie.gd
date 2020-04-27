extends "res://src/bodies/characters.gd"
"""
Script base dos Personagens Inimigos. Segue o jogador quando seu estado atual
for 'ALERT'.
"""

enum States {
	IDLE
	ALERT,
	KNOCK_BACK
}

export(int, 0, 9999) var max_health: int = 2
var player: PhysicsBody2D setget set_player
var state: int = States.ALERT
var is_damaging: bool
onready var health: int = max_health


func _physics_process(delta: float) -> void:
	
	match state:
		
		States.KNOCK_BACK:
			apply_friction(200 * delta)
		
		States.ALERT:
			if player != null:
				_tracks_player(delta)
	
	motion = move_and_slide(motion) # move_and_slide ultiliza delta internamente


func _on_KnockBackTimer_timeout() -> void:
	state = States.ALERT


func take_damage(atk: int, atack_position: Vector2) -> void:
	"""
	Lida com o ataque (recebido por outro objeto).
	"""
	
	if is_damaging:
		return
	
	if health <= 0:
		die()
		
	else:
		health -= atk
		state = States.KNOCK_BACK
		$AnimationPlayer.play("take_damage")
		$KnockBackTimer.start()
		motion = (global_position - atack_position).clamped(1) * 150 # set knock back


func die() -> void: # TODO -> Adicionar animações
	queue_free()


func _tracks_player(delta: float) -> void:
	"""
	Segue em direção ao player.
	"""
	var vec_to_player: Vector2 = player.global_position - global_position
	vec_to_player = vec_to_player.normalized()
	
	global_rotation = atan2(vec_to_player.y, vec_to_player.x) # Olha para o player.
	_move(delta, vec_to_player)


func _move(delta: float, direction: Vector2) -> void:
	"""
	Move-se para a direção determinada.
	"""
	
	match state:
		
		States.ALERT:
			apply_movement(direction * acceleration * delta)
		
		States.IDLE:
			apply_friction(acceleration * delta)


func set_player(value: PhysicsBody2D) -> void:
	"""
	O player deve ser determinado externamente.
	"""
	player = value


func set_is_damaging(value: bool) -> void:
	is_damaging = value
