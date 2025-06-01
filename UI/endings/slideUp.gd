extends Sprite2D
@onready var timer: Timer = $"../Timer"
var over : bool = false
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		GlobalTimer.is_game_started = true
		get_tree().change_scene_to_file("res://Scenes/Places/dışarı/sokak_2.tscn")
		
	
	if not over:
		self.position.y = self.position.y -80*delta
	
func _ready() -> void:
	timer.start()


func _on_timer_timeout() -> void:
	over = true
