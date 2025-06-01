extends Timer

var is_game_started: bool = false
var timer_started = false
var ringing = false

func _process(delta: float) -> void:
	if is_game_started and not timer_started:
		timer_started = true
		print("timer started")
		self.start(30)
	if time_left < 10 and not ringing:
		ringing = true
		$AudioStreamPlayer2D.play(0)

func _on_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/lose.tscn")

func reset_timer():
	start(30)
	ringing = false
