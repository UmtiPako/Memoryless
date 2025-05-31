extends CharacterBody2D

var is_taking_hit : bool = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue: Label = $Dialogue

@export var HEALTH = 4
@export var boundary: MovementArea

@export var camera_2D : Camera2D

var lookin_right : bool = true
var size_swap_reset:bool = false

var random_start_catchprases: Array[String] = [
	"Bura nere lan?",
	"Bababoi!",
	"Zoinks!",
	"NOLUYO",
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
	
	if Input.is_action_just_pressed("ui_accept") && animated_sprite_2d.animation != "Get_Hit":
		attack()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	if direction:
		if velocity.x > 0:
			# Moving right - face right
			animated_sprite_2d.scale.x = 1
			$Area2D.visible = true
			$Area2D2.visible = false

		elif velocity.x < 0:
			# Moving left - face left
			animated_sprite_2d.scale.x = -1
			$Area2D.visible = false
			$Area2D2.visible = true
		
		velocity = direction * SPEED
		animated_sprite_2d.play("Walk")
	else:
		if (animated_sprite_2d.animation == "Get_Hit" || animated_sprite_2d.animation == "Attack" ):
			await animated_sprite_2d.animation_finished
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		animated_sprite_2d.play("Idle")
		size_swap_reset = true 
	
	
	move_and_slide()
	if boundary:
		global_position = boundary.clamp_global_position(global_position)

func take_damage(damageTaken: int):
	animated_sprite_2d.play("Get_Hit")
	var tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(self.position.x +  -sign(self.scale.x) * (30), self.position.y), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	HEALTH -= damageTaken
	await animated_sprite_2d.animation_finished
	

func attack():
	animated_sprite_2d.play("Attack")
	if $Area2D.has_overlapping_bodies(): 
		camera_2D.apply_shake()
		
	for enemy in $Area2D.get_overlapping_bodies():
		if  enemy.is_in_group("enemies") and enemy.has_method("take_damage"):
			enemy.call("take_damage")

	
