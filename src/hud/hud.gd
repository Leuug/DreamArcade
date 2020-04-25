extends CanvasLayer

onready var score_display: Label = $Display/Score/Value
onready var exit_popup: Popup = $PopUp/Exit


func _ready() -> void:
	var errors: int = Game.connect("score_changed", self, "_on_Game_score_changed")
	
	_on_Game_score_changed()
	assert(errors == OK)


func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("escape"):
		
		exit_popup.popup_centered()
		get_tree().set_input_as_handled()


func _on_Game_score_changed():
	score_display.text = str(Game.score)


func _on_Exit_confirmed() -> void:
	get_tree().quit()


func _on_Exit_about_to_show() -> void:
	
	get_tree().paused = true
	$AnimationPlayer.play("blur_in")


func _on_Exit_popup_hide() -> void:
	
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur_in")
