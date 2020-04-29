extends "res://src/objects/destructible_object.gd"


func take_damage(_atk: int, _pos: Vector2) -> void:
	$AnimationPlayer.play("exploding")


func _on_ExplosionArea_exploded() -> void:
	$AnimationPlayer.play("fade")
