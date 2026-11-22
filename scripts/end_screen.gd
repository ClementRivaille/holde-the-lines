extends Control
class_name EndScreen


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	GameStoreInstance.game_over.connect(on_game_over)

func on_game_over():
	pass
