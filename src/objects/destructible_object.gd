extends StaticBody2D

const collectible: PackedScene = preload("res://src/objects/collectible.tscn")
var dying: bool
onready var animation_player: AnimationPlayer = $AnimationPlayer


func take_damage(_atk: int) -> void:
	"""
	Destroi o objeto com algum ataque.
	"""
	var new_collectible: Area2D
	
	if dying:
		return
	
	new_collectible = collectible.instance()
	new_collectible.global_position = global_position
	get_tree().current_scene.add_child(new_collectible)
	dying = true
	animation_player.play("fade")
