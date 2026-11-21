extends Node2D
class_name BlockPool

var instanced_blocks: Array[BlockProperties] = []

@export var default_properties: Array[BlockProperties] = []
@export var shop_levels: Array[BlockChanches] = []

func _ready() -> void:
	GameStoreInstance.register_block_pool(self)
	GameStoreInstance.remove_blocks.connect(on_blocks_removed)
	GameStoreInstance.destroy_block.connect(delete_block)

func block_exists(id: int):
	var index := instanced_blocks.find_custom(func (b: BlockProperties): return b.id == id)
	return index >= 0

func get_block_by_id(id: int) -> BlockProperties:
	var index := instanced_blocks.find_custom(func (b: BlockProperties): return b.id == id)
	assert(index >= 0, "ERROR: block {0} not found in pool".format([id]))

	return instanced_blocks[index]

func generate_block(type: BlockProperties.BlockType) -> BlockProperties:
	var props_idx := default_properties.find_custom(func (p: BlockProperties): return p.type == type)
	var block := BlockProperties.new() if props_idx == -1 else default_properties[props_idx].copy()
	block.type = type
	instanced_blocks.append(block)

	return block

func delete_block(id: int):
	var index := instanced_blocks.find_custom(func (b: BlockProperties): return b.id == id)
	if index == -1: return

	instanced_blocks.remove_at(index)

func on_blocks_removed(blocks: Array[int]):
	blocks.map(func(id: int): delete_block(id))

func pick_block_type(level: int) -> BlockProperties.BlockType:
	if level >= shop_levels.size():
		return BlockProperties.BlockType.WEAK

	var chances := shop_levels[level]
	return chances.pick_type()
