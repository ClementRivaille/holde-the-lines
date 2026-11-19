extends Area2D
class_name BlockPiece

const BLOCK_SIZE: float = 48
const LINE_VALIDATION_DURATION: float = .7

@export var unplaceable_opacity: float = 0.5
@export var plaecable_opacity: float = 1.0

@export var standardTexture: Texture2D
@export var weakTexture: Texture2D
@export var strongTexture: Texture2D
@export var goldTexture: Texture2D

var _type: BlockProperties.BlockType = BlockProperties.BlockType.STANDARD
var block_id: int = -1

@onready var sprite: Sprite2D = $Sprite2D
@onready var valid_sprite: Sprite2D = $ValidSprite

func set_placeable(placeable: bool):
	modulate = Color(Color.WHITE, plaecable_opacity if placeable else unplaceable_opacity)

func set_type(value: BlockProperties.BlockType):
	_type = value
	sprite.texture = {
		BlockProperties.BlockType.STANDARD: standardTexture,
		BlockProperties.BlockType.WEAK: weakTexture,
		BlockProperties.BlockType.STRONG: strongTexture,
		BlockProperties.BlockType.GOLD: goldTexture,
	}[_type]

func validate_line():
	create_tween().tween_property(valid_sprite, "modulate", Color(Color.WHITE, 1), LINE_VALIDATION_DURATION
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
