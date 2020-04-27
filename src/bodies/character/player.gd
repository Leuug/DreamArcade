extends "res://src/bodies/characters.gd"
"""
Script base dos Personagens do Jogador.
"""
const SMOOTHNESS = 5
const DASH_TIME = .15
enum State {
	IDLE,
	RUN,
	DASH
}

export(int, 0, 9999) var strength: int = 1
export(float, 0, 9999) var dash_max_speed: float = 5
export(float, 0, 9999) var dash_min_speed: float = 1

var is_atacking: bool setget set_is_atacking
var current_direction: Vector2 = Vector2.RIGHT
var dash_direction: Vector2
var state: int
var damaged_bodies: PoolIntArray = []

onready var weapon_ray: RayCast2D = $Weapon
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var dash_timer: Timer = $DashTimer


func _ready() -> void:
	get_tree().call_group("enemies", "set_player", self)


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("attack"):
		_attack()
	
	if event.is_action_pressed("move_left"):
		_move_left()
	
	if event.is_action_pressed("move_right"):
		_move_right()
	
	if event.is_action_pressed("move_up"):
		current_direction = Vector2.UP
	
	if event.is_action_pressed("move_down"):
		current_direction = Vector2.DOWN
	
	if event.is_action_pressed("dash"):
		_set_dash()


func _physics_process(delta: float) -> void:
	
	match state:
		State.IDLE, State.RUN:
			_move(delta)
		
		State.DASH:
			_dash(delta)
	
	if is_atacking and weapon_ray.is_colliding():
		damage_body(weapon_ray.get_collider())


func _on_DashTimer_timeout() -> void:
	state = State.RUN
	motion = Vector2.ZERO
	
	if Input.get_action_strength("move_right") - Input.get_action_strength("move_left") > 0:
		_move_right()
		
	else:
		_move_left()


func damage_body(body: CollisionObject2D) -> void:
	
	if body.has_method("take_damage") and not body.get_instance_id() in damaged_bodies:
		
		damaged_bodies.append(body.get_instance_id())
		body.take_damage(strength, global_position)


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


func _set_dash() -> void:
	"""
	Configura o personagem para permitir que o dash seja executado.
	"""
	var mouse_position: Vector2 = get_local_mouse_position()
	var dash_angle: float = rad2deg(mouse_position.angle())
	
	state = State.DASH
	dash_timer.start(DASH_TIME)
	motion = mouse_position.clamped(1) * dash_max_speed / 2
	
	if dash_angle > -90 and dash_angle < 90:
		_move_right()
	
	else:
		_move_left()


func _dash(delta: float) -> void:
	"""
	Executa o movimento de dash.
	"""
	var timing: float = DASH_TIME - dash_timer.time_left
	
	if timing < DASH_TIME / 2:
		motion = lerp(motion, current_direction * dash_max_speed, delta * 0.0005)
	
	else:
		motion = lerp(motion, current_direction * dash_min_speed, delta * 0.0005)
	
	move_and_collide(motion)


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
	
	if not value:
		damaged_bodies = []
	
	is_atacking = value
