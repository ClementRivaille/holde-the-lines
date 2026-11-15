extends Control
class_name Debug

@onready var cursor_position: Label = $CursorPosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStoreInstance.cursor_pos_changed.connect(on_cursor_pos)

func on_cursor_pos(pos: Vector2i):
	cursor_position.text = "X: {0} Y: {1}".format([pos.x, pos.y])
