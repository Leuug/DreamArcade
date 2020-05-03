extends "res://src/bodies/character/player.gd"

signal weapon_changed

var current_weapon: int setget set_current_weapon
var weapons: Array = [
	Weapon.new("KNIFE", 3, 6),
	Weapon.new("GUN", 1, 12, Game.EFFECTS.SLOWNESS),
	Weapon.new("HAMMER", 9, 1, Game.EFFECTS.KNOCKBACK),
	Weapon.new("SABER", 6, 1, Game.EFFECTS.MELT),
	Weapon.new("KATANA", 4, 3, Game.EFFECTS.DIZZY)
]
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var bullet_point: Position2D = $BulletPoint
onready var hurt_box: Area2D = $HurtBox


func _ready() -> void:
	set_current_weapon(0)


func _input(event: InputEvent) -> void:
	._input(event)
	
	if event.is_action_pressed("scroll_up"):
		set_current_weapon(cycle_trought(current_weapon, weapons.size() -1))
	
	if event.is_action_pressed("scroll_down"):
		set_current_weapon(cycle_trought(current_weapon, weapons.size() -1, -1))


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	set_state(State.IDLE)


# @override
func _set_idle() -> void:
	animation_player.play("idle")


func _set_run() -> void:
	animation_player.play("running")


func _set_dash() -> void:
	._set_dash()
	animation_player.play("dash")


func _set_attack() -> void:
	._set_attack()
	animation_player.play(weapons[current_weapon].animation)


func _damage(atk: int) -> void:
	._damage(atk)
	set_state(State.DAMAGE)
	animation_player.play("damage")


func _move_left() -> void:
	
	._move_left()
	animated_sprite.flip_h = true
	bullet_point.position.x = -abs(bullet_point.position.x)
	hurt_box.scale.x = -abs(hurt_box.scale.x)
	hurt_box.position.x = -14 # WATCH -> O centro do sprite ficou deslocado


func _move_right() -> void:
	
	._move_right()
	animated_sprite.flip_h = false
	bullet_point.position.x = abs(bullet_point.position.x)
	hurt_box.scale.x = abs(hurt_box.scale.x)
	hurt_box.position.x = 0 # WATCH -> O centro do sprite ficou deslocado


# @main
func _shoot() -> void:
	"""
	Instancia uma bala na posição do bullet_point.
	"""
	var new_bullet: Area2D = bullet.instance()
	
	new_bullet.global_position = bullet_point.global_position
	new_bullet.rotation = deg2rad(180) if animated_sprite.flip_h else deg2rad(0)
	get_tree().current_scene.add_child(new_bullet)
	._set_attack()


func damage_body(body: CollisionObject2D) -> void:
	
	if body.has_method("take_damage"):
		body.take_damage(max(weapons[current_weapon].damage_modifier - 1, 1), global_position, weapons[current_weapon].effect)


# @setters
func set_current_weapon(value: int) -> void:
	
	current_weapon = value
	emit_signal("weapon_changed", weapons[current_weapon].name)
	set_max_combos(weapons[current_weapon].max_combos)
