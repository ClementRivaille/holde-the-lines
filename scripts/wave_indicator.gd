extends Control
class_name WaveIndicator

@onready var wave_time: Control = $WaveTime
@onready var incoming_wave_label: Label = $WaveTime/Label
@onready var time_bar: Control = $WaveTime/Bar
@onready var current_wave_label: Label = $CurrentWave

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStoreInstance.wave_started.connect(on_start_wave)
	GameStoreInstance.wave_ended.connect(on_stop_wave)
	GameStoreInstance.time_to_wave_updated.connect(on_update_wave_time)
	GameStoreInstance.game_started.connect(on_game_start)
	GameStoreInstance.game_over.connect(on_game_over)

	visible = false

func on_game_start():
	visible = true
	current_wave_label.visible = false
	wave_time.visible = true
	incoming_wave_label.text = get_incoming_wave_text(0)

func get_incoming_wave_text(number: int) -> String:
	return "Time before wave %s"%(number + 1)

func on_start_wave(number: int):
	wave_time.visible = false
	current_wave_label.visible = true
	current_wave_label.text = "WAVE %s"%(number + 1)

func on_stop_wave():
	current_wave_label.visible = false
	wave_time.visible = true
	incoming_wave_label.text = get_incoming_wave_text(GameStoreInstance.wave_number)
	time_bar.anchor_left = 0
	time_bar.anchor_right = 1

func on_update_wave_time(remaining: float):
	time_bar.anchor_left = lerpf(0.5, 0, remaining)
	time_bar.anchor_right = lerpf(0.5, 1, remaining)

func on_game_over():
	visible = false
