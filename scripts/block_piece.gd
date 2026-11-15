extends Area2D
class_name BlockPiece

signal on_grabbed

const BLOCK_SIZE: float = 20

@export var unplaceable_opacity: float = 0.5

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			on_grabbed.emit()

func set_placeable(placeable: bool):
	modulate = Color(Color.WHITE, 1.0 if placeable else unplaceable_opacity)
