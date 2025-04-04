class_name InventorySlot
extends Panel

var item_data: Dictionary = {}

@onready var icon = $ItemIcon
@onready var count_label = $ItemCount

func set_item(item: Dictionary):
	item_data = item
	if item:
		var path := "res://sprites/%s.png" % item.name
		if ResourceLoader.exists(path):
			icon.texture = load(path)
		else:
			icon.texture = null
		count_label.text = str(item.count)
		icon.visible = true
		count_label.visible = item.count > 1
	else:
		item_data = {}
		icon.texture = null
		count_label.text = ""
		icon.visible = false
		count_label.visible = false

func get_item() -> Dictionary:
	return item_data
