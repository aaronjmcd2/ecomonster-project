# SpecterInitModule.gd
# Handles Specter initialization and setup
extends Node

# Initialize the Specter with all required setup
func initialize(specter: Node) -> void:
	# Set up physics
	_setup_physics(specter)
	
	# Set up search display
	_setup_search_display(specter)
	
	# Initialize animations
	if specter.has_node("AnimatedSprite2D") and specter.sprite != null:
		specter.sprite.play("idle")

# Set up physics properties
func _setup_physics(specter: Node) -> void:
	specter.collision_layer = 2
	specter.collision_mask = 1

# Set up the search radius display
func _setup_search_display(specter: Node) -> void:
	if specter.search_display:
		specter.search_display.set_radius(specter.search_radius_px)
