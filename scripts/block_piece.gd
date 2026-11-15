extends Area2D
class_name BlockPiece

const BLOCK_SIZE: float = 20

@export var unplaceable_opacity: float = 0.5
@export var plaecable_opacity: float = 1.0

@export var standardTexture: Texture2D
@export var weakTexture: Texture2D
@export var strongTexture: Texture2D
@export var goldTexture: Texture2D

var _type: BlockProperties.BlockType = BlockProperties.BlockType.STANDARD
var block_id: int = -1

@onready var sprite: Sprite2D = $Sprite2D

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
