extends Timer

var is_game_started: bool = false
var timer_started = false

func _process(delta: float) -> void:
	if is_game_started and not timer_started:
		timer_started = true
		print("timer started")
		self.start(30)

func _on_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/lose.tscn")
	pass # Replace with function body.
