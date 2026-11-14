extends Area2D
class_name BlockPiece

signal on_grabbed
signal on_released

const BLOCK_SIZE: float = 20

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			on_grabbed.emit()
		elif event.is_released():
			on_released.emit()
