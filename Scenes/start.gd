extends Button

@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_down() -> void:
	animation_player.play("pop")
	GlobalTimer.is_game_started = true
	get_tree().change_scene_to_file("res://Scenes/Places/dışarı/sokak_1.tscn")
	pass # Replace with function body.
