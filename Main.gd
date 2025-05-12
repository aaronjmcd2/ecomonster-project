# Main.gd
# Initializes UI inventory and hotbar on scene load. Handles inventory toggling and debug setup.
# Loads InventorySlot instances dynamically and sets up test items.
# Used during startup; intended to be replaced or trimmed for final game flow.

extends Node

@onready var InventorySlotScene := preload("res://systems/inventory/InventorySlot.tscn")

func _ready() -> void:
	await get_tree().process_frame  # Ensure all nodes are ready before setup
	
	_init_inventory_ui()
	_setup_test_items()
	
	 # Connect to item drop events to detect silver ingots in water
	EventBus.connect("item_dropped", Callable(self, "_on_item_dropped"))

# Add item drop handler
func _on_item_dropped(item_data, world_position):
	# Check if it's a silver ingot
	if item_data.name == "SilverIngot":
		var lake_manager = get_node_or_null("LakeManager")
		if lake_manager:
			lake_manager.check_silver_ingot_drop(world_position)

# === Populates inventory and hotbar UI ===
func _init_inventory_ui() -> void:
	var ui = $UILayer/InventoryUI

	# Setup hotbar slots (8 total)
	var hotbar_path := "HotbarWrapper/Hotbar"
	if ui.has_node(hotbar_path):
		var hotbar = ui.get_node(hotbar_path)

		# Clear any pre-existing slots
		for child in hotbar.get_children():
			hotbar.remove_child(child)
			child.queue_free()

		# Create new InventorySlots
		for i in range(8):
			var slot := InventorySlotScene.instantiate()
			hotbar.add_child(slot)

		print("🧪 Created ", hotbar.get_child_count(), " hotbar slots.")
	else:
		print("🛑 Hotbar not found at path:", hotbar_path)

# === Adds temporary test items to verify layout ===
func _setup_test_items() -> void:
	var ui = $UILayer/InventoryUI
	var test_item = { "name": "IronOre", "count": 24 }

	# Populate inventory grid slots
	var grid_path := "MainContainer/InventoryGrid"
	if ui.has_node(grid_path):
		var grid = ui.get_node(grid_path)
		var grid_slots = grid.get_children().filter(func(child): return child is InventorySlot)

		print("🧪 Found ", grid_slots.size(), " inventory grid slots.")

		if grid_slots.size() >= 2:
			grid_slots[0].set_item(test_item)
			grid_slots[1].set_item({ "name": "IronOre", "count": 64 })
	else:
		print("🛑 InventoryGrid not found at path:", grid_path)

	# Add item to hotbar slot 0
	var hotbar_path := "HotbarWrapper/Hotbar"
	if ui.has_node(hotbar_path):
		var hotbar = ui.get_node(hotbar_path)
		var hotbar_slots = hotbar.get_children().filter(func(child): return child is InventorySlot)

		if hotbar_slots.size() >= 1:
			hotbar_slots[0].set_item({ "name": "IronOre", "count": 1 })
	else:
		print("🛑 Hotbar not found at path:", hotbar_path)

# === Toggles inventory visibility with a keybind ===
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		var container = $UILayer/InventoryUI/MainContainer
		if container:
			container.visible = not container.visible
		else:
			print("🛑 MainContainer not found under InventoryUI")

	if event is InputEventMouseButton:
		print("📍 Mouse button:", event.button_index, " at ", event.position)
