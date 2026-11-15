extends Node2D
class_name BlockPool

var instanced_blocks: Array[BlockProperties] = []

func get_block_by_id(id: int) -> BlockProperties:
	var index := instanced_blocks.find_custom(func (b: BlockProperties): return b.id == id)
	assert(index >= 0, "ERROR: block {0} not found in pool".format([id]))

	return instanced_blocks[index]

func generate_block(type: BlockProperties.BlockType) -> BlockProperties:
	var block := BlockProperties.new()
	block.type = type

	instanced_blocks.append(block)

	return block

func _ready() -> void:
	GameStoreInstance.register_block_pool(self)
