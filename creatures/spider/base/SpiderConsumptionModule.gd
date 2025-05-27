# SpiderConsumptionModule.gd
# Handles consumption of resources by the Spider

extends Node

# Consume the target resource
func consume_resource(spider: Node, target_data: Dictionary) -> void:
	if not target_data.target or not is_instance_valid(target_data.target):
		return
	
	print("🕷️ Spider consuming: ", target_data.resource_type)
	
	# Clean up claiming
	if target_data.target.claimed_by == spider:
		target_data.target.claimed_by = null
	
	# Remove the consumed item
	target_data.target.queue_free()
