extends Node

@onready var heart: Sprite2D = $CanvasLayer/Heart
@onready var heart_2: Sprite2D = $CanvasLayer/Heart2
@onready var heart_3: Sprite2D = $CanvasLayer/Heart3
@onready var heart_4: Sprite2D = $CanvasLayer/Heart4

var scene1: PackedScene = preload("res://Scenes/test_level.tscn")
var scene2: PackedScene = preload("res://Scenes/test_level_2.tscn")

var scenes: Array[PackedScene] = [scene1, scene2]

var player_health: int


func _update_canvas_hearths():
	if player_health == 4:
		heart.modulate.a = 1
		heart_2.modulate.a = 1
		heart_3.modulate.a = 1
		heart_4.modulate.a = 1
	if player_health == 3:
		heart.modulate.a = 1
		heart_2.modulate.a = 1
		heart_3.modulate.a = 1
		heart_4.modulate.a = 0.3
	if player_health == 2:
		heart.modulate.a = 1
		heart_2.modulate.a = 1
		heart_3.modulate.a = 0.3
		heart_4.modulate.a = 0.3
	if player_health == 1:
		heart.modulate.a = 1
		heart_2.modulate.a = 0.3
		heart_3.modulate.a = 0.3
		heart_4.modulate.a = 0.3
	if player_health == 0:
		heart.modulate.a = 0.3
		heart_2.modulate.a = 0.3
		heart_3.modulate.a = 0.3
		heart_4.modulate.a = 0.3
	pass

func select_random_room() -> PackedScene:
	return scenes[randf_range(0, len(scenes))]
