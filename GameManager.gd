extends Node

var scene1: PackedScene = preload("res://Scenes/test_level.tscn")
var scene2: PackedScene = preload("res://Scenes/test_level_2.tscn")

var scenes: Array[PackedScene] = [scene1, scene2]

var player_health: int


func select_random_room() -> PackedScene:
	return scenes[randf_range(0, len(scenes))]
