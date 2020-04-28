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

var player: PhysicsBody2D setget set_player
var state: int = States.ALERT
var is_damaging: bool


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


func _on_Player_tree_exiting() -> void:
	set_player(null)


func take_damage(atk: int, from: Vector2) -> void: # @override
	
	if not is_damaging:
		.take_damage(atk, from)


func _knock_back(from: Vector2, force: int) -> void:
	
	state = States.KNOCK_BACK
	$AnimationPlayer.play("take_damage")
	$KnockBackTimer.start()
	._knock_back(from, force)


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
	if player != null:
		player.disconnect("tree_exiting", self, "_on_Player_tree_exiting")
	
	if value != null:
		var errors: int = value.connect("tree_exiting", self, "_on_Player_tree_exiting")
		assert(errors == OK)
	
	player = value


func set_is_damaging(value: bool) -> void:
	is_damaging = value


func _on_DamageArea_body_entered(body: Node) -> void:
	body.take_damage(strength, global_position)
