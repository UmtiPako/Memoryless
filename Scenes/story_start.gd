extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		pass
		print("load scene")
		
		
	pass


func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://UI/endings/Start.tscn")
