extends Control
class_name  ShieldLevel

@onready var health_bar: Control = $Border/HealthBar
@onready var icon: TextureRect = $Icon

@export var damage_modulate: Color = Color.RED
@export_range(0.0, 1.0, 0.05) var hit_duration: float = 1.0
@export_range(0.0, 0.5, 0.05) var bar_update_time := 0.2

var _tween_bar: Tween = null
var _tween_icon: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStoreInstance.city_damaged.connect(on_city_damaged)

func on_city_damaged(hp: int):
	var percent: float = float(hp) / float(GameStore.CITY_HP_TOTAL)
	if _tween_bar != null && _tween_bar.is_running():
		_tween_bar.stop()
	_tween_bar = create_tween()
	_tween_bar.tween_property(health_bar, "anchor_top", 1.0 - percent, bar_update_time)

	if _tween_icon != null && _tween_icon.is_running():
		_tween_icon.stop()
	_tween_icon = create_tween()
	icon.modulate = damage_modulate
	_tween_icon.tween_property(icon, "modulate", Color.WHITE, hit_duration)
