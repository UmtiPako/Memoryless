extends CharacterBody2D
class_name Player

var is_taking_hit : bool = false

const SPEED = 300.0
const DASH_SPEED = 800.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue: Label = $Dialogue

var dash_direction := Vector2.ZERO

@export var boundary: MovementArea

@export var camera_2D : Camera2D

var lookin_right : bool = true
var size_swap_reset:bool = false

var is_dashing: bool = false

var active_area: Area2D

@export var dash_duration: float = 0.2
@export var dash_cooldown_time: float = 1.0


var random_start_catchprases: Array[String] = [
	"Bura nere lan?",
	"Ha? Ne yapıyordum?",
	"Zoinks!",
	"NOLUYOR?",
]

func _ready() -> void:
	display_random_dialogue(random_start_catchprases)
	

func display_dialogue(text: String):
	for letter in text:
		dialogue.text += letter
		$letterTimer.start()
		await $letterTimer.timeout
	var tween = create_tween()
	tween.tween_property(dialogue, "modulate:a", 0, 0.5)
	await tween.finished
	dialogue.text = " "

	
func display_random_dialogue(text: Array[String]):
	display_dialogue(random_start_catchprases[randf_range(0, len(random_start_catchprases))])


func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("attack") && animated_sprite_2d.animation == "Idle":
		attack()

		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	if direction:
		if velocity.x > 0:
			# Moving right - face right
			animated_sprite_2d.scale.x = 1
			$Area2D/CollisionShape2D.disabled = false
			$Area2D2/CollisionShape2D.disabled = true
			active_area = $Area2D

		elif velocity.x < 0:
			# Moving left - face left
			animated_sprite_2d.scale.x = -1
			$Area2D/CollisionShape2D.disabled = true
			$Area2D2/CollisionShape2D.disabled = false
			active_area = $Area2D2
		
		velocity = direction * SPEED
		if is_dashing:
			velocity = dash_direction * DASH_SPEED
		else:
			velocity = direction * SPEED
		
		animated_sprite_2d.play("Walk")
	else:
		if (animated_sprite_2d.animation == "Get_Hit" || animated_sprite_2d.animation == "Attack" ):
			await animated_sprite_2d.animation_finished
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		animated_sprite_2d.play("Idle")
		size_swap_reset = true 
	
	if Input.is_action_just_pressed("Dash") and !is_dashing and direction != Vector2.ZERO:
		is_dashing = true
		dash_direction = direction
		$dashTimer.start()
		$CollisionShape2D.disabled = true
		GameManager.player_dashed.emit()
	
	move_and_slide()
	if boundary:
		global_position = boundary.clamp_global_position(global_position)
	
func take_damage(damageTaken: int, enemy_pos: Vector2):
	animated_sprite_2d.play("Get_Hit")
	
	camera_2D.apply_shake()
	
	var tween = create_tween()
	tween.tween_method(func(value): modulate = Color.WHITE.lerp(Color.DIM_GRAY, 1.0 - value), 0.0, 1.0, 0.2)
	
	var direction = 1
	
	if enemy_pos > global_position :
		direction = -1
	
	tween.tween_property(self, "global_position", Vector2(self.position.x + (30 * direction), self.position.y), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	GameManager.player_health -= damageTaken
	await animated_sprite_2d.animation_finished


func attack():
	animated_sprite_2d.play("Attack")
	
	await animated_sprite_2d.animation_finished
	
	for enemy in active_area.get_overlapping_bodies():
		if  enemy.is_in_group("enemies") and enemy.has_method("take_damage"):
			enemy.call("take_damage")


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	$CollisionShape2D.disabled = false
