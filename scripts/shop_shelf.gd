extends Control
class_name  ShopShelf

@onready var price_tag: Label = $PriceTag/Label
@onready var button_1: ShopButton = $HBoxContainer/ShopButton
@onready var button_2: ShopButton = $HBoxContainer/ShopButton2

@export var price: int = 1
@export var level: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	price_tag.text = "%s$"%price
	button_1.init(price, level)
	button_2.init(price, level)
