extends Node2D
class_name AnimatedIcon

signal animation_finished

@onready var player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Icon

@export var gold_icon: Texture2D
@export var shield_icon: Texture2D

func _ready() -> void:
	player.play("icon_up")
	player.animation_finished.connect(on_animation_finished)

func on_animation_finished(_name: StringName):
	animation_finished.emit()

func set_icon(type: AnimationProperties.AnimationKind):
	if type == AnimationProperties.AnimationKind.SHIELD_BLOCK:
		sprite.texture = shield_icon
	elif type == AnimationProperties.AnimationKind.GOLD_BLOCK:
		sprite.texture = gold_icon
