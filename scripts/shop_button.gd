extends Button
class_name  ShopButton

@export var price: int = 4
@export var level: int = 0
@export var alpha_disabled := 0.5

var _tetromino: Tetromino

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_tetromino = Tetromino.new()
	add_child(_tetromino)
	_tetromino.position = Vector2(size.x / 2, size.y / 2)

	pressed.connect(on_click)
	GameStoreInstance.on_drop.connect(on_drop)
	GameStoreInstance.money_updated.connect(on_money_updated)
	GameStoreInstance.game_over.connect(on_game_over)

func init(with_price: int, with_level: int):
	price = with_price
	level = with_level

	disabled = GameStoreInstance.money < price
	modulate = Color(Color.WHITE, alpha_disabled) if disabled else Color.WHITE

	_tetromino.shape_type = get_random_shape()
	_tetromino.block_types = get_random_blocks()
	_tetromino.build()

func get_random_shape() -> Tetromino.SHAPE_TYPE:
	return Tetromino.ALL_SHAPES[randi()%Tetromino.ALL_SHAPES.size()]

func get_random_blocks() -> Array[BlockProperties.BlockType]:
	var block_types: Array[BlockProperties.BlockType] = []
	for i in 4:
		block_types.append(GameStoreInstance.block_pool_instance.pick_block_type(level))
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

func on_game_over():
	disabled = true
	modulate = Color(Color.WHITE, alpha_disabled)
