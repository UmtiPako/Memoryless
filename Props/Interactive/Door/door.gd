extends Node2D
@onready var SolWorldBorder = $SolWolrdBorder
@onready var SagWorldBorder = $SagWorldBorder

@export var SolEnabled = false
@export var SagEnabled = false
# Called when the node enters the scene tree for the first time.
func ready() -> void:
	if SolEnabled == true :
		SolWorldBorder.show()
	else: 
		SolWorldBorder.hide()
	if SagEnabled == true :
		SagWorldBorder.show()
	else:
		SagWorldBorder.hide()
func lock():
	SolWorldBorder.hide()
	SagWorldBorder.hide()
func unlock():
	if SolEnabled == true :
		SolWorldBorder.show()
	else: 
		SolWorldBorder.hide()
	if SagEnabled == true :
		SagWorldBorder.show()
	else:
		SagWorldBorder.hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		AnimationManager.transition_to_scene(GameManager.select_random_room())
