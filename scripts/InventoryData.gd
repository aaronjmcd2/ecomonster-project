extends Node

class_name InventoryData

# Constants
const INVENTORY_ROWS := 7
const INVENTORY_COLUMNS := 8
const HOTBAR_SIZE := 8

# Inventory item structure
# Example: { "name": "coal", "count": 32 }
var inventory: Array = []
var hotbar_selected_index := 0

func _ready():
	_initialize_inventory()

func _initialize_inventory():
	# Fill inventory with empty slots (null means empty)
	for row in INVENTORY_ROWS:
		var row_array := []
		for col in INVENTORY_COLUMNS:
			row_array.append(null)
		inventory.append(row_array)

func get_item(row: int, col: int) -> Dictionary:
	return inventory[row][col]

func set_item(row: int, col: int, item: Dictionary):
	inventory[row][col] = item

func move_item(from_row: int, from_col: int, to_row: int, to_col: int):
	var from_item = inventory[from_row][from_col]
	var to_item = inventory[to_row][to_col]

	if to_item == null:
		inventory[to_row][to_col] = from_item
		inventory[from_row][from_col] = null
	elif from_item.name == to_item.name:
		to_item.count += from_item.count
		inventory[from_row][from_col] = null

func drop_item_from_inventory(item: Dictionary, slot_ref: Node) -> void:
	var player = get_tree().get_root().get_node("Main/Player")
	if not player:
		print("❌ Player not found")
		return

	var drop_pos = player.global_position + Vector2(16, 0)  # Drop slightly to the right

	# Only handle IronOre for now
	if item.get("name") == "IronOre":
		var drop_scene = preload("res://scenes/IronOreDrop.tscn")
		var drop_instance = drop_scene.instantiate()
		drop_instance.position = drop_pos
		get_tree().get_root().add_child(drop_instance)

		# Update item count in slot
		item["count"] -= 1
		if item["count"] <= 0:
			slot_ref.clear_slot()
		else:
			slot_ref.set_item(item)
