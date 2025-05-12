# GolemInitModule.gd
# Handles Golem initialization and setup

extends Node

# Initialize the Golem with all required setup
func initialize(golem: Node) -> void:
	# Set up physics
	_setup_physics(golem)
	
	# Set up search display
	_setup_search_display(golem)
	
	# Initialize animations if available
	if golem.has_node("AnimatedSprite2D"):
		golem.anim_sprite.play("idle")

# Set up physics properties
func _setup_physics(golem: Node) -> void:
	golem.collision_layer = 2
	golem.collision_mask = 1

# Set up the search radius display
func _setup_search_display(golem: Node) -> void:
	if golem.search_display:
		golem.search_display.set_radius(golem.search_radius_px)
