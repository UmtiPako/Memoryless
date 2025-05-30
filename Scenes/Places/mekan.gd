extends Node2D
@export var main : String  = "res://Scenes/Places/main.tscn"

func _ready():
	
	pass


	


func _on_doors_body_entered(body: Node2D) -> void:
	if body.name == "The_Guy":
		get_tree().change_scene_to_file("res://Scenes/Places/main.tscn")
	
	pass # Replace with function body.
