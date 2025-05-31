extends Node

signal player_dashed

var scene1: PackedScene = preload("res://Scenes/test_level.tscn")
var scene2: PackedScene = preload("res://Scenes/test_level_2.tscn")

var scenes: Array[PackedScene] = [scene1, scene2]

var player_health: int = 4

func _process(delta: float) -> void:
	pass

func select_random_room() -> PackedScene:
	return scenes[randf_range(0, len(scenes))]

func hit_stop(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1
