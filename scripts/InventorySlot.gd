class_name InventorySlot
extends Panel

var item_data: Dictionary = {}
var dragging := false

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

func get_drag_data(position):
	if item_data.is_empty():
		print("🛑 Item data empty!")
		return null

	print("🟢 get_drag_data() called on:", item_data)

	var drag_preview = TextureRect.new()
	drag_preview.texture = icon.texture
	drag_preview.custom_minimum_size = Vector2(32, 32)
	set_drag_preview(drag_preview)

	return {
		"item": item_data,
		"source": self
	}

func can_drop_data(position, data):
	return data.has("item") and data.has("source")

func drop_data(position, data):
	var incoming_item = data["item"]
	var source_slot = data["source"]

	# Simple swap for now
	var temp = item_data
	set_item(incoming_item)
	source_slot.set_item(temp)
