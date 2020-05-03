extends Node
"""
Lida com o comportamento geral do jogo.
"""

signal volume_changed
signal mute_toggled
signal fullscreen_mode_changed
signal score_changed
signal language_changed

enum EFFECTS {
	NONE,
	DIZZY,
	MELT,
	KNOCKBACK,
	SLOWNESS
}
const VOLUME_STEP = 0.1
var score: int setget set_score
onready var language := TranslationServer.get_locale() setget set_language, get_language


func _input(event: InputEvent) -> void:
	
	if Engine.is_editor_hint():
		return
	
	if event.is_action_pressed("full_screen_mode_shift"):
		set_fullscreen()
	
	if event.is_action_pressed("decrease_volume"):
		decrease_volume()
	
	if event.is_action_pressed("increase_volume"):
		increase_volume()
	
	if event.is_action_pressed("restart"):
		var errors: int = get_tree().reload_current_scene()
		
		assert(errors == OK)


# @main
func increase_volume(channel: int = AudioServer.get_bus_index("Master")) -> void:
	set_volume(linear2db(db2linear(AudioServer.get_bus_volume_db(channel))  + VOLUME_STEP), channel)


func decrease_volume(channel: int = AudioServer.get_bus_index("Master")) -> void:
	set_volume(linear2db(db2linear(AudioServer.get_bus_volume_db(channel))  - VOLUME_STEP), channel)


func set_volume(value: float, channel: int = AudioServer.get_bus_index("Master")) -> void:
	"""
	Altera o volume do jogo para o valor (linear) indicado.
	"""
	var is_muted := AudioServer.is_bus_mute(channel)
	var mute := is_muted
	
	if value <= -80:
		
		if not is_muted:
			mute = true
		
	elif value <= 0:
		
		AudioServer.set_bus_volume_db(channel, value)
		emit_signal("volume_changed", channel, value)
		
		if is_muted:
			mute = false
	
	if is_muted != mute:
		mute_toggle(channel)


func mute_toggle(channel: int = AudioServer.get_bus_index("Master")) -> void:
	"""
	Alterna o modo de Mudez do canal áudio indicado.
	"""
	var value = not AudioServer.is_bus_mute(channel)
	
	AudioServer.set_bus_mute(channel, value)
	emit_signal("mute_toggled", channel, value)


# @setters
func set_fullscreen(mode: bool = not OS.window_fullscreen) -> void:
	"""
	Alterna o modo de Tela Cheia.
	"""
	OS.window_fullscreen = mode
	emit_signal("fullscreen_mode_changed")


func set_score(value: int) -> void:
	
	score = value
	emit_signal("score_changed")


func set_language(value: String) -> void:
	
	TranslationServer.set_locale(value)
	language = value
	emit_signal("language_changed", value)


# @getters
func get_language() -> String:
	return language
