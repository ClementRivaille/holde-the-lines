extends Area2D
class_name DropZone

@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var tilemap: TileMapLayer = $TileMap
@onready var preview_area: Node2D = $Preview
@onready var blocks_area: Node2D = $Blocks
@onready var particles: Node2D = $Particles

@export var preview_block_prefab: PackedScene = preload("res://prefabs/preview_block.tscn")
@export var block_prefab: PackedScene = preload("res://prefabs/block_piece.tscn")

var _is_cursor_inside := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(BlockPiece.BLOCK_SIZE * GameStore.GRID_WIDTH, BlockPiece.BLOCK_SIZE * GameStore.GRID_HEIGHT)

	collisionShape.shape = rectangle

	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)

	tilemap.position = Vector2(-float(GameStore.GRID_WIDTH) / 2 * BlockPiece.BLOCK_SIZE, -float(GameStore.GRID_HEIGHT) / 2 * BlockPiece.BLOCK_SIZE)

	GameStoreInstance.on_tetromino_placeable.connect(on_block_placeable)
	GameStoreInstance.blocks_added.connect(on_add_blocks)
	GameStoreInstance.lines_validated.connect(on_lines_validated)
	GameStoreInstance.remove_blocks.connect(on_blocks_removed)
	GameStoreInstance.move_block.connect(on_block_moved)
	GameStoreInstance.damage_block.connect(on_block_damaged)
	GameStoreInstance.destroy_block.connect(on_block_destroyed)
	AnimCoordinator.should_play_anim.connect(on_animation)

func on_mouse_enter():
	_is_cursor_inside = true

func on_mouse_exit():
	_is_cursor_inside = false
	GameStoreInstance.update_cursor_position(Vector2i(-1, -1))

func _process(_delta: float) -> void:
	if GameStoreInstance.is_dragging and _is_cursor_inside:
		var local_pos := get_global_mouse_position() - tilemap.global_position
		GameStoreInstance.update_cursor_position(get_coordinates(local_pos))

func get_coordinates(local_pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(local_pos)

func on_block_placeable(placeable: bool, positions: Array[Vector2i]):
		preview_area.get_children().map(func (block: Node): block.queue_free())
		if placeable:
			for block_position in positions:
				var global_pos := tilemap.map_to_local(block_position) + tilemap.global_position
				var preview: PreviewBlock = preview_block_prefab.instantiate()
				preview_area.add_child(preview)
				preview.global_position = global_pos

func on_add_blocks(positions: Array[Vector2i]):
	for block_pos in positions:
		var global_pos := tilemap.map_to_local(block_pos) + tilemap.global_position
		var block: BlockPiece = block_prefab.instantiate()
		var props := GameStoreInstance.get_block_at(block_pos)
		blocks_area.add_child(block)
		block.block_id = props.id
		block.set_type(props.type)
		block.collideable = true
		block.global_position = global_pos

func on_lines_validated(_rows: Array[int], blocks: Array[int]):
	for block_id in blocks:
		var block := _get_block_instance(block_id)
		block.validate_line()

func on_blocks_removed(blocks: Array[int]):
	for block_id in blocks:
		var block := _get_block_instance(block_id)
		block.queue_free()

func on_block_damaged(block_props: BlockProperties):
	var block := _get_block_instance(block_props.id)
	block.damage(block_props.hp, block_props.total_hp)

func on_block_destroyed(id: int):
	var block := _get_block_instance(id)
	var explosion := block.explode()
	explosion.reparent(particles, true)
	block.queue_free()

	await explosion.finished
	explosion.queue_free()

func on_block_moved(block_id: int, to_position: Vector2i):
	var block := _get_block_instance(block_id)
	var global_pos := tilemap.map_to_local(to_position) + tilemap.global_position
	block.global_position = global_pos

func _get_block_instance(block_id: int) -> BlockPiece:
	var block_idx: int = blocks_area.get_children().find_custom(func (b: BlockPiece): return b.block_id == block_id)
	assert(block_idx != -1, "ERROR: block %s not found in instanciated blocks"%block_id)
	return blocks_area.get_child(block_idx)

func on_animation(anim: AnimationProperties):
	if anim.kind == AnimationProperties.AnimationKind.GOLD_BLOCK || anim.kind == AnimationProperties.AnimationKind.SHIELD_BLOCK:
		if !GameStoreInstance.block_pool_instance.block_exists(anim.block_id): return
		var block := _get_block_instance(anim.block_id)
		block.activate()
		if anim.kind == AnimationProperties.AnimationKind.GOLD_BLOCK:
			AnimCoordinator.play_gold_animation(block.global_position)
		else:
			AnimCoordinator.play_shield_animation(block.global_position)
	elif anim.kind == AnimationProperties.AnimationKind.LINE:
		var global_pos := tilemap.map_to_local(Vector2i(GameStore.GRID_WIDTH / 2, anim.row_idx)) + tilemap.global_position
		AnimCoordinator.play_gold_animation(global_pos, true)
