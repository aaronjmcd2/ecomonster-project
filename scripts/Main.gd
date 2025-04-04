extends Node

func _ready():
	var ui = $UILayer/InventoryUI

	var test_item = { "name": "IronOre", "count": 24 }

	var grid = ui.get_node("Background/MainContainer/InventoryGrid")
	var grid_slots = grid.get_children().filter(func(child): return child is InventorySlot)

	var hotbar = ui.get_node("HotbarWrapper/Hotbar")
	var hotbar_slots = hotbar.get_children().filter(func(child): return child is InventorySlot)

	print("🧪 Found ", grid_slots.size(), " grid slots")
	print("🧪 Found ", hotbar_slots.size(), " hotbar slots")

	if grid_slots.size() >= 2:
		print("🌱 Setting grid slots...")
		grid_slots[0].set_item(test_item)
		grid_slots[1].set_item({ "name": "IronOre", "count": 64 })

	if hotbar_slots.size() >= 1:
		print("🌱 Setting hotbar slot 0...")
		hotbar_slots[0].set_item({ "name": "IronOre", "count": 1 })
		
func _unhandled_input(event):
	if event.is_action_pressed("inventory_toggle"):
		var container = $UILayer/InventoryUI/Background/MainContainer
		container.visible = not container.visible
	
	if event is InputEventMouseButton:
		print("📍 Mouse button:", event.button_index, " at ", event.position)
