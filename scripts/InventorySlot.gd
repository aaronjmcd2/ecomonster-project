class_name InventorySlot
extends Control

var item_data: Dictionary = {}

@onready var icon = $ItemIcon
@onready var count_label = $ItemCount

func _ready():
	# Nothing needed here unless you want to add test items manually
	pass

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

func _get_drag_data(at_position: Vector2) -> Variant:
	if item_data.is_empty():
		print("🔸 _get_drag_data: No item.")
		return null

	print("🟢 _get_drag_data called on:", item_data)

	# Create a wrapper Control node
	var preview_wrapper := Control.new()
	preview_wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Create the actual icon preview
	var preview := TextureRect.new()
	preview.texture = icon.texture
	preview.custom_minimum_size = Vector2(32, 32)
	preview.position = -preview.custom_minimum_size / 2 + Vector2(-8, -8)

	preview_wrapper.add_child(preview)

	set_drag_preview(preview_wrapper)

	return {
		"item": item_data,
		"source": self
	}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data.has("item") and data.has("source")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("🟣 Dropping data:", data)
	var incoming = data["item"]
	var source = data["source"]

	var temp = item_data
	set_item(incoming)
	source.set_item(temp)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var item = get_item()
			if item and not item.is_empty():
				var drop_entire_stack := Input.is_key_pressed(KEY_CTRL)
				InventoryDataScript.drop_item_from_inventory(item, self, drop_entire_stack)

func update_count(new_count: int) -> void:
	item_data["count"] = new_count
	$ItemCount.text = str(new_count)

func clear_slot() -> void:
	item_data = {}
	icon.texture = null
	count_label.text = ""
	icon.visible = false
	count_label.visible = false
