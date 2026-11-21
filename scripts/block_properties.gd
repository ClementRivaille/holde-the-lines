extends Resource
class_name BlockProperties

enum BlockType { WEAK, STANDARD, STRONG, GOLD }

var id: int = randi()
var type: BlockType
var hp: int = 100
var total_hp := 100
var in_grid := false
