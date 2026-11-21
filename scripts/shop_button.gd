extends Button
class_name  ShopButton

const ALL_SHAPES: Array[Tetromino.SHAPE_TYPE] = [
	Tetromino.SHAPE_TYPE.T,
	Tetromino.SHAPE_TYPE.SQUARE,
	Tetromino.SHAPE_TYPE.L,
	Tetromino.SHAPE_TYPE.J,
	Tetromino.SHAPE_TYPE.S,
	Tetromino.SHAPE_TYPE.Z,
	Tetromino.SHAPE_TYPE.I ]
const ALL_TYPES: Array[BlockProperties.BlockType] = [
	BlockProperties.BlockType.WEAK,
	BlockProperties.BlockType.STANDARD,
	BlockProperties.BlockType.STRONG,
	BlockProperties.BlockType.GOLD
]

@export var price: int = 4
@export var alpha_disabled := 0.5

var _tetromino: Tetromino

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_tetromino = Tetromino.new()
	add_child(_tetromino)
	_tetromino.position = Vector2(size.x / 2, size.y / 2)

	_tetromino.shape_type = get_random_shape()
	_tetromino.block_types = get_random_blocks()
	_tetromino.build()

	pressed.connect(on_click)
	GameStoreInstance.on_drop.connect(on_drop)
	GameStoreInstance.money_updated.connect(on_money_updated)

	init_enabled()

func init_enabled():
	disabled = GameStoreInstance.money < price
	modulate = Color(Color.WHITE, alpha_disabled) if disabled else Color.WHITE

func get_random_shape() -> Tetromino.SHAPE_TYPE:
	return ALL_SHAPES[randi()%ALL_SHAPES.size()]

func get_random_blocks() -> Array[BlockProperties.BlockType]:
	var block_types: Array[BlockProperties.BlockType] = []
	for i in 4:
		block_types.append(ALL_TYPES[randi()%ALL_TYPES.size()])
	return block_types

func on_click():
	_tetromino.grab()

func on_drop(placed: bool):
	if !_tetromino.is_grabbed(): return

	# Put tetromino back in button
	_tetromino.position = Vector2(size.x / 2, size.y / 2)
	_tetromino.drop()
	if placed:
		GameStoreInstance.spend_money(price)
		# generate new shape
		_tetromino.shape_type = get_random_shape()
		_tetromino.block_types = get_random_blocks()
		_tetromino.reset()

func on_money_updated(money: int, _diff: int):
	if money < price && !disabled:
		disabled = true
		modulate = Color(Color.WHITE, alpha_disabled)
	elif money >= price && disabled:
		disabled = false
		modulate = Color.WHITE
