extends RigidBody2D

@export var SPEED = 20000 # This is a very high value for apply_force, might want to adjust
var onetime = true

func _ready():
	self.freeze = true

func _physics_process(delta: float) -> void:
	if self.position.y < -80 or position.y > 2000 :
		self.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if onetime:
		onetime = false
		# self.freeze = false # <--- This was the line causing the error
		self.set_deferred("freeze", false) # <--- Corrected line
		
		print("AAA - Unfreezing and applying force.")
		
		# It's generally safer to use global positions for angle calculations
		# unless you are certain about the relative node structure.
		var direction_to_self = body.global_position.angle_to_point(self.global_position)
		
		# Create a directional vector and then scale it by SPEED
		# apply_force expects a force vector, not a velocity.
		# The magnitude of SPEED (5000) might be very large for a force,
		# you might want to adjust it or use apply_impulse if it's meant to be an instant kick.
		var force_vector = Vector2.RIGHT.rotated(direction_to_self) * SPEED 
		
		print("Applying force vector:", force_vector)
		apply_force(force_vector)
