extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var move_speed: float = 70.0
@export var attack_damage: int = 10
@export var attack_range_distance: float = 20.0 # Should match AttackRange's shape
@export var attack_cooldown: float = 1.5 # Seconds

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_range_area: Area2D = $Area2D
@onready var attack_cooldown_timer: Timer = $AttackTimer
@onready var nav_update_timer: Timer = $NavTimer
# @onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # If you have animations

var player: Node2D = null
var _is_player_in_attack_range: bool = false
var _can_attack: bool = true
var _is_attacking: bool = false # To prevent moving while in attack animation

# A simple state machine could be more robust, but this works for now
enum State { IDLE, CHASING, ATTACKING }
var current_state: State = State.IDLE

func _ready():
	# Add to enemies group for easier management if needed
	add_to_group("enemies")

	# Attempt to find the player immediately
	# More robust: have spawner or game manager assign the player
	var player_nodes = get_tree().get_nodes_in_group("player")
	if not player_nodes.is_empty():
		player = player_nodes[0] as CharacterBody2D # Cast to Node2D or your player type
	else:
		printerr("Enemy couldn't find player!")
		# queue_free() # Or handle appropriately
		
	var direction = player.position.x - self.position.x
	
	if sign(direction) == -1:
		self.scale.x = -1
	else:
		self.scale.x = 1

	# Configure AttackRange Area2D's collision shape radius if needed
	# (Alternatively, set it in the editor and ensure attack_range_distance matches)
	if attack_range_area.get_child(0) is CollisionShape2D:
		var shape = attack_range_area.get_child(0).shape
		if shape is CircleShape2D:
			shape.radius = attack_range_distance
		# Add similar for RectangleShape2D if you use that

	attack_range_area.body_entered.connect(_on_attack_range_body_entered)
	attack_range_area.body_exited.connect(_on_attack_range_body_exited)
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_timer_timeout)
	nav_update_timer.timeout.connect(_on_nav_update_timer_timeout)


func _physics_process(_delta: float):
	
	
	if not player or not is_instance_valid(player):
		# Player might have been removed (e.g. died)
		# Consider what enemies should do here (e.g. go idle, despawn)
		velocity = Vector2.ZERO
		move_and_slide()
		return

	match current_state:
		State.IDLE:
			# Optionally, transition to CHASING if player is detected nearby
			# For now, spawner will likely make them chase immediately
			if player:
				current_state = State.CHASING
				_update_navigation_target() # Start chasing

		State.CHASING:
			if _is_player_in_attack_range and _can_attack:
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

	print(name + " attacks player!")
	# Assuming player has a take_damage method
	if player.has_method("take_damage"):
		player.call("take_damage", attack_damage)

	_can_attack = false
	attack_cooldown_timer.start(attack_cooldown)
	# If you have an attack animation:
	_is_attacking = true
	animated_sprite_2d.play("Attack")
	await animated_sprite_2d.animation_finished
	_is_attacking = false
	current_state = State.CHASING # Or IDLE if player moved out of range
	
	# Without animation, immediately go to chasing or check range again
	if _is_player_in_attack_range: # Still in range? Could attack again after CD
		pass # Stay in ATTACKING to be re-evaluated or go to a COOLDOWN state
	else: # Player moved out during the instant attack
		current_state = State.CHASING


# --- Signal Callbacks ---

func _on_attack_range_body_entered(body: Node2D):
	if body == player: # Or body.is_in_group("player")
		_is_player_in_attack_range = true
		# If not already attacking and can attack, consider immediate transition
		if current_state == State.CHASING and _can_attack:
			current_state = State.ATTACKING
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
		_perform_attack() # Try to attack again immediately if still in range
	else:
		current_state = State.CHASING # Default back to chasing

func _on_nav_update_timer_timeout():
	if current_state == State.CHASING and player and is_instance_valid(player):
		animated_sprite_2d.play("Run")
		_update_navigation_target()

# Public function for the spawner to activate the enemy
func set_target(target_node: Node2D):
	player = target_node
	if player:
		current_state = State.CHASING
		_update_navigation_target() # Initial path calculation
	else:
		current_state = State.IDLE
