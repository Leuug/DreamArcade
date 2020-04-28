extends "res://src/bodies/characters.gd"
"""
Script base dos Personagens do Jogador.
"""
signal weapon_changed
signal combo_changed

const SMOOTHNESS = 5
const DASH_TIME = .15
const bullet: PackedScene = preload("res://src/objects/bullet.tscn")

enum State {
	IDLE,
	RUN,
	DASH
}
enum Weapons {
	KNIFE,
	GUN
}

export(float, 0, 9999) var dash_max_speed: float = 5
export(float, 0, 9999) var dash_min_speed: float = 1

var is_atacking: bool setget set_is_atacking
var state: int
var current_weapon: int
var combo: int setget set_combo
var max_combos: int = 6
var current_direction: Vector2 = Vector2.RIGHT
var dash_direction: Vector2
var damaged_bodies: PoolIntArray = []

onready var weapon_ray: RayCast2D = $Weapon
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var dash_timer: Timer = $DashTimer
onready var combo_timer: Timer = $ComboTimer


func _ready() -> void:
	get_tree().call_group("enemies", "set_player", self)


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("attack") and combo != max_combos:
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
	
	if event.is_action_pressed("scroll_up"):
		set_current_weapon(cycle_trought(current_weapon, Weapons.size() -1))
	
	if event.is_action_pressed("scroll_down"):
		set_current_weapon(cycle_trought(current_weapon, Weapons.size() -1, -1))


func _physics_process(delta: float) -> void:
	
	match state:
		State.IDLE, State.RUN:
			_move(delta)
		
		State.DASH:
			_dash(delta)
	
	if is_atacking and weapon_ray.is_colliding():
		damage_body(weapon_ray.get_collider())


func _on_DashTimer_timeout() -> void:
	
	var direction: int = round(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	state = State.RUN
	motion = Vector2.ZERO
	
	if direction == 0:
		return
	
	if direction > 0:
		_move_right()
		
	else:
		_move_left()


func _on_ComboTimer_timeout() -> void:
	set_combo(combo - 1)


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
	
	match current_weapon:
		Weapons.KNIFE:
			_cut()
		
		Weapons.GUN:
			_shoot()


func _cut() -> void:
	
	match current_direction:
		Vector2.RIGHT:
			animation_player.play("attack")
		
		Vector2.LEFT:
			animation_player.play("attack _left")
	
	set_combo(min(combo + 1, max_combos))


func _shoot() -> void:
	
	var new_bullet: Area2D = bullet.instance()
	var mouse_position: Vector2 = get_local_mouse_position()
	
	new_bullet.rotation = mouse_position.angle()
	new_bullet.global_position = global_position + mouse_position.clamped(1) * 8
	
	get_tree().current_scene.add_child(new_bullet)


func get_input_axis() -> Vector2:
	"""
	Retorna um eixo (vetor de direção) conforme as teclas pressionadas pelo jogador.
	"""
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()


static func cycle_trought(value: int, max_value: int, amount: int = 1) -> int:
	"""
	Percorre um valor de forma cíclica. Ex.:
		value = 1, max_value = 3, amount = 12. Contando 12 vezes entre 0 e 3, começando do 1, o valor final será 1.
		1+1= 2, 2+1= 3 -> 0+1= 1, 1+1 = 2, 2+1 = 2 -> ... 0+1 = 1
	"""
	var new_value: int = value + amount
	var pointer: int
	
	if new_value < 0: # WATCH
		pointer = (int(abs(value - amount)) % (max_value + 1))
		new_value = max_value + 1 - pointer
	
	if new_value > max_value: # WATCH
		
		pointer = ((value + amount) % (max_value + 1))
		
		if pointer + value >= max_value:
			new_value = pointer
		
		else:
			new_value = value + pointer
	
#	while new_value > max_value: # Equivalente algoritmico do método acima.
#		new_value -= max_value
	
	return new_value


func set_is_atacking(value: bool) -> void:
	
	if not value:
		damaged_bodies = []
	
	is_atacking = value


func set_current_weapon(value: int) -> void:
	current_weapon = value
	emit_signal("weapon_changed", current_weapon)


func set_combo(value: int) -> void:
	combo = value
	emit_signal("combo_changed", combo)
	
	if combo > 0 and combo_timer.is_stopped():
		combo_timer.start()
