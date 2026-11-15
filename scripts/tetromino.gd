extends Node2D
class_name Tetromino

var T_SHAPE: Array[Array] = [
	[0,0,0],
	[1,1,1],
	[0,1,0]
]
var SQUARE_SHAPE: Array[Array] = [
	[0,0,0],
	[1,1,0],
	[1,1,0]
]
var L_SHAPE: Array[Array] = [
	[0,1,0],
	[0,1,0],
	[0,1,1]
]
var J_SHAPE: Array[Array] = [
	[0,1,0],
	[0,1,0],
	[1,1,0]
]
var S_SHAPE: Array[Array] = [
	[0,0,0],
	[0,1,1],
	[1,1,0]
]
var Z_SHAPE: Array[Array] = [
	[0,0,0],
	[1,1,0],
	[0,1,1]
]
var I_SHAPE: Array[Array] = [
	[0,0,0,0,0],
	[0,0,1,0,0],
	[0,0,1,0,0],
	[0,0,1,0,0],
	[0,0,1,0,0]
]

enum SHAPE_TYPE {	T, SQUARE, L, J, S, Z, I }

var SHAPE_BY_TYPE: Dictionary[SHAPE_TYPE, Array] = {
	SHAPE_TYPE.T: T_SHAPE,
	SHAPE_TYPE.SQUARE: SQUARE_SHAPE,
	SHAPE_TYPE.L: L_SHAPE,
	SHAPE_TYPE.J: J_SHAPE,
	SHAPE_TYPE.S: S_SHAPE,
	SHAPE_TYPE.Z: Z_SHAPE,
	SHAPE_TYPE.I: I_SHAPE,
}

@export var shape_type: SHAPE_TYPE = SHAPE_TYPE.T
@export var block_types: Array[BlockProperties.BlockType] = [
	BlockProperties.BlockType.STANDARD,
	BlockProperties.BlockType.STANDARD,
	BlockProperties.BlockType.STANDARD,
	BlockProperties.BlockType.STANDARD
]
@export var piece_prefab: PackedScene = preload("res://prefabs/block_piece.tscn")

var _shape: Array[Array] = []
var _nbBlocks: int = 0

var _grabbed := false


func _ready() -> void:
	GameStoreInstance.on_tetromino_placeable.connect(on_placeable)
	GameStoreInstance.on_drop.connect(on_drop)

	# Prototype only
	if GameStoreInstance.block_pool_instance == null:
		GameStoreInstance.block_pool_initiated.connect(build)
	else:
		build()


func build():
	# Init shape with rotation
	_shape.assign(SHAPE_BY_TYPE[shape_type].map(func (row: Array) -> Array: return row.duplicate()))
	_nbBlocks = _shape.reduce(func (sum: int, row: Array) -> int: return sum + row.count(1), 0)
	for i in randi_range(0, 3):
		_shape = _rotate_shape(_shape)

	# Initialize block properties and ids
	while block_types.size() < _nbBlocks:
		block_types.append(BlockProperties.BlockType.STANDARD)
	var block_props: Array[BlockProperties] = []
	block_types.map(func (type: BlockProperties.BlockType):
		block_props.append(GameStoreInstance.block_pool_instance.generate_block(type)))
	var block_idx := 0
	for row in _shape:
		for cell_idx in row.size():
			if row[cell_idx] == 1:
				row[cell_idx] = block_props[block_idx].id
				block_idx += 1
			else:
				row[cell_idx] = -1

	# Instantiate blocks
	for i in _nbBlocks:
		var block: BlockPiece = piece_prefab.instantiate()
		add_child(block)
		block.block_id = block_props[i].id
		block.set_type(block_props[i].type)
		block.on_grabbed.connect(on_grab)

	_build_shape()

func on_grab():
	_grabbed = true
	GameStoreInstance.grab_tetromino(_shape)

func _build_shape() -> void:
	var nb_moved: int = 0
	var center := floori(float(_shape.size()) / 2.0)

	for row_idx in _shape.size():
		for col_idx: int in _shape.size():
			var has_block: bool = _shape[row_idx][col_idx] >= 0
			if has_block:
				var block_id: int = _shape[row_idx][col_idx]
				var block_idx: int = get_children().find_custom(func (b: BlockPiece): return b.block_id == block_id)
				assert(block_idx != -1, "ERROR: Block % not instantiated" % block_id)
				var block: Node2D = get_child(block_idx)
				block.position.x = (col_idx - center) * BlockPiece.BLOCK_SIZE
				block.position.y = (row_idx - center) * BlockPiece.BLOCK_SIZE

				nb_moved += 1
				if nb_moved >= _nbBlocks: return


func _rotate_shape(shape: Array[Array]) -> Array[Array]:
	var rotated_shape: Array[Array] = []
	rotated_shape.assign(shape.map(func (row: Array): return row.map(func (_v): return -1)))

	for y in _shape.size():
		var row: Array = shape[y]
		for x in _shape.size():
			var value:int = row[x]
			rotated_shape[x][_shape.size() - 1 - y] = value

	return rotated_shape

func _physics_process(_delta: float) -> void:
	if _grabbed:
		global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if _grabbed && event is InputEventMouseButton:
		var mouse_event :=  event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT &&	mouse_event.is_released():
			_release()
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT && mouse_event.is_pressed():
			_rotate()

func _release():
	GameStoreInstance.release_tetromino()

func _rotate():
	_shape = _rotate_shape(_shape)
	_build_shape()
	GameStoreInstance.update_hand_tetromino(_shape)

func on_placeable(placeable: bool, _target: Array[Vector2i]):
	if !_grabbed: return

	for block: BlockPiece in get_children():
		block.set_placeable(placeable)

func on_drop(placed: bool):
	if !_grabbed: return

	_grabbed = false
	if placed:
		queue_free()
