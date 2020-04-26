extends "res://src/bodies/characters.gd"
"""
Script base dos Personagens do Jogador.
"""
const SMOOTHNESS = 5
enum State {
	IDLE,
	RUN
}

export(int, 0, 9999) var strength: int = 1
var is_atacking: bool setget set_is_atacking
var current_direction: Vector2 = Vector2.RIGHT
var state: int

onready var weapon_ray: RayCast2D = $Weapon
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	get_tree().call_group("enemies", "set_player", self)


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("attack"):
		_attack()
	
	if event.is_action_pressed("move_left"):
		_move_left()
	
	if event.is_action_pressed("move_right"):
		_move_right()


func _physics_process(delta: float) -> void:
	_move(delta)
	
	if is_atacking and weapon_ray.is_colliding():
		damage_body(weapon_ray.get_collider())


func damage_body(body: PhysicsBody2D) -> void:
	
	if body.has_method("take_damage"):
		body.take_damage(strength)


func _move(delta: float) -> void:
	"""
	Move o player de acordo com os eixos recebidos pelo input do jogador.
	"""
	var axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		apply_friction(acceleration * delta)
		state = State.IDLE
		
	else:
		apply_movement(axis * acceleration * delta)
		state = State.RUN
	
	move_and_collide(motion * delta)


func _move_left() -> void:
	
	current_direction = Vector2.LEFT


func _move_right() -> void:
	
	current_direction = Vector2.RIGHT


func _attack() -> void:
	
	match current_direction:
		Vector2.RIGHT:
			animation_player.play("attack")
		
		Vector2.LEFT:
			animation_player.play("attack _left")


func get_input_axis() -> Vector2:
	"""
	Retorna um eixo (vetor de direção) conforme as teclas pressionadas pelo jogador.
	"""
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()


func set_is_atacking(value: bool) -> void:
	is_atacking = value
