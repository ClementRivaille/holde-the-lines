extends Control
class_name  ShieldLevel

@onready var health_bar: Control = $Border/HealthBar
@onready var icon: TextureRect = $Icon

@export var damage_modulate: Color = Color.RED
@export var heal_modulate: Color = Color.GREEN
@export_range(0.0, 1.0, 0.05) var hit_duration: float = 1.0
@export_range(0.0, 0.5, 0.05) var bar_update_time := 0.2

var _tween_bar: Tween = null
var _tween_icon: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStoreInstance.city_damaged.connect(on_city_damaged)
	GameStoreInstance.city_heal.connect(on_city_healed)

func on_city_damaged(hp: int):
	_update_bar(hp)
	_animate_icon(damage_modulate)

func on_city_healed(hp: int):
	_update_bar(hp)
	_animate_icon(heal_modulate)

func _update_bar(hp: int):
	var percent: float = float(hp) / float(GameStore.CITY_HP_TOTAL)
	if _tween_bar != null && _tween_bar.is_running():
		_tween_bar.stop()
	_tween_bar = create_tween()
	_tween_bar.tween_property(health_bar, "anchor_top", 1.0 - percent, bar_update_time)

func _animate_icon(color: Color):
	if _tween_icon != null && _tween_icon.is_running():
		_tween_icon.stop()
	_tween_icon = create_tween()
	icon.modulate = color
	_tween_icon.tween_property(icon, "modulate", Color.WHITE, hit_duration)
