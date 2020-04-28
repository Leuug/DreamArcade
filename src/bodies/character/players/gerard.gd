extends "res://src/bodies/character/player.gd"

onready var animated_sprite: AnimatedSprite = $AnimatedSprite


func _physics_process(delta: float) -> void:
	._physics_process(delta)
	
	if state == State.RUN:
		animated_sprite.play('run')
	
	if state == State.IDLE:
		animated_sprite.play('idle')
	
	if state == State.DASH:
		animated_sprite.play('dash')


func _damage(atk: int) -> void:
	
	._damage(atk)
	$AnimationPlayer.play("damage")


func _move_left() -> void:
	
	._move_left()
	animated_sprite.flip_h = true


func _move_right() -> void:
	
	._move_right()
	animated_sprite.flip_h = false
