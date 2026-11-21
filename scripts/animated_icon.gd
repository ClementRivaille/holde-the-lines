extends Node2D
class_name AnimatedIcon

signal animation_finished

@onready var player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	player.play("icon_up")
	player.animation_finished.connect(on_animation_finished)

func on_animation_finished(_name: StringName):
	animation_finished.emit()
