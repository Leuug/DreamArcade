extends Area2D

export(int, 0, 9999) var points: int
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _init() -> void:
	scale = Vector2.ZERO


func _ready() -> void:
	animation_player.play("popup")


func _on_Collectible_body_entered(body: Node) -> void:
	
	if body.is_in_group("players"):
		
		Game.score += 10
		queue_free()
