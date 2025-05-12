# PlayerPickupModule.gd
# Handles item pickup detection and logic for the player
# Uses: InventoryDataScript, InventoryUI

extends Node

var parent_node = null
var inventory_ui = null
var pickup_radius: float = 100.0

# Setup function called from the Player's _ready
func setup(player_node, inventory_ui_ref, radius: float = 100.0) -> void:
	parent_node = player_node
	inventory_ui = inventory_ui_ref
	pickup_radius = radius

# Try to pickup items near a world position
func try_pickup_item(world_pos: Vector2) -> bool:
	# Array of all item groups we can pick up
	var pickup_groups = [
		"ore_drops",
		"egg_drops", 
		"world_items",
		"soul_drops",           # NEW: Soul drops from specters
		"crystal_shard_drops",  # NEW: Crystal shards from mining
		"crystal_drops"         # NEW: Full crystals
	]
	
	var closest_item = null
	var closest_distance = pickup_radius
	
	# Check each group for items
	for group in pickup_groups:
		var items = get_tree().get_nodes_in_group(group)
		
		for item in items:
			if is_instance_valid(item):
				var distance = item.global_position.distance_to(world_pos)
				
				# Check if this item is closer than any found so far
				if distance < closest_distance:
					closest_item = item
					closest_distance = distance
	
	# If we found a valid item to pick up
	if closest_item != null:
		print("🖐️ Picking up: ", closest_item.name)
		
		# Get item data dictionary (all pickups should implement this)
		var item_data = closest_item.get_item_data()
		
		# Add to inventory
		inventory_ui.add_item_to_inventory(item_data)
		
		# Remove from world
		closest_item.queue_free()
		return true
	
	return false
