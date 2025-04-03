extends Control

var item_data: Dictionary = {}

@onready var icon = $ItemIcon
@onready var count_label = $ItemCount

func set_item(item: Dictionary):
	item_data = item
	if item:
		var path := "res://sprites/%s.png" % item.name
		print("Trying to load texture from path: ", path)
		if ResourceLoader.exists(path):
			print("✓ Texture exists!")
			icon.texture = load(path)
		else:
			print("✗ Texture path not found!")
			icon.texture = null
	else:
		item_data = {}
		icon.texture = null
		count_label.text = ""
		icon.visible = false
		count_label.visible = false

func get_item() -> Dictionary:
	return item_data
