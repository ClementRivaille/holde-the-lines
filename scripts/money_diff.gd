extends Label
class_name MoneyDiff

signal done

@onready var animation: AnimationPlayer = $AnimationPlayer

@export var color_plus: Color = Color.GREEN
@export var color_minus: Color = Color.RED

func _ready() -> void:
	animation.play("fade_out")

func on_animation_finished():
	done.emit()

func set_value(value: int):
	var positive := value >= 0
	text = "{0}{1}$".format(["+" if positive else "", value])
	label_settings.font_color = color_plus if positive else color_minus
