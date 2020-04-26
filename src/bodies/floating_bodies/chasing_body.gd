extends "res://src/bodies/floaty_body.gd"

export var target: NodePath

var time: float
var target_node: Node2D 


func _ready() -> void:
	
	if target != null:
		target_node = get_node(target)
		target_node.connect("tree_exiting", self, "_on_TargetNode_tree_exiting")


func _physics_process(delta) -> void:
	
	if target_node == null:
		set_physics_process(false)
		
	else:
		
		time += delta
		fly(delta)


func _on_TargetNode_tree_exiting() -> void:
	target_node = null


func fly(delta) -> void:
	"""
	Voa no topo de um alvo.
	"""
	var target_position: Vector2 = target_node.get_position() + Vector2(cos(time * 2) * 20, sin(time * 1.4) * 10 - 20)
	var difference: Vector2 = target_position - get_position()
	var direction: Vector2 = difference.normalized()
	var distance: float = difference.length()
	
	if distance < current_speed.length() * delta + 1:
		direction = Vector2()
	
	entry_direction = direction
	max_current_speed = pow(distance, 1.5) + 50
	
	entry_direction = direction
