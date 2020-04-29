tool
extends Area2D

signal exploded
export(int, 0, 9999) var strength: int = 10
export var radius: float = 16 setget set_radius


func explode() -> void:
	$CollisionShape2D.disabled = false
	$Delay.start()


func _on_ExplosionArea_body_entered(body: Node) -> void:
	body.take_damage(strength, global_position)


func _on_Delay_timeout() -> void:
	
	$CollisionShape2D.disabled = true
	emit_signal("exploded")


func set_radius(value) -> void:
	radius = value
	$CollisionShape2D.shape.radius = radius
