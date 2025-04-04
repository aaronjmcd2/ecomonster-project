extends Node

@onready var InventorySlotScene := preload("res://scenes/InventorySlot.tscn")

func _ready():
	await get_tree().process_frame  # Ensures all nodes are initialized

	var ui = $UILayer/InventoryUI

	# Debug print to verify structure
	for child in ui.get_children():
		print("📦 InventoryUI child:", child.name)

	var test_item = { "name": "IronOre", "count": 24 }

	# === Safe check for inventory grid ===
	var grid_path := "MainContainer/InventoryGrid"
	if ui.has_node(grid_path):
		var grid = ui.get_node(grid_path)
		var grid_slots = grid.get_children().filter(func(child): return child is InventorySlot)

		print("🧪 Found ", grid_slots.size(), " grid slots")

		if grid_slots.size() >= 2:
			print("🌱 Setting grid slots...")
			grid_slots[0].set_item(test_item)
			grid_slots[1].set_item({ "name": "IronOre", "count": 64 })
	else:
		print("🛑 InventoryGrid not found at path:", grid_path)

	# === Hotbar ===
	var hotbar_path := "HotbarWrapper/Hotbar"
	if ui.has_node(hotbar_path):
		var hotbar = ui.get_node(hotbar_path)

		# Clear old children
		for child in hotbar.get_children():
			hotbar.remove_child(child)
			child.queue_free()

		# Create 8 new InventorySlots
		for i in range(8):
			var slot := InventorySlotScene.instantiate()
			hotbar.add_child(slot)

		var hotbar_slots = hotbar.get_children().filter(func(child): return child is InventorySlot)
		print("🧪 Created ", hotbar_slots.size(), " hotbar slots")

		if hotbar_slots.size() >= 1:
			print("🌱 Setting hotbar slot 0...")
			hotbar_slots[0].set_item({ "name": "IronOre", "count": 1 })
	else:
		print("🛑 Hotbar not found at path:", hotbar_path)


func _unhandled_input(event):
	if event.is_action_pressed("inventory_toggle"):
		var container = $UILayer/InventoryUI/MainContainer
		if container:
			container.visible = not container.visible
		else:
			print("🛑 MainContainer not found under InventoryUI")

	if event is InputEventMouseButton:
		print("📍 Mouse button:", event.button_index, " at ", event.position)
