extends "res://src/objects/destructible_object.gd"

var is_exploding: bool

func take_damage() -> void:
	
	if not is_exploding:
		animation_player.play("exploding")
		is_exploding = true


func _on_ExplosionArea_exploded() -> void:
	animation_player.play("fade")
