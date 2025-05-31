extends Node

signal player_dashed

var ev_sahne: PackedScene = preload("res://Scenes/Places/ev/sahne_ev.tscn")
var sokak1: PackedScene = preload("res://Scenes/Places/dışarı/sokak_1.tscn")
var sokak2: PackedScene = preload("res://Scenes/Places/dışarı/sokak_2.tscn")
var sokak3: PackedScene = preload("res://Scenes/Places/dışarı/sokak_3.tscn")

var scenes: Array[PackedScene] = [ev_sahne, sokak1, sokak2, sokak3]

var player_health: int = 4

func _process(delta: float) -> void:
	pass

func select_random_room() -> PackedScene:
	return scenes[randf_range(0, len(scenes))]

func hit_stop(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout
	Engine.time_scale = 1
