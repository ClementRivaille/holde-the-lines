extends Camera2D
class_name MainCamera

@export var oscillation: float = 0.5
@export var oscillation_speed: float = 0.2

var _tween: Tween = null
var _init_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_position = Vector2(position)
	GameStoreInstance.wave_started.connect(on_wave_start)
	GameStoreInstance.wave_stopped.connect(on_wave_stop)
	GameStoreInstance.game_over.connect(on_wave_stop)

func on_wave_start(_number: int):
	_tween = create_tween().set_loops(
		).set_trans(Tween.TRANS_LINEAR)
		#).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "position", Vector2(_init_position.x, _init_position.y + oscillation), oscillation_speed)
	_tween.chain().tween_property(self, "position", Vector2(_init_position.x, _init_position.y - oscillation), oscillation_speed)

func on_wave_stop():
	if _tween != null:
		_tween.stop()
	create_tween().tween_property(self, "position", _init_position, oscillation_speed
	).set_trans(Tween.TRANS_SINE
	).set_ease(Tween.EASE_IN_OUT)
