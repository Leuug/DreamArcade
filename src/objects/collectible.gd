extends Area2D
"""
Um item que pode ser coletado pelo Personagem do Jogador.
"""
export(int, 0, 9999) var points: int


func _on_Collectible_body_entered(body: Node) -> void:
	
	if "Player" in body.name:
		Game.score += 10
		queue_free()
