# CoalWormConsumptionModule.gd
# Handles consumption of ore drops

extends Node

# Consume the ore drop and handle cleanup
func consume_ore_drop(worm: Node, target_drop: Node) -> void:
	if not target_drop or not is_instance_valid(target_drop):
		return
	
	if not target_drop.has_method("consume"):
		print("🐛 Skipping drop without consume() method:", target_drop.name)
		return
	
	print("🐛 Coal Worm consuming:", target_drop.name)
	
	# Consume the drop
	target_drop.consume()
	
	# Clean up claiming reference
	if target_drop.claimed_by == worm:
		target_drop.claimed_by = null
