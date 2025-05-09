# FireElementalInitModule.gd
# Handles initialization and setup for Fire Elemental

extends Node

# Initialize the Fire Elemental with required setup
func initialize(elemental: Node) -> void:
	# Set up physics
	_setup_physics(elemental)
	
	# Add stats module child
	_setup_stats(elemental)
	
	# Set up search display
	_setup_search_display(elemental)

# Set up physics properties
func _setup_physics(elemental: Node) -> void:
	elemental.collision_layer = 2
	elemental.collision_mask = 1

# Add stats tracking child node
func _setup_stats(elemental: Node) -> void:
	elemental.add_child(elemental.lava_stat)

# Set up the search radius display
func _setup_search_display(elemental: Node) -> void:
	if elemental.search_display:
		elemental.search_display.set_radius(elemental.search_radius * 32)
