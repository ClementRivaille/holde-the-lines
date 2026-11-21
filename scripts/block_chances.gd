extends Resource
class_name BlockChanches

@export var weak: int = 1
@export var standard: int = 1
@export var strong: int = 1
@export var gold: int = 1
@export var shield: int = 1

var probabilities: Array[float] = []
var total: int = 0
var block_types_index: Array[BlockProperties.BlockType] = [
	BlockProperties.BlockType.WEAK,
	BlockProperties.BlockType.STANDARD,
	BlockProperties.BlockType.STRONG,
	BlockProperties.BlockType.GOLD,
	BlockProperties.BlockType.SHIELD,
]

func build_probabilities():
	total = weak + standard + strong + gold + shield
	var chances: Array[int] = [weak, standard, strong, gold, shield]

	# order types
	for i: int in range(1, chances.size()):
		var j := i
		while j > 0 && chances[j] < chances[j-1]:
			var value := chances[j]
			var type := block_types_index[j]
			chances[j] = chances[j-1];
			block_types_index[j] = block_types_index[j-1]
			chances[j-1] = value
			block_types_index[j-1] = type
			j -= 1


	var sum: float = 0.0
	probabilities.clear()
	for score in chances:
		sum += float(score)
		probabilities.append(sum)

func pick_type() -> BlockProperties.BlockType:
	if probabilities.size() == 0:
		build_probabilities()

	var dice_value := randf() * total
	for idx in probabilities.size():
		if dice_value <= probabilities[idx]:
			return block_types_index[idx]

	return block_types_index[0]
