extends Resource
class_name BlockProperties

enum BlockType { WEAK, STANDARD, STRONG, GOLD }

const ALL_TYPES: Array[BlockProperties.BlockType] = [
	BlockType.WEAK,
	BlockType.STANDARD,
	BlockType.STRONG,
	BlockType.GOLD
]

var id: int = randi()
var hp: int = 100
var in_grid := false
@export var type: BlockType
@export var total_hp := 100

func copy() -> BlockProperties:
	var block: BlockProperties = BlockProperties.new()
	block.type = type
	block.id = randi()
	block.total_hp = total_hp
	block.hp = total_hp
	return block
