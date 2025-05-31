extends CharacterBody2D

var is_taking_hit : bool = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var HEALTH = 4

var lookin_right : bool = true
var size_swap_reset:bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		attack()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		if velocity.x > 0:
			# Moving right - face right
			animated_sprite_2d.scale.x = 1
		elif velocity.x < 0:
			# Moving left - face left
			animated_sprite_2d.scale.x = -1
		
		velocity.x = direction * SPEED
		animated_sprite_2d.play("Walk")
	else:
		if (animated_sprite_2d.animation == "Get_Hit" || animated_sprite_2d.animation == "Attack" ):
			await animated_sprite_2d.animation_finished
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.play("Idle")
		size_swap_reset = true 
	
	
	move_and_slide()

func take_damage(damageTaken: int):
	animated_sprite_2d.play("Get_Hit")
	HEALTH -= damageTaken
	await animated_sprite_2d.animation_finished
	

func attack():
	animated_sprite_2d.play("Attack")
	for enemy in $Area2D.get_overlapping_bodies():
		if enemy.has_method("take_damage"):
			enemy.call("take_damage") 
	await animated_sprite_2d.animation_finished
