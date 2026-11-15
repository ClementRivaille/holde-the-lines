extends Sprite2D
class_name PreviewBlock

@export var blink_speed := 1.0
@export var max_alpha := 0.6
@export var min_alpha := 0.4

var _tween: Tween

func _ready() -> void:
	modulate = Color(Color.WHITE, max_alpha)
	_tween = create_tween().set_loops(
		).set_trans(Tween.TRANS_SINE
		).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "modulate", Color(Color.WHITE, min_alpha), blink_speed)
	_tween.chain().tween_property(self, "modulate", Color(Color.WHITE, max_alpha), blink_speed)

func _exit_tree() -> void:
	_tween.stop()
