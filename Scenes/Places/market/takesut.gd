extends Area2D


func _on_body_entered(body: Player) -> void:
	GlobalTimer.stop_timer()
	get_tree().change_scene_to_file("res://UI/endings/SutEnding1.tscn")
