extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var enemy_count

func _ready() -> void:
	GameManager.set_enemy_count_in_room()
	enemy_count = GameManager.enemies_in_room
	if enemy_count == 0:
		collision_shape_2d.disabled = false
	else:
		collision_shape_2d.disabled = true
	GameManager.enemy_killed.connect(enemy_killed)
	
func enemy_killed():
	enemy_count -= 1
	if enemy_count == 0:
		collision_shape_2d.disabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		AnimationManager.transition_to_scene(GameManager.select_random_room())
		collision_shape_2d.disabled = true
