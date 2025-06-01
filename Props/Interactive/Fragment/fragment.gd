extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Animation parameters
@export var float_speed: float = 80.0  # pixels per second upward
@export var grow_scale: float = 1.5     # final scale multiplier
@export var fade_duration: float = 3.0  # seconds to complete the effect

# Internal variables
var initial_scale: Vector2
var initial_modulate: Color
var tween: Tween

func _ready():
	# Store initial values
	initial_scale = scale
	initial_modulate = modulate
	
	# Start the floating fade effect
	start_floating_fade()

func start_floating_fade():
	
	animated_sprite_2d.play("Open")
	
	# Create a new tween
	
	tween = create_tween()
	tween.set_parallel(true)  # Allow multiple animations to run simultaneously
	
	# Animate upward movement
	tween.tween_method(move_upward, 0.0, float_speed * fade_duration, fade_duration)
	
	# Animate scale growth
	tween.tween_property(self, "scale", initial_scale * grow_scale, fade_duration)
	
	# Animate fade out
	var fade_color = initial_modulate
	fade_color.a = 0.0
	tween.tween_property(self, "modulate", fade_color, fade_duration)
	
	# Optional: Remove the node when animation completes
	tween.tween_callback(queue_free).set_delay(fade_duration)

func move_upward(distance: float):
	# Move the Area2D upward by the given distance
	position.y -= float_speed * get_process_delta_time()

# Alternative method if you prefer to use _process instead of tween_method
func _process(delta):
	# Uncomment these lines and comment out the tween_method line above
	# if you prefer manual movement control
	pass

# Function to restart the effect (useful for testing or reusing)
func restart_effect():
	# Reset properties
	scale = initial_scale
	modulate = initial_modulate
	
	# Stop current tween if running
	if tween:
		tween.kill()
	
	# Start new effect
	start_floating_fade()
