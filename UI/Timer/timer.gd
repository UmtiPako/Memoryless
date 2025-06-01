extends Timer

var is_game_started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_game_started:
		start()
	pass # Replace with function body.


func _on_timeout() -> void:
	#Load ending screen
	pass # Replace with function body.
