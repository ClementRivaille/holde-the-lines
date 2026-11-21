extends StaticBody2D
class_name CityDome

@onready var sprite: Sprite2D = $Sprite
@onready var cracks: Sprite2D = $Sprite/Cracks

@export var damage_modulate: Color = Color.RED
@export_range(0.0, 1.0, 0.05) var hit_duration: float = 1.0
@export var cracks_textures: Array[Texture2D]
@export var coins_offset := 100.0

var _tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cracks.visible = false
	GameStoreInstance.city_damaged.connect(on_city_damaged)
	GameStoreInstance.city_heal.connect(on_city_heal)
	AnimCoordinator.should_play_anim.connect(on_animation)

func on_city_damaged(hp: int):
	if _tween != null && _tween.is_running():
		_tween.stop()

	modulate = damage_modulate
	_tween = create_tween()
	_tween.tween_property(self, "modulate", Color.WHITE, hit_duration
		).set_ease(Tween.EASE_IN
		).set_trans(Tween.TRANS_QUAD)

	update_cracks(hp)

func on_city_heal(hp: int):
	update_cracks(hp)

func update_cracks(hp: int):
	var crack_index = floori((1.0 - (float(hp) / float(GameStore.CITY_HP_TOTAL))) * float(cracks_textures.size() + 1)) - 1
	if crack_index >= 0:
		cracks.visible = true
		cracks.texture = cracks_textures[min(crack_index, cracks_textures.size() - 1)]

func on_animation(anim: AnimationProperties):
	if anim.kind == AnimationProperties.AnimationKind.CITY_INCOME:
		AnimCoordinator.play_gold_animation(Vector2(global_position.x, global_position.y - coins_offset), true)
