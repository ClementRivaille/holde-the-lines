extends Label
class_name ControlsInstruction

var drop_count := 0
@export var hide_after_drops := 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	GameStoreInstance.game_started.connect(on_start)
	GameStoreInstance.blocks_added.connect(on_drop_block)


func on_start():
	visible = true

func on_drop_block(_positions):
	if drop_count >= hide_after_drops: return

	drop_count += 1
	if drop_count >= hide_after_drops:
		visible = false
