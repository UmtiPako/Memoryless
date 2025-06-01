extends Sprite2D
@onready var timer: Timer = $"../Timer"
var over : bool = false
func _process(delta: float) -> void:
	if not over:
		self.position.y = self.position.y -80*delta
	
func _ready() -> void:
	timer.start()


func _on_timer_timeout() -> void:
	over = true
