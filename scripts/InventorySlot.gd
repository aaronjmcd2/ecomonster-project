# InventorySlot.gd
# Manages visual representation and drag-and-drop interaction for a single inventory slot.
# Handles stacking, swapping, partial dragging, and right-click item dropping.
# Used in both inventory grid and hotbar slots.

class_name InventorySlot
extends Control

# === Data ===
var item_data: Dictionary = {}

@onready var icon = $ItemIcon
@onready var count_label = $ItemCount

func _ready() -> void:
	# No setup needed unless populating test data manually
	pass

# === Set the item in this slot and update visuals ===
func set_item(item: Dictionary) -> void:
	item_data = item

	if item:
		if item.has("icon") and item["icon"] is Texture2D:
			icon.texture = item["icon"]
		else:
			# Fallback to loading from name if no icon provided
			var path := "res://sprites/%s.png" % item.name
			if ResourceLoader.exists(path):
				icon.texture = load(path)
			else:
				icon.texture = null

		count_label.text = str(item.count)
		icon.visible = true
		count_label.visible = item.count > 1
	else:
		clear_slot()

# === Return the item in this slot ===
func get_item() -> Dictionary:
	return item_data

# === Called when the player begins dragging an item from this slot ===
func _get_drag_data(at_position: Vector2) -> Variant:
	if item_data.is_empty():
		print("🔸 _get_drag_data: No item.")
		return null

	print("🟢 _get_drag_data called on:", item_data)

	var drag_count = item_data.count
	var drag_name = item_data.name
	var drag_texture = icon.texture
	var ctrl_pressed = Input.is_key_pressed(KEY_CTRL)

	var item_to_drag: Dictionary

	# Handle stack splitting if Ctrl is held
	if ctrl_pressed and drag_count > 1:
		item_to_drag = item_data.duplicate(true)
		item_to_drag["count"] = 1
		item_data["count"] -= 1
		set_item(item_data)
	else:
		item_to_drag = item_data.duplicate(true)
		clear_slot()

	# Prepare drag preview UI
	var preview_wrapper := Control.new()
	preview_wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var preview := TextureRect.new()
	preview.texture = drag_texture
	preview.custom_minimum_size = Vector2(32, 32)
	preview.position = -preview.custom_minimum_size / 2 + Vector2(-8, -8)
	preview_wrapper.add_child(preview)

	set_drag_preview(preview_wrapper)

	return {
		"item": item_to_drag,
		"source": self
	}


# === Determine if we can accept the incoming dropped item ===
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data.has("item") and data.has("source")

# === Handle item being dropped into this slot ===
func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("🟣 Dropping data:", data)

	var incoming = data["item"]
	var source = data["source"]
	var existing = get_item()

	if not existing.is_empty() and existing.name == incoming.name:
		existing.count += incoming.count
		set_item(existing)
	elif existing.is_empty():
		set_item(incoming)
	else:
		# Swap items
		var temp = get_item()
		set_item(incoming)
		source.set_item(temp)

# === Right-click behavior: drop 1 or entire stack ===
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var item = get_item()
		if item and not item.is_empty():
			var drop_entire_stack := Input.is_key_pressed(KEY_CTRL)
			InventoryDataScript.drop_item_from_inventory(item, self, drop_entire_stack)

# === Updates only the count label of the current item ===
func update_count(new_count: int) -> void:
	item_data["count"] = new_count
	count_label.text = str(new_count)

# === Clears the slot visually and internally ===
func clear_slot() -> void:
	item_data = {}
	icon.texture = null
	count_label.text = ""
	icon.visible = false
	count_label.visible = false
