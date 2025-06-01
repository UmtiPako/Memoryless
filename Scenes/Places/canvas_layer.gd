extends CanvasLayer

@onready var label: Label = $Timer/Label

@onready var heart: Sprite2D = $Heart
@onready var heart_2: Sprite2D = $Heart2
@onready var heart_3: Sprite2D = $Heart3
@onready var heart_4: Sprite2D = $Heart4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_hearths()
	_update_timer()
	pass

func _update_timer():
	label.text = str(GlobalTimer.time_left)
	pass

func _update_hearths():
	if GameManager.player_health == 4:
		heart.modulate.a = 1.0
		heart_2.modulate.a = 1.0
		heart_3.modulate.a = 1.0
		heart_4.modulate.a = 1.0
	if GameManager.player_health == 3:
		heart.modulate.a = 1.0
		heart_2.modulate.a = 1.0
		heart_3.modulate.a = 1.0
		heart_4.modulate.a = 0.3
	if GameManager.player_health == 2:
		heart.modulate.a = 1.0
		heart_2.modulate.a = 1.0
		heart_3.modulate.a = 0.3
		heart_4.modulate.a = 0.3
	if GameManager.player_health == 1:
		heart.modulate.a = 1.0
		heart_2.modulate.a = 0.3
		heart_3.modulate.a = 0.3
		heart_4.modulate.a = 0.3
	if GameManager.player_health == 0:
		heart.modulate.a = 0.3
		heart_2.modulate.a = 0.3
		heart_3.modulate.a = 0.3
		heart_4.modulate.a = 0.3
	pass
