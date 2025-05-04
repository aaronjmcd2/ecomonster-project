# DragonInitModule.gd
# Handles Dragon initialization and setup
# Centralizes the setup logic from _ready()

extends Node

# Initialize the Dragon with all required setup
func initialize(dragon: Node) -> void:
	# Set up physics
	_setup_physics(dragon)
	
	# Set up search display
	_setup_search_display(dragon)
	
	# Find initial targets
	_find_initial_targets(dragon)
	
	# Initialize animations
	if dragon.has_node("AnimatedSprite2D"):
		dragon.anim_sprite.play("idle_down")

# Set up physics properties
func _setup_physics(dragon: Node) -> void:
	dragon.collision_layer = 2
	dragon.collision_mask = 1

# Set up the search radius display
func _setup_search_display(dragon: Node) -> void:
	if dragon.search_display:
		dragon.search_display.set_radius(dragon.search_radius_px)

# Find initial targets to pursue
func _find_initial_targets(dragon: Node) -> void:
	# First try to find lava
	dragon.target_tile = dragon.search_module.search_for_lava(dragon)
	
	# If no lava, try ice
	if not dragon.target_tile:
		dragon.target_tile = SearchModule.find_nearest_tile(
			dragon.global_position, 
			dragon.search_radius_tiles, 
			4  # Ice
		)

# Validate required nodes and resources
func validate_dependencies(dragon: Node) -> bool:
	var valid = true
	
	# Check tilemap layer
	if not dragon.tile_map_layer:
		push_error("Dragon: Could not find TileMapLayer!")
		valid = false
	
	return valid
