extends Resource
class_name AnimationProperties

enum AnimationKind { GOLD_BLOCK, CITY_INCOME, LINE }

var kind: AnimationKind
var block_id: int
var row_idx: int

func _init(
p_kind: AnimationKind = AnimationKind.GOLD_BLOCK,
p_block_id: int = -1,
p_row_idx: int = -1) -> void:
	kind = p_kind
	block_id = p_block_id
	row_idx =p_row_idx
