extends NinePatchRect
class_name MoneyScreen

@onready var amount: Label = $Amount
@onready var update_timer: Timer = $UpdateTimer
@onready var diff_anchor: Control = $DiffAnchor

@export var nb_digits := 4
@export var money_diff_prefab: PackedScene = preload("res://prefabs/money_diff.tscn")

var displayed_value: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_value()
	update_timer.timeout.connect(on_update_display)
	GameStoreInstance.money_updated.connect(on_money_updated)

func init_value():
	displayed_value = GameStoreInstance.money
	amount.text = write_value(displayed_value)

func write_value(value: int) -> String:
	var text := ""
	for n in nb_digits:
		var modulo := value % 10**(nb_digits - n)
		var digit := modulo / 10**(nb_digits - n - 1)
		text += "%s"%digit

	return text

func on_money_updated(_money: int, diff: int):
	var money_diff: MoneyDiff = money_diff_prefab.instantiate()
	money_diff.set_value(diff)

	if diff_anchor.get_children().size() > 0:
		await get_tree().create_timer(0.2).timeout
	diff_anchor.add_child(money_diff)

	on_update_display()

	await money_diff.done
	money_diff.queue_free()

func on_update_display():
	if displayed_value == GameStoreInstance.money: return

	displayed_value += 1 if displayed_value < GameStoreInstance.money else -1
	amount.text = write_value(displayed_value)

	if displayed_value != GameStoreInstance.money:
		update_timer.start()
