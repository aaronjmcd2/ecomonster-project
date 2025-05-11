# CoalWormInitModule.gd
# Handles initialization and setup for the Coal Worm

extends Node

# Initialize the Coal Worm with required setup
func initialize(worm: Node) -> void:
	# Set up physics
	_setup_physics(worm)
	
	# Add stats module child
	_setup_stats(worm)
	
	# Set up search display
	_setup_search_display(worm)

# Set up physics properties
func _setup_physics(worm: Node) -> void:
	worm.collision_layer = 2
	worm.collision_mask = 1

# Add stats tracking child node
func _setup_stats(worm: Node) -> void:
	worm.add_child(worm.coal_stat)

# Set up the search radius display
func _setup_search_display(worm: Node) -> void:
	if worm.search_display:
		worm.search_display.set_radius(worm.search_radius * 64)  # tile size conversion
