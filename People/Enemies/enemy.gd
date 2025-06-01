extends CharacterBody2D

var is_dead:bool = false

var fragment:PackedScene = preload("res://Props/Interactive/Fragment/fragment.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var playerL: PackedScene
@export var move_speed: float = 70.0
@export var attack_damage: int = 1
@export var attack_range_distance: float = 20.0 # Should match AttackRange's shape
@export var attack_cooldown: float = 1.5 # Seconds
@export var enemy_health: int = 5
@export var can_be_damaged: bool = false
@export var navigation_region: NavigationRegion2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_range_area: Area2D = $Area2D
@onready var attack_range_area2: Area2D = $Area2D2
@onready var attack_cooldown_timer: Timer = $AttackTimer
@onready var nav_update_timer: Timer = $NavTimer
# @onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # If you have animations

var player: Node2D = null
var _is_player_in_attack_range: bool = false
var _can_attack: bool = true
var _is_attacking: bool = false # To prevent moving while in attack animation

# A simple state machine could be more robust, but this works for now
enum State { IDLE, CHASING, ATTACKING ,DEAD}
var current_state: State = State.IDLE

func _ready():
	
	move_speed = randf_range(100,150)
	$DashDelay.wait_time = randf_range(0.8, 1.4)
	GameManager.player_dashed.connect(player_dashed)
	
	# Attempt to find the player immediately
	# More robust: have spawner or game manager assign the player
	var player_nodes = get_tree().get_nodes_in_group("player")
	if not player_nodes.is_empty():
		player = player_nodes[0] as CharacterBody2D # Cast to Node2D or your player type
	else:
		printerr("Enemy couldn't find player!")
		# queue_free() # Or handle appropriately

	# Configure AttackRange Area2D's collision shape radius if needed
	# (Alternatively, set it in the editor and ensure attack_range_distance matches)
	if attack_range_area.get_child(0) is CollisionShape2D or attack_range_area2.get_child(0) is CollisionShape2D:
		var shape = attack_range_area.get_child(0).shape
		var shape2 = attack_range_area2.get_child(0).shape
		
		if shape is CircleShape2D:
			shape.radius = attack_range_distance
		elif shape2 is CircleShape2D:
			shape2.radius = attack_range_distance
		# Add similar for RectangleShape2D if you use that

	attack_range_area.body_entered.connect(_on_attack_range_body_entered)
	attack_range_area.body_exited.connect(_on_attack_range_body_exited)
	
	attack_range_area2.body_entered.connect(_on_attack_range_body_entered)
	attack_range_area2.body_exited.connect(_on_attack_range_body_exited)
	
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timer_timeout)
	nav_update_timer.timeout.connect(_on_nav_update_timer_timeout)

var dash_delay: bool = false

func player_dashed():
	if !is_dead:
		$DashDelay.start()
		dash_delay = true

func _process(delta: float) -> void:	
	if !dash_delay && !is_dead:
		if (player.global_position.x < global_position.x):
				animated_sprite_2d.flip_h = true
				$Area2D/CollisionShape2D.disabled = true
				$Area2D2/CollisionShape2D.disabled = false
		else:
				animated_sprite_2d.flip_h = false
				$Area2D/CollisionShape2D.disabled = false
				$Area2D2/CollisionShape2D.disabled = true		
	
	update_layer_by_position()

func _physics_process(_delta: float):
	
	
	if not player or not is_instance_valid(player):
		# Player might have been removed (e.g. died)
		# Consider what enemies should do here (e.g. go idle, despawn)
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if not is_dead and animated_sprite_2d.animation == "Hurt":
		await animated_sprite_2d.animation_finished
	
	match current_state:
		State.IDLE:
			# Optionally, transition to CHASING if player is detected nearby
			# For now, spawner will likely make them chase immediately
			if player:
				current_state = State.CHASING
				_update_navigation_target() # Start chasing

		State.CHASING:
			if _is_player_in_attack_range and _can_attack and animated_sprite_2d.animation != "Hurt":
				current_state = State.ATTACKING
				_perform_attack()
			else:
				if navigation_agent.is_navigation_finished():
					# Reached player or cannot reach, stop moving
					velocity = Vector2.ZERO
				else:
					var next_pos = navigation_agent.get_next_path_position()
					var direction = global_position.direction_to(next_pos)
					velocity = direction * move_speed
					# Optional: Face the direction of movement
					# look_at(next_pos) # If sprite is oriented correctly
				move_and_slide()

		State.ATTACKING:
			# Attack animation might play here.
			# For simplicity, we assume attack is instant and then cooldown starts.
			# If you have an attack animation, wait for it to finish
			# before transitioning out of ATTACKING state.
			# For now, _perform_attack handles transition to cooldown.
			velocity = Vector2.ZERO # Stop moving while attacking
			move_and_slide()


func _update_navigation_target():
	if player and is_instance_valid(player) and navigation_agent:
		navigation_agent.target_position = player.global_position

func _perform_attack():
	if not _is_player_in_attack_range or not _can_attack or not player:
		current_state = State.CHASING # Go back to chasing if conditions not met
		return

	_can_attack = false
	attack_cooldown_timer.start(attack_cooldown)
	# If you have an attack animation:
	_is_attacking = true
	animated_sprite_2d.play("Attack")
	await animated_sprite_2d.animation_finished
		# Assuming player has a take_damage method
	if player.has_method("take_damage") and _is_player_in_attack_range:
		player.call("take_damage", attack_damage, self.global_position)
	
	_is_attacking = false
	if current_state != State.DEAD:
		current_state = State.CHASING # Or IDLE if player moved out of range
	
	# Without animation, immediately go to chasing or check range again
	if _is_player_in_attack_range: # Still in range? Could attack again after CD
		pass # Stay in ATTACKING to be re-evaluated or go to a COOLDOWN state
	elif current_state != State.DEAD: # Player moved out during the instant attack
		current_state = State.CHASING


# --- Signal Callbacks ---

func _on_attack_range_body_entered(body: Node2D):
	if body == player: # Or body.is_in_group("player")
		_is_player_in_attack_range = true
		# If not already attacking and can attack, consider immediate transition
		if current_state == State.CHASING and _can_attack:
			current_state = State.ATTACKING
			if not is_dead:
				_perform_attack() # Or just set state and let _physics_process handle it

func _on_attack_range_body_exited(body: Node2D):
	if body == player: # Or body.is_in_group("player")
		_is_player_in_attack_range = false
		if current_state == State.ATTACKING and not _is_attacking: # If not mid-animation
			current_state = State.CHASING # Player moved out, go back to chasing

func _on_attack_cooldown_timer_timeout():
	_can_attack = true
	# After cooldown, if still in range and in ATTACKING state, try to attack again
	# Or, more simply, always go back to CHASING to re-evaluate
	if current_state == State.ATTACKING and _is_player_in_attack_range:
		if not is_dead:
			_perform_attack() # Try to attack again immediately if still in range
	else:
		current_state = State.CHASING # Default back to chasing

func _on_nav_update_timer_timeout():
	if not is_dead:
		if current_state == State.CHASING and player and is_instance_valid(player):
			animated_sprite_2d.play("Run")
			_update_navigation_target()

func update_layer_by_position():
	var y_pos = global_position.y
	var player_y_pos = player.global_position.y
	# Calculate layer based on Y position
	# Y position range: 920-1000 (80 units total)
	# Layer changes every 10 units
	# This gives us 8 different layers (0-7)
	
	if player_y_pos < y_pos:
		self.z_index = 1
	else:
		self.z_index = 0


		

# Public function for the spawner to activate the enemy
func set_target(target_node: Node2D):
	player = target_node
	if player:
		current_state = State.CHASING
		_update_navigation_target() # Initial path calculation
	else:
		current_state = State.IDLE

func take_damage():
	if enemy_health > 0:
		var tween = create_tween()
	
		var direction = -1
	
		if player.global_position.x - self.global_position.x < 0:
			direction = 1
	
		$damage_sfx.stop()
		$damage_sfx.play()

	
		tween.tween_property(self, "global_position", Vector2(self.position.x +  30 * direction, self.position.y), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		animated_sprite_2d.play("Hurt")
		var tween2 = create_tween()
		tween2.tween_method(func(value): modulate = Color.WHITE.lerp(Color.DIM_GRAY, 1.0 - value), 0.0, 1.0, 0.2)
		await animated_sprite_2d.animation_finished
		enemy_health -= 1
		if enemy_health <= 0:
			_die()

func _die():
	enemy_health = -2
	GameManager.enemy_killed.emit()
	$damage_sfx.stop()
	$death_sfx.play()
	for node in get_children():
		if node is not AnimatedSprite2D and node is not AudioStreamPlayer2D:
			node.queue_free()

	#navigation_agent.navigation_finished.emit()
	is_dead = true
	current_state = State.DEAD
	animated_sprite_2d.play("Dead")
	await  animated_sprite_2d.animation_finished
	_drop_fragment()

func _on_dash_delay_timeout() -> void:
	dash_delay = false

func _drop_fragment():
	GlobalTimer.reset_timer()
	var fragment_instance = fragment.instantiate()
	fragment_instance.global_position = global_position
	get_parent().add_child(fragment_instance)
	pass
