extends Control
class_name EndScreen

@onready var description: Label = $Content/Description
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	GameStoreInstance.game_over.connect(on_game_over)

func on_game_over():
	description.text = "Wave %s had the better of you"%(GameStoreInstance.wave_number + 1)
	mouse_filter = Control.MOUSE_FILTER_STOP

	visible = true
	animation_player.play("pop-in")

func restart():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	animation_player.play("pop-out")
	await animation_player.animation_finished
	GameStoreInstance.restart_game()
	visible = false
