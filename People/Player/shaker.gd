extends Camera2D

@export var random_strenght: float = 10.0
@export var shakeFade: float = 5
@onready var shake_timer: Timer = $"../shakeTimer"

var rng = RandomNumberGenerator.new()

var shakeStrength: float = 0.0

func _process(delta: float) -> void:
	if shakeStrength > 0:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		offset = random_offset()
		
func apply_shake():
	if shake_timer.is_stopped():
		shakeStrength = random_strenght

func random_offset():
	return Vector2(rng.randf_range(-shakeStrength,shakeStrength),rng.randf_range(-shakeStrength, shakeStrength))
