extends Control

var first_scene : PackedScene = load("res://Scenes/Places/dışarı/sokak_3.tscn")

func _ready() -> void:
	print("test")


func _on_start_button_down() -> void:
	get_tree().change_scene_to_packed(first_scene)
	pass # Replace with function body.


func _on_begin_pressed() -> void:
	get_tree().change_scene_to_packed(first_scene)
	pass # Replace with function body.
