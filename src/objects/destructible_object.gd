extends StaticBody2D
"""
Um objeto que pode ser destruído e que pode dropar algo.
"""
const collectible: PackedScene = preload("res://src/objects/collectible.tscn")

func take_damage(_atk: int) -> void:
	
	var new_collectible: Area2D = collectible.instance()
	
	new_collectible.global_position = global_position
	get_tree().current_scene.add_child(new_collectible)
	queue_free()
