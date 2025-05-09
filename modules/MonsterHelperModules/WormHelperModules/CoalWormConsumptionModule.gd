# CoalWormConsumptionModule.gd
# Enhanced to handle different target types

extends Node

# Consume the target based on its type
func consume_target(worm: Node, target_data: Dictionary) -> bool:
	match target_data.type:
		"drop":
			consume_ore_drop(worm, target_data.target)
			return true  # Assume success if we got this far
		"entity":
			return _consume_entity(worm, target_data.target, target_data.resource_type)
	
	return false

# Original function for ore drops (returns void)
func consume_ore_drop(worm: Node, target_drop: Node) -> void:
	if not target_drop or not is_instance_valid(target_drop):
		return
	
	if not target_drop.has_method("consume"):
		print("🐛 Skipping drop without consume() method:", target_drop.name)
		return
	
	print("🐛 Coal Worm consuming:", target_drop.name)
	target_drop.consume()
	
	if target_drop.claimed_by == worm:
		target_drop.claimed_by = null

# New function for entities (crystals and melons)
func _consume_entity(worm: Node, entity: Node, resource_type: String) -> bool:
	if not entity or not is_instance_valid(entity):
		return false
	
	match resource_type:
		"crystal":
			if entity.has_method("consume"):
				print("🐛 Coal Worm consuming crystal")
				entity.consume()
				return true
		
		"melon":
			if entity.has_method("harvest"):
				print("🐛 Coal Worm harvesting melon")
				entity.harvest(true)  # true = consumed by worm
				return true
	
	# Clean up claiming
	if entity.claimed_by == worm:
		entity.claimed_by = null
	
	return false
