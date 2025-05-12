# InventoryData.gd
# Stores and manages all inventory data: 8x7 grid, 8-slot hotbar, item movement, and dropping logic.
# Used by UI and player systems. Designed for modular extension later.
# Attached as Autoload singleton.

extends Node
class_name InventoryData

# === Constants ===
const INVENTORY_ROWS := 7
const INVENTORY_COLUMNS := 8
const HOTBAR_SIZE := 8

# === State ===
# inventory: Array of arrays representing rows of item slots (null = empty)
var inventory: Array = []
var hotbar_selected_index := 0
var sword_item := {
	"type": "weapon",
	"name": "Sword",
	"icon": preload("res://items/equipment/weapons/Sword.png"), # Replace with actual path
	"count": 1,
	#"scene": preload("res://items/SwordHitbox.tscn") # Optional, for spawning hitbox
}


func _ready():
	_initialize_inventory()

# === Initialize inventory with empty slots ===
func _initialize_inventory() -> void:
	inventory.clear()
	for row in INVENTORY_ROWS:
		var row_array := []
		for col in INVENTORY_COLUMNS:
			row_array.append(null)
		inventory.append(row_array)

# === Retrieve item at specified position ===
func get_item(row: int, col: int) -> Dictionary:
	return inventory[row][col]

# === Set an item in the grid ===
func set_item(row: int, col: int, item: Dictionary) -> void:
	inventory[row][col] = item

# === Move an item from one slot to another ===
# Stacks items if names match, replaces otherwise
func move_item(from_row: int, from_col: int, to_row: int, to_col: int) -> void:
	var from_item = inventory[from_row][from_col]
	var to_item = inventory[to_row][to_col]

	if to_item == null:
		inventory[to_row][to_col] = from_item
		inventory[from_row][from_col] = null
	elif from_item.name == to_item.name:
		to_item.count += from_item.count
		inventory[from_row][from_col] = null

# === Drops an item from inventory into the world near the player ===
# slot_ref: the inventory slot node this came from (used to clear/update)
func drop_item_from_inventory(item: Dictionary, slot_ref: Node, drop_entire_stack: bool = false) -> void:
	var player = get_tree().get_root().get_node_or_null("Main/Player")
	if player == null:
		print("❌ Player not found. Cannot drop item.")
		return

	var drop_pos = player.global_position + Vector2(16, 0)

	# TEMP: Determine drop scene from item type
	var drop_scene: PackedScene
	if item.has("scene"):
		drop_scene = item["scene"]
	else:
		match item["name"]:
			"IronOre":
				drop_scene = preload("res://items/drops/ores/IronOreDrop.tscn")
			"Egg":
				drop_scene = preload("res://items/drops/resources/Egg.tscn")
			"GoldOre":
				drop_scene = preload("res://items/drops/ores/GoldOreDrop.tscn")
			"SilverOre":
				drop_scene = preload("res://items/drops/ores/SilverOreDrop.tscn")
			"Melon":
				drop_scene = preload("res://items/drops/resources/Melon.tscn")
			"Stone":
				drop_scene = preload("res://items/drops/resources/Stone.tscn")
			# Inside the match statement for drop_scene
			"AetherdriftOre":
				drop_scene = preload("res://items/drops/ores/AetherdriftOre.tscn")
			"ReinforcedConcrete":
				drop_scene = preload("res://items/drops/resources/ReinforcedConcrete.tscn")
			"IronIngot":
				drop_scene = preload("res://items/drops/resources/IronIngot.tscn")
			"SilverIngot":
				drop_scene = preload("res://items/drops/resources/SilverIngot.tscn")
			"GoldIngot":
				drop_scene = preload("res://items/drops/resources/GoldIngot.tscn")
			"AetherdriftIngot":
				drop_scene = preload("res://items/drops/resources/AetherdriftIngot.tscn")
			_:
				print("⚠️ No drop scene found for item:", item["name"])
				return


	var drop_instance = drop_scene.instantiate()
	drop_instance.position = drop_pos
	get_tree().get_root().add_child(drop_instance)

	if drop_entire_stack:
		drop_instance.count = item.get("count", 1)
		slot_ref.clear_slot()
	else:
		drop_instance.count = 1
		item["count"] -= 1
		if item["count"] <= 0:
			slot_ref.clear_slot()
		else:
			slot_ref.set_item(item)
			
	# Signal that an item was dropped (for lake interaction, etc.)
	EventBus.emit_signal("item_dropped", item, drop_position)
