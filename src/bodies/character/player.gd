extends "res://src/bodies/characters.gd"
"""
Script base dos Personagens do Jogador.
"""
signal weapon_changed
signal combo_changed
signal max_combos_changed

const SMOOTHNESS = 5
const DASH_TIME = .15
const bullet: PackedScene = preload("res://src/objects/bullet.tscn")

enum State {
	IDLE,
	RUN,
	DASH,
	ATK
}

export(float, 0, 9999) var dash_max_speed: float = 5
export(float, 0, 9999) var dash_min_speed: float = 1

var state: int setget set_state
var combo: int setget set_combo
var max_combos: int setget set_max_combos
var current_direction: Vector2 = Vector2.RIGHT
var dash_direction: Vector2

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var dash_timer: Timer = $DashTimer
onready var combo_timer: Timer = $ComboTimer


func _ready() -> void:
	get_tree().call_group("enemies", "set_player", self)


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("attack") and combo != max_combos:
		set_state(State.ATK)
	
	if event.is_action_pressed("move_left"):
		_move_left()
	
	if event.is_action_pressed("move_right"):
		_move_right()
	
	if event.is_action_pressed("move_up"):
		current_direction = Vector2.UP
	
	if event.is_action_pressed("move_down"):
		current_direction = Vector2.DOWN
	
	if event.is_action_pressed("dash"):
		set_state(State.DASH)


func _physics_process(delta: float) -> void:
	
	match state:
		State.IDLE, State.RUN:
			_move(delta)
		
		State.DASH:
			_dash(delta)


# @signals
func _on_DashTimer_timeout() -> void:
	
	var direction: int = round(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	set_state(State.RUN)
	motion = Vector2.ZERO
	
	if direction == 0:
		return
	
	if direction > 0:
		_move_right()
		
	else:
		_move_left()


func _on_ComboTimer_timeout() -> void:
	set_combo(combo - 1)


# @main
func _set_idle() -> void:
	"""
	Função virtual que é chamada quando o jogador entra no state IDLE.
	"""
	pass


func _set_run() -> void:
	"""
	Função virtual que é chamada quando o jogador entra no state RUN.
	"""
	pass


func _set_attack() -> void:
	"""
	Chamada quando o jogador entra no state ATK.
	"""
	set_combo()


func _set_dash() -> void:
	"""
	Chamado quando o jogador entrar no state DASH.
	Configura o personagem para permitir que o dash seja executado.
	"""
	var mouse_position: Vector2 = get_local_mouse_position()
	var dash_angle: float = rad2deg(mouse_position.angle())
	
	dash_timer.start(DASH_TIME)
	motion = mouse_position.clamped(1) * dash_max_speed / 2
	
	if dash_angle > -90 and dash_angle < 90:
		_move_right()
	
	else:
		_move_left()


func _move(delta: float) -> void:
	"""
	Move o player de acordo com os eixos recebidos pelo input do jogador.
	"""
	var axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		apply_friction(acceleration * delta)
		set_state(State.IDLE)
		
	else:
		apply_movement(axis * acceleration * delta)
		set_state(State.RUN)
	
	move_and_collide(motion * delta)


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
	"""
	Chamado quando o jogador vira à esquerda.
	"""
	current_direction = Vector2.LEFT


func _move_right() -> void:
	"""
	Chamado quando o jogador vira à direita.
	"""
	current_direction = Vector2.RIGHT


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


# @setters
func set_combo(value: int = int(min(combo + 1, max_combos))) -> void:
	combo = value
	emit_signal("combo_changed", combo)
	
	if combo > 0 and combo_timer.is_stopped():
		combo_timer.start()


func set_max_combos(value: int) -> void:
	
	max_combos = value
	emit_signal("max_combos_changed", max_combos)


func set_state(value: int = State.IDLE) -> void:
	
	if state != value:
		state = value
		
		match state:
			State.IDLE:
				_set_idle()
			
			State.RUN:
				_set_run()
			
			State.ATK:
				_set_attack()
			
			State.DASH:
				_set_dash()



class Weapon extends Resource:
	"""
	Classe-base para as armas do jogador.
	"""
	var damage_modifier: int
	var max_combos: int
	var identifier: String
	var name: String
	var animation: String
	
	
	func _init(localization_identifier: String, damage: int, combos: int) -> void:
		
		identifier = localization_identifier
		name = tr(identifier)
		animation = localization_identifier.to_lower()
		damage_modifier = damage
		max_combos = combos
