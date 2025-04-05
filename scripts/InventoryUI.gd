extends Control

@onready var inventory_grid := $MainContainer/InventoryGrid
@export var inventory_slot_scene: PackedScene

const NUM_COLUMNS := 8
const NUM_ROWS := 7

func _ready():
	# Populate inventory grid
	for i in range(NUM_COLUMNS * NUM_ROWS):
		var slot = inventory_slot_scene.instantiate()
		inventory_grid.add_child(slot)

func add_item_to_inventory(item: Dictionary):
	var name = item.get("name", "")
	var count = item.get("count", 1)

	# Get all hotbar & inventory slots
	var hotbar = $HotbarWrapper/Hotbar
	var hotbar_slots = []
	for child in hotbar.get_children():
		if child is InventorySlot:
			hotbar_slots.append(child)

	var grid = $MainContainer/InventoryGrid
	var grid_slots = []
	for child in grid.get_children():
		if child is InventorySlot:
			grid_slots.append(child)

	# Try to stack in hotbar
	for slot in hotbar_slots:
		var existing = slot.get_item()
		if !existing.is_empty() and existing.name == name:
			existing.count += count
			slot.set_item(existing)
			print("📥 Stacked", item, "in hotbar")
			return

	# Try to place in empty hotbar slot
	for slot in hotbar_slots:
		if slot.get_item().is_empty():
			slot.set_item(item)
			print("📥 Placed", item, "in empty hotbar slot")
			return

	# Try to stack in inventory
	for slot in grid_slots:
		var existing = slot.get_item()
		if !existing.is_empty() and existing.name == name:
			existing.count += count
			slot.set_item(existing)
			print("📥 Stacked", item, "in inventory")
			return

	# Try to place in empty inventory slot
	for slot in grid_slots:
		if slot.get_item().is_empty():
			slot.set_item(item)
			print("📥 Placed", item, "in empty inventory slot")
			return

	print("❌ No room for item:", item)
