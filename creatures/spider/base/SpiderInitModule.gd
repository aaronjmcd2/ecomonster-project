# SpiderInitModule.gd
# Handles initialization and setup for Spider

extends Node

# Initialize the Spider with required setup
func initialize(spider: Node) -> void:
	# Set up physics
	_setup_physics(spider)
	
	# Add stats module child
	_setup_stats(spider)
	
	# Set up search display
	_setup_search_display(spider)

# Set up physics properties
func _setup_physics(spider: Node) -> void:
	spider.collision_layer = 2
	spider.collision_mask = 1

# Add stats tracking child node
func _setup_stats(spider: Node) -> void:
	spider.add_child(spider.silk_stat)

# Set up the search radius display
func _setup_search_display(spider: Node) -> void:
	if spider.search_display:
		spider.search_display.set_radius(spider.search_radius * 32)
