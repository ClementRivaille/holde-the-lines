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

var SHAPE_WIDTH: int = 3

enum SHAPE_TYPE {	T, SQUARE, L, J, S, Z }

var SHAPE_BY_TYPE: Dictionary[SHAPE_TYPE, Array] = {
	SHAPE_TYPE.T: T_SHAPE,
	SHAPE_TYPE.SQUARE: SQUARE_SHAPE,
	SHAPE_TYPE.L: L_SHAPE,
	SHAPE_TYPE.J: J_SHAPE,
	SHAPE_TYPE.S: S_SHAPE,
	SHAPE_TYPE.Z: Z_SHAPE,
}

@export var shape_type: SHAPE_TYPE = SHAPE_TYPE.T
@export var piece_prefab: PackedScene = preload("res://prefabs/block_piece.tscn")

var _shape: Array[Array]
var _nbBlocks: int = 0


func _ready() -> void:
	_shape = SHAPE_BY_TYPE[shape_type].map(func (row: Array[int]): return row.duplicate())
	_nbBlocks = _shape.reduce(func (row: Array[int]) -> int: return row.count(1), 0)
	for i in randi_range(0, 3):
		_shape = _rotate_shape(_shape)

	for i in _nbBlocks:
		var block = piece_prefab.instantiate()
		add_child(block)


	_build_shape()

func _build_shape() -> void:
	var child_idx: int = 0
	var center := floori(float(SHAPE_WIDTH) / 2.0)

	for row_idx in SHAPE_WIDTH:
		for col_idx: int in SHAPE_WIDTH:
			var has_block: bool = _shape[row_idx][col_idx] == 1
			if has_block:
				var block: Node2D = get_child(child_idx)
				block.position.x = (col_idx - center) * BlockPiece.BLOCK_SIZE
				block.position.y = (row_idx - center) * BlockPiece.BLOCK_SIZE

				child_idx += 1
				if child_idx >= _nbBlocks: return


func _rotate_shape(shape: Array[Array]) -> Array[Array]:
	var rotated_shape: Array[Array] = [[], [], []]

	for y in SHAPE_WIDTH:
		var row: Array = shape[y]
		for x in SHAPE_WIDTH:
			var value:int = row[x]
			rotated_shape[x][SHAPE_WIDTH - 1 - y] = value

	return rotated_shape
