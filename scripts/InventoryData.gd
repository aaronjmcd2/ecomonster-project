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
