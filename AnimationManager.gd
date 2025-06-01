extends Node

var transition_scene: PackedScene = preload("res://Scenes/transitionlayer.tscn")
var rect: ColorRect

var initialized := false

func _ready() -> void:
	if initialized:
		return
	initialized = true

	var transition_instance = transition_scene.instantiate()
	add_child(transition_instance)

	rect = transition_instance.get_node("ColorRect")
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.modulate.a = 0.0

func transition_to_scene(scene: PackedScene):
	fade_out(0.5)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(scene)
	fade_in(0.5)

func fade_out(duration: float):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, duration)

func fade_in(duration: float):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration)
