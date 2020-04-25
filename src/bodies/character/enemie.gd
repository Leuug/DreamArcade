extends "res://src/bodies/characters.gd"
"""
Script base dos Personagens Inimigos. Segue o jogador quando seu estado atual
for 'ALERT'.
"""

enum States {
	IDLE = 0
	ALERT
}

var player: PhysicsBody2D setget set_player
var state: int = States.ALERT


func _physics_process(delta: float) -> void:
	
	if player != null:
		_tracks_player(delta)


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
	
	motion = move_and_slide(motion) # move_and_slide ultiliza delta internamente


func set_player(value: PhysicsBody2D) -> void:
	"""
	O player deve ser determinado externamente.
	"""
	player = value
