extends Area2D

export var speed: float = 60 # px/ sec
var strength: int = 10


func _physics_process(delta: float) -> void:
	position += polar2cartesian(1, rotation) * delta * speed


func _on_Bullet_body_entered(body: PhysicsBody2D) -> void:
	
	if body.has_method('take_damage'):
		body.take_damage(strength, global_position)


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
